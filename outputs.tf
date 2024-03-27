output "master_username" {
  description = "Username for the master DB user."
  value       = aws_docdb_cluster.this.master_username
}

output "master_password" {
  description = "Password for the master DB user."
  value       = aws_docdb_cluster.this.master_password
  sensitive   = true
}

output "cluster_name" {
  description = "Cluster Identifier"
  value       = aws_docdb_cluster.this.cluster_identifier
}

output "arn" {
  description = "Amazon Resource Name (ARN) of the cluster."
  value       = aws_docdb_cluster.this.arn
}

output "endpoint" {
  description = "Endpoint of the DocumentDB cluster."
  value       = aws_docdb_cluster.this.endpoint

}

output "reader_endpoint" {
  description = "A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas."
  value       = aws_docdb_cluster.this.reader_endpoint
}

output "security_group_id" {
  description = "ID of the DocumentDB cluster Security Group."
  value       = aws_security_group.docdb.id
}

output "security_group_arn" {
  description = "ARN of the DocumentDB cluster Security Group."
  value       = aws_security_group.docdb.arn
}

output "security_group_name" {
  description = "Name of the DocumentDB cluster Security Group."
  value       = aws_security_group.docdb.name
}
