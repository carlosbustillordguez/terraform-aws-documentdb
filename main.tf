################################################################################
# Local Values
################################################################################

locals {

  # Fixed tags
  fixed_tags = {
    Terraform          = true
    TerraformWorkspace = terraform.workspace
    Environment        = var.environment
  }

  common_tags = merge(local.fixed_tags, var.tags)

  # Get the DocumentDB major and minor version
  docdb_major_minor_version = regex("[0-9]+.[0-9]+", var.cluster_engine_version)

  # Cluster family
  cluster_family = "docdb${local.docdb_major_minor_version}"
}


################################################################################
# Master Random Password
################################################################################

resource "random_password" "password" {
  count = var.cluster_master_password == "" ? 1 : 0

  length  = 16
  special = false
}


################################################################################
# Save Cluster Master Password in AWS SSM Parameter Store or AWS Secrets
################################################################################

resource "aws_ssm_parameter" "cluster_master_password" {
  count = var.save_cluster_master_password_ssm_params ? 1 : 0

  name  = "/documentdb/${var.cluster_name}/CLUSTER_MASTER_PASSWORD"
  type  = "SecureString"
  value = var.cluster_master_password != "" ? var.cluster_master_password : random_password.password[0].result

  tags = merge(local.common_tags, {
    documentDBCluster = var.cluster_name
  })
}

resource "aws_secretsmanager_secret" "cluster_master_password" {
  count = var.save_cluster_master_password_aws_secrets ? 1 : 0

  name = "/documentdb/${var.cluster_name}/CLUSTER_MASTER_PASSWORD"

  tags = merge(local.common_tags, {
    documentDBCluster = var.cluster_name
  })
}

resource "aws_secretsmanager_secret_version" "cluster_master_password" {
  count = var.save_cluster_master_password_aws_secrets ? 1 : 0

  secret_id     = aws_secretsmanager_secret.cluster_master_password[0].id
  secret_string = "/documentdb/${var.cluster_name}/CLUSTER_MASTER_PASSWORD"
}


################################################################################
# DocumentDB Subnet Group
################################################################################

resource "aws_docdb_subnet_group" "default" {
  count = length(var.cluster_subnets_id) > 0 ? 1 : 0

  name        = var.cluster_name
  description = "Allowed subnets for DocumentDB cluster instances"
  subnet_ids  = var.cluster_subnets_id
  tags        = local.common_tags
}


################################################################################
# DocumentDB Parameter Group
################################################################################

# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "custom" {
  count = length(var.cluster_custom_parameters) > 0 ? 1 : 0

  name        = "${var.cluster_name}-custom-params"
  description = "Custom ${local.cluster_family} parameter group"
  family      = local.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_custom_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = local.common_tags
}


################################################################################
# DocumentDB Cluster Security Group
################################################################################

## EC2 Security Group
resource "aws_security_group" "docdb" {
  name_prefix = "${var.cluster_name}-"
  description = "DocumentDB Cluster Security Group"
  vpc_id      = var.cluster_vpc_id
  tags        = merge(local.common_tags, { "Name" : var.cluster_name })
}

## EC2 Security Group Rules
# tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group_rule" "docdb_egress" {
  type              = "egress"
  description       = "Allow outbound traffic from this SG"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.docdb.id
}

resource "aws_security_group_rule" "docdb_self_ingress" {
  type              = "ingress"
  description       = "Allow traffic within the SG"
  from_port         = var.cluster_db_port
  to_port           = var.cluster_db_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.docdb.id
}

resource "aws_security_group_rule" "docdb_ingress" {
  for_each = toset(var.cluster_allowed_security_groups_id)

  type                     = "ingress"
  description              = "Allow inbound traffic from the given SG"
  from_port                = var.cluster_db_port
  to_port                  = var.cluster_db_port
  protocol                 = "tcp"
  source_security_group_id = each.key
  security_group_id        = aws_security_group.docdb.id
}

################################################################################
# DocumentDB Cluster Definition
################################################################################

## DocumentDB Cluster Configuration
# tfsec:ignore:aws-documentdb-enable-log-export # this is controlled by var.enabled_cloudwatch_logs_exports
# tfsec:ignore:aws-documentdb-encryption-customer-key # managed AWS key meet our requirements
resource "aws_docdb_cluster" "this" {
  cluster_identifier              = var.cluster_name
  master_username                 = var.cluster_master_username
  master_password                 = var.cluster_master_password != "" ? var.cluster_master_password : random_password.password[0].result
  engine                          = "docdb"
  engine_version                  = var.cluster_engine_version
  port                            = var.cluster_db_port
  vpc_security_group_ids          = [aws_security_group.docdb.id]
  db_subnet_group_name            = length(var.cluster_subnets_id) > 0 ? aws_docdb_subnet_group.default[0].name : var.cluster_subnet_group_name
  db_cluster_parameter_group_name = length(var.cluster_custom_parameters) > 0 ? aws_docdb_cluster_parameter_group.custom[0].name : null
  storage_encrypted               = var.cluster_at_rest_encryption
  storage_type                    = var.cluster_storage_type
  backup_retention_period         = var.cluster_backup_retention_period
  preferred_backup_window         = var.cluster_preferred_backup_window
  preferred_maintenance_window    = var.cluster_preferred_maintenance_window
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  final_snapshot_identifier       = var.cluster_name
  skip_final_snapshot             = var.skip_final_snapshot
  snapshot_identifier             = var.snapshot_identifier
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately

  tags = local.common_tags
}

## DocumentDB Instances Configuration
# tfsec:ignore:aws-documentdb-encryption-customer-key # managed AWS key meet our requirements
resource "aws_docdb_cluster_instance" "this" {
  count = var.cluster_size

  identifier                   = "${var.cluster_name}-${count.index + 1}"
  cluster_identifier           = aws_docdb_cluster.this.id
  engine                       = "docdb"
  instance_class               = var.cluster_instance_class
  ca_cert_identifier           = var.ca_cert_identifier
  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.cluster_preferred_maintenance_window
  enable_performance_insights  = var.enable_performance_insights

  tags = local.common_tags
}
