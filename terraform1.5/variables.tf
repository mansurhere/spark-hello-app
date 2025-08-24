variable "kubeconfig_path" {
 type    = string
  default = "~/.kube/config"  # Change if your kubeconfig is elsewhere
}

variable "kube_context" {
 type    = string
  default = "minikube"        # or your EKS context
}
