terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Token de comunicacao com a nuvem
provider "digitalocean" {
  token = var.do_token
}

# Definicao da maquina para o Jenkins
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

# Definicao da chave ssh
data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}


# Definicoes do cluster k8s
resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = "nyc1"
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2

  }
}

# As variaveis estao declaradas no arquivo terraform.tfvars que esta no .gitignore
########################################################
variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

variable "region" {
  default = ""
}
########################################################

# Output do IP da maquina do jenkins
output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
}

# Output do arquivo .kube_config do cluster kubernetes
resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
}
