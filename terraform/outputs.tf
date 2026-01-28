#account id output


output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name  
}

output "app_namespace" {
  description = "The namespace created for the application"
  value       = var.app_namespace
  
}
output "argo_cd_namespace" {
  description = "The namespace created for ArgoCD"
  value       = var.argo_cd_namespace
}
output "observability_namespace" {
  description = "The namespace created for Observability"
  value       = var.observability_namespace
}

output "loki_irsa_role_arn" {
  value = module.loki_irsa.iam_role_arn
}

output "tempo_irsa_role_arn" {
  value = module.tempo_irsa.iam_role_arn
}
