# Amazon DocumentDB (with MongoDB Compatibility)

Terraform module to provision an instance based cluster, [Amazon DocumentDB (with MongoDB Compatibility)](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html).

An instance based cluster can scale the databases to millions of reads per second and up to 128 TiB of storage capacity.

**Table of Contents:**

- [Amazon DocumentDB (with MongoDB Compatibility)](#amazon-documentdb-with-mongodb-compatibility)
  - [Important Notes](#important-notes)
    - [Cluster Access](#cluster-access)
    - [Amazon DocumentDB Quotas and Limits](#amazon-documentdb-quotas-and-limits)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

## Important Notes

- The cluster admin user name (`cluster_master_username` input variable) must be from 1 to 63 letters or numbers. The first character must be a letter and cannot be a reserved word.
- The cluster master password (`cluster_master_password` input variable) be at least eight characters long and cannot contain a `/` (slash), `"` (double quote) or `@` (at symbol). If not value is set for the password, a random password will be generated. Optionally you can store the provided/generated password in AWS SSM Parameter Store (`save_cluster_master_password_ssm_params=true`) and/or AWS Secrets (`save_cluster_master_password_aws_secrets`); the password will be available at `/documentdb/<CLUSTER_NAME>/CLUSTER_MASTER_PASSWORD` key.
- All resources with tags support, will be tagged with the following tags as default:
  - `Terraform`: indicates the resources is managed by Terraform. Value `true`.
  - `TerraformWorkspace`: indicates the current [Terraform's workspace](https://www.terraform.io/cli/workspaces). If no worksapce is used, the value is `default`.
  - `Environment`: indicates the name of the environment to which the resource belongs. The value is taken from the `environment` input variable.

  Additional tags can be defined by setting the `tags` input variable, e.g.:

    ```hcl
    tags = {
      Project = "MyProject"
      TerraformModule = "documentdb_cluster"
    }
    ```

### Cluster Access

This module attach a Security Group to the DocumentDB only allowing traffic within the Security Group itself. To allow others Security Group to access to the cluster, set the `cluster_allowed_security_groups_id` input parameter.

### Amazon DocumentDB Quotas and Limits

For the resource quotas, limits, and naming constraints for Amazon DocumentDB (with MongoDB compatibility) see [Amazon DocumentDB Quotas and Limits](https://docs.aws.amazon.com/documentdb/latest/developerguide/limits.html).

## Usage

```hcl
module "documentdb_cluster" {
  source = "../"

  environment                              = "testing"
  cluster_name                             = "mydocumentdb1245"
  cluster_size                             = 3
  cluster_engine_version                   = "5.0.0"
  cluster_instance_class                   = "db.t4g.medium"
  cluster_vpc_id                           = "vpc-xxx"
  cluster_subnets_id                       = ["subnet-abc", "subnet-cdf", "subnet-ghi"]
  cluster_master_username                  = "docadmin"
  deletion_protection                      = true
  save_cluster_master_password_ssm_params  = true

  tags = {
    Project         = "MyProject"
    TerraformModule = "documentdb_cluster"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.42.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.42.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_docdb_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) | resource |
| [aws_docdb_cluster_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance) | resource |
| [aws_docdb_cluster_parameter_group.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_parameter_group) | resource |
| [aws_docdb_subnet_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_subnet_group) | resource |
| [aws_secretsmanager_secret.cluster_master_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.cluster_master_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.docdb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.docdb_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.docdb_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.docdb_self_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.cluster_master_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. | `bool` | `false` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | The identifier of the CA certificate for the DocumentDB instance, | `string` | `null` | no |
| <a name="input_cluster_allowed_security_groups_id"></a> [cluster\_allowed\_security\_groups\_id](#input\_cluster\_allowed\_security\_groups\_id) | A list with the allowed Security Groups ID to access to the DocumentDB Cluster. | `list(string)` | `[]` | no |
| <a name="input_cluster_at_rest_encryption"></a> [cluster\_at\_rest\_encryption](#input\_cluster\_at\_rest\_encryption) | Whether to enable encryption of data stored on disk. | `bool` | `true` | no |
| <a name="input_cluster_backup_retention_period"></a> [cluster\_backup\_retention\_period](#input\_cluster\_backup\_retention\_period) | The days to retain backups for. | `number` | `35` | no |
| <a name="input_cluster_custom_parameters"></a> [cluster\_custom\_parameters](#input\_cluster\_custom\_parameters) | A map of string with the custom parameters for this DocumentDB Cluster. | `map(string)` | `{}` | no |
| <a name="input_cluster_db_port"></a> [cluster\_db\_port](#input\_cluster\_db\_port) | The port on which the DB accepts connections. | `number` | `27017` | no |
| <a name="input_cluster_engine_version"></a> [cluster\_engine\_version](#input\_cluster\_engine\_version) | The database engine version. To see the available versions issue:<br>  `aws docdb describe-db-engine-versions --engine docdb --query 'DBEngineVersions[*].EngineVersion' --output text` | `string` | `"5.0.0"` | no |
| <a name="input_cluster_instance_class"></a> [cluster\_instance\_class](#input\_cluster\_instance\_class) | The DocumentDB instance class. For a list of the supported instances, see:<br>  <https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs> | `string` | `"db.t4g.medium"` | no |
| <a name="input_cluster_master_password"></a> [cluster\_master\_password](#input\_cluster\_master\_password) | Password for the master DB user.<br>  Password must be at least eight characters long and cannot contain a / (slash), " (double quote) or @ (at symbol).<br>  Don't set when `snapshot_identifier` is provided. If no value is set, a random password will be generated. | `string` | `""` | no |
| <a name="input_cluster_master_username"></a> [cluster\_master\_username](#input\_cluster\_master\_username) | Username for the master DB user. Required unless a `snapshot_identifier` is provided. | `string` | `"admin"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | A unique name for this DocumentDB Cluster. | `string` | n/a | yes |
| <a name="input_cluster_preferred_backup_window"></a> [cluster\_preferred\_backup\_window](#input\_cluster\_preferred\_backup\_window) | The daily time range during which automated backups are created if automated backups are enabled.<br>  The format is `hh24:mi-hh24:mi` (24H Clock UTC). | `string` | `"02:00-02:30"` | no |
| <a name="input_cluster_preferred_maintenance_window"></a> [cluster\_preferred\_maintenance\_window](#input\_cluster\_preferred\_maintenance\_window) | Specifies the weekly time range for when maintenance on the DocumentDB Cluster is performed.<br>  The format is `ddd:hh24:mi-ddd:hh24:mi` (24H Clock UTC). The minimum maintenance window is a 60 minute period. | `string` | `"wed:04:00-wed:05:30"` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Set he number of instances to be deployed in this DocumentDB Cluster.<br>  A cluster can have up to sixteen instances (one primary and up to 15 replicas). | `number` | `3` | no |
| <a name="input_cluster_storage_type"></a> [cluster\_storage\_type](#input\_cluster\_storage\_type) | The storage type to associate with the DB cluster. | `string` | `"standard"` | no |
| <a name="input_cluster_subnet_group_name"></a> [cluster\_subnet\_group\_name](#input\_cluster\_subnet\_group\_name) | The subnet group name for the DocumentDB Cluster. This input variable is ignored when `cluster_subnets_id` is set. | `string` | `""` | no |
| <a name="input_cluster_subnets_id"></a> [cluster\_subnets\_id](#input\_cluster\_subnets\_id) | A list with the subnets ID to add to the Cluster Subnet Group. By setting this input variable, the `cluster_subnet_group_name`<br>  will be ignored and a new subnet group with the given subnets will be created and used by the DocumentDB Cluster.<br>  Subnet groups must contain at least two subnets in two different Availability Zones in the same region. | `list(string)` | `[]` | no |
| <a name="input_cluster_vpc_id"></a> [cluster\_vpc\_id](#input\_cluster\_vpc\_id) | The VPC ID where the cluster will be provisioned. | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Whether the DocumentDB Cluster has deletion protection enabled. | `bool` | `false` | no |
| <a name="input_enable_performance_insights"></a> [enable\_performance\_insights](#input\_enable\_performance\_insights) | Whether to enable Performance Insights for the DocumentDB Instance. | `bool` | `false` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to Amazon CloudWatch. The following log types are supported: `audit`, `profiler`.<br>  To enable auditing, ensure that both exporting auditing logs to Amazon CloudWatch is enabled and<br>  the Cluster Parameter "Auditing" is enabled. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name, e.g: testing. | `string` | n/a | yes |
| <a name="input_save_cluster_master_password_aws_secrets"></a> [save\_cluster\_master\_password\_aws\_secrets](#input\_save\_cluster\_master\_password\_aws\_secrets) | Whether or no save the cluster master password in AWS Secrets.<br>  The password is stored in a secret called `/documentdb/<CLUSTER_NAME>/CLUSTER_MASTER_PASSWORD`. | `bool` | `false` | no |
| <a name="input_save_cluster_master_password_ssm_params"></a> [save\_cluster\_master\_password\_ssm\_params](#input\_save\_cluster\_master\_password\_ssm\_params) | Whether or no save the cluster master password in AWS SSM Parameter Store.<br>  The password is stored as secure string in `/documentdb/<CLUSTER_NAME>/CLUSTER_MASTER_PASSWORD`. | `bool` | `false` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this cluster from a snapshot.<br>  You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot.<br>  Automated snapshots should not be used for this attribute, unless from a different cluster.<br>  Automated snapshots are deleted as part of cluster destruction when the resource is replaced. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags added to all supported resources. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster Identifier |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Endpoint of the DocumentDB cluster. |
| <a name="output_master_password"></a> [master\_password](#output\_master\_password) | Password for the master DB user. |
| <a name="output_master_username"></a> [master\_username](#output\_master\_username) | Username for the master DB user. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the DocumentDB cluster Security Group. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the DocumentDB cluster Security Group. |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the DocumentDB cluster Security Group. |
<!-- END_TF_DOCS -->
