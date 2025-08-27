# variable "kubeconfig_path" {
#   type    = string
#   default = "~/.kube/config"  # Update if using a custom config file
# }
variable "kubeconfig_path" {
  type    = string
  default = "/home/vagrant/mansur/.kube/config"  # Correct path inside VM
}
variable "kube_context" {
  type    = string
  default = "minikube"
}
