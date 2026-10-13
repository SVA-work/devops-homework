
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "ssh://devops-server"
}

resource "docker_network" "nginx_network" {
  name   = "terraform_net"
  driver = "bridge"
}

resource "docker_volume" "nginx_volume" {
  name = "nginx_data"
}

resource "docker_image" "nginx" {
  name         = "nginx:stable-alpine"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name    = "terraform_nginx"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.nginx_network.name
  }

  volumes {
    volume_name    = docker_volume.nginx_volume.name
    container_path = "/usr/share/nginx/html"
  }

  ports {
    internal = 80
    external = 8081
    ip       = "127.0.0.1"
  }
}

output "nginx_url" {
  value = "http://127.0.0.1:8081"
}

