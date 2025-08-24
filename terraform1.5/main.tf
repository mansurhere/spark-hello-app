resource "kubernetes_manifest" "rbac" {
  manifest = yamldecode(file("${path.module}/../k8s/spark-cluster-rbac.yaml"))
}

resource "kubernetes_manifest" "spark_app" {
  manifest = yamldecode(file("${path.module}/../k8s/spark-hello-app-deployment.yaml"))
  depends_on = [kubernetes_manifest.rbac]
}