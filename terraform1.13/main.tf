resource "null_resource" "apply_rbac" {
  provisioner "local-exec" {
    command = "kubectl apply -f ~/tf-workspace-spark/k8s/spark-cluster-rbac.yaml --kubeconfig=${var.kubeconfig_path} --context=${var.kube_context}"
  }

  provisioner "local-exec" {
    when    = destroy
    # Use static paths here, no variables allowed
    command = "kubectl delete -f ~/tf-workspace-spark/k8s/spark-cluster-rbac.yaml --kubeconfig=/home/vagrant/.kube/config --context=minikube"
  }
}

resource "null_resource" "apply_spark_app" {
  depends_on = [null_resource.apply_rbac]

  provisioner "local-exec" {
    command = "kubectl apply -f ~/tf-workspace-spark/k8s/spark-hello-app-deployment.yaml --kubeconfig=${var.kubeconfig_path} --context=${var.kube_context}"
  }

  provisioner "local-exec" {
    when    = destroy
    # Use static paths here, no variables allowed
    command = "kubectl delete -f ~/tf-workspace-spark/k8s/spark-hello-app-deployment.yaml --kubeconfig=/home/vagrant/.kube/config --context=minikube"
  }
}



#######for create and update
# resource "null_resource" "apply_rbac" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f ~/tf-workspace-spark/k8s/spark-cluster-rbac.yaml --kubeconfig=${var.kubeconfig_path} --context=${var.kube_context}"
#   }
# }
#
# resource "null_resource" "apply_spark_app" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f  ~/tf-workspace-spark/k8s/spark-hello-app-deployment.yaml --kubeconfig=${var.kubeconfig_path} --context=${var.kube_context}"
#   }
#
#   depends_on = [null_resource.apply_rbac]
# }