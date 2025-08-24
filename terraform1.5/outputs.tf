output "spark_application_name" {
  value = kubernetes_manifest.spark_app.manifest["metadata"]["name"]
}
