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
