terraform {
  required_providers {
    docker = {
      source  = "registry.terraform.io/kreuzwerker/docker"
      version = "~>3.0"
    }

    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~>3.5"
    }
  }
}

provider "random" {}
provider "docker" {}

variable "port" {
  type    = number
  default = 27017
}

variable "network_mode" {
  type    = string
  default = "bridge"
}


resource "random_pet" "dbname" {}

resource "docker_image" "mongo" {
  name         = "mongo:latest"
  keep_locally = false
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.image_id
  name  = random_pet.dbname.id
  ports {
    internal = 27017
    external = var.port
  }
}

locals {
  port = var.network_mode == "host" ?  27017 : docker_container.mongo.ports[0].external
}


output "MONGO_URL" {
  sensitive   = true
  value       = "mongodb://localhost:${local.port}/${random_pet.dbname.id}"
}

output "MONGO_DBNAME" {
  sensitive   = true
  value       = random_pet.dbname.id
}
