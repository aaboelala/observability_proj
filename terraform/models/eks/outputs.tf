output "cluster_name" {
    description = "The name of the EKS cluster"
    value       = aws_eks_cluster.main.name
  
}
output "cluster_endpoint" {
    description = "The endpoint of the EKS cluster"
    value       = aws_eks_cluster.main.endpoint
}
output "cluster_certificate_authority_data" {
    description = "The certificate authority data for the EKS cluster"
    value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.oidc.url
}
