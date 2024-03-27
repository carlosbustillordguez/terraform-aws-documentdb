variable "tags" {
  description = "Tags added to all supported resources."
  type        = map(any)
  default     = {}
}

variable "environment" {
  description = "The environment name, e.g: testing."
  type        = string
}

variable "cluster_name" {
  description = "A unique name for this DocumentDB Cluster."
  type        = string
}

variable "cluster_size" {
  description = <<EOT
  Set he number of instances to be deployed in this DocumentDB Cluster.
  A cluster can have up to sixteen instances (one primary and up to 15 replicas).
  EOT
  type        = number
  default     = 3
}

variable "cluster_engine_version" {
  description = <<EOT
  The database engine version. To see the available versions issue:
  `aws docdb describe-db-engine-versions --engine docdb --query 'DBEngineVersions[*].EngineVersion' --output text`
  EOT
  type        = string
  default     = "5.0.0"
}

variable "cluster_instance_class" {
  description = <<EOT
  The DocumentDB instance class. For a list of the supported instances, see:
  <https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs>
  EOT
  type        = string
  default     = "db.t4g.medium"
}

variable "cluster_db_port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 27017
}

variable "cluster_vpc_id" {
  description = "The VPC ID where the cluster will be provisioned."
  type        = string
}

variable "cluster_subnets_id" {
  description = <<EOT
  A list with the subnets ID to add to the Cluster Subnet Group. By setting this input variable, the `cluster_subnet_group_name`
  will be ignored and a new subnet group with the given subnets will be created and used by the DocumentDB Cluster.
  Subnet groups must contain at least two subnets in two different Availability Zones in the same region.
  EOT
  type        = list(string)
  default     = []
}

variable "cluster_subnet_group_name" {
  description = "The subnet group name for the DocumentDB Cluster. This input variable is ignored when `cluster_subnets_id` is set."
  type        = string
  default     = ""
}

variable "cluster_custom_parameters" {
  description = "A map of string with the custom parameters for this DocumentDB Cluster."
  type        = map(string)
  default     = {}
}

variable "cluster_master_username" {
  description = "Username for the master DB user. Required unless a `snapshot_identifier` is provided."
  type        = string
  default     = "admin"
}

variable "cluster_master_password" {
  description = <<EOT
  Password for the master DB user.
  Password must be at least eight characters long and cannot contain a / (slash), " (double quote) or @ (at symbol).
  Don't set when `snapshot_identifier` is provided. If no value is set, a random password will be generated.
  EOT
  type        = string
  default     = ""
}

variable "cluster_allowed_security_groups_id" {
  description = "A list with the allowed Security Groups ID to access to the DocumentDB Cluster."
  type        = list(string)
  default     = []
}

variable "cluster_at_rest_encryption" {
  description = "Whether to enable encryption of data stored on disk."
  type        = bool
  default     = true
}

variable "cluster_storage_type" {
  description = "The storage type to associate with the DB cluster."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "iopt1"], var.cluster_storage_type)
    error_message = "Possible values are `standard` or `iopt1`."
  }
}

variable "cluster_backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 35

  validation {
    condition = (
      var.cluster_backup_retention_period >= 1 &&
      var.cluster_backup_retention_period <= 35
    )
    error_message = "Accepted values are in the range 1 to 35."
  }
}

variable "cluster_preferred_backup_window" {
  description = <<EOT
  The daily time range during which automated backups are created if automated backups are enabled.
  The format is `hh24:mi-hh24:mi` (24H Clock UTC).
  EOT
  type        = string
  default     = "02:00-02:30"
}

variable "cluster_preferred_maintenance_window" {
  description = <<EOT
  Specifies the weekly time range for when maintenance on the DocumentDB Cluster is performed.
  The format is `ddd:hh24:mi-ddd:hh24:mi` (24H Clock UTC). The minimum maintenance window is a 60 minute period.
  EOT
  type        = string
  default     = "wed:04:00-wed:05:30"
}

variable "enabled_cloudwatch_logs_exports" {
  description = <<EOT
  List of log types to export to Amazon CloudWatch. The following log types are supported: `audit`, `profiler`.
  To enable auditing, ensure that both exporting auditing logs to Amazon CloudWatch is enabled and
  the Cluster Parameter "Auditing" is enabled.
  EOT
  type        = list(string)
  default     = []
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted."
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = <<EOT
  Specifies whether or not to create this cluster from a snapshot.
  You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot.
  Automated snapshots should not be used for this attribute, unless from a different cluster.
  Automated snapshots are deleted as part of cluster destruction when the resource is replaced.
  EOT
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "Whether the DocumentDB Cluster has deletion protection enabled."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DocumentDB instance,"
  type        = string
  default     = null
}

variable "enable_performance_insights" {
  description = "Whether to enable Performance Insights for the DocumentDB Instance."
  type        = bool
  default     = false
}

variable "save_cluster_master_password_ssm_params" {
  description = <<EOT
  Whether or no save the cluster master password in AWS SSM Parameter Store.
  The password is stored as secure string in `/documentdb/<CLUSTER_NAME>/CLUSTER_MASTER_PASSWORD`.
  EOT
  type        = bool
  default     = false
}

variable "save_cluster_master_password_aws_secrets" {
  description = <<EOT
  Whether or no save the cluster master password in AWS Secrets.
  The password is stored in a secret called `/documentdb/<CLUSTER_NAME>/CLUSTER_MASTER_PASSWORD`.
  EOT
  type        = bool
  default     = false
}
