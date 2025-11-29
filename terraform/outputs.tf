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
output "monitoring_namespace" {
  description = "The namespace created for Monitoring"
  value       = var.monitoring_namespace
}
output "traces_namespace" {
  description = "The namespace created for Traces"
  value       = var.traces_namespace
}
output "logging_namespace" {
    description = "The namespace created for Logging"
    value       = var.logging_namespace

}
output "namespace_otlc" {
    description = "The namespace created for OpenTelemetry Collector"
    value       = var.open_telemetry_collector_namespace
}