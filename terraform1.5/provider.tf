terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
  }
}
provider "kubernetes" {
  config_path = var.kubeconfig_path
  config_context = var.kube_context
}
