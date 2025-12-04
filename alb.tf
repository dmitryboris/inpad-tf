# Target group для API ВМ
resource "yandex_alb_target_group" "api_tg" {
  name = "api-target-group"

  target {
    ip_address = "10.0.1.10"
    subnet_id  = yandex_vpc_subnet.subnet_api.id
  }

  target {
    ip_address = "10.0.1.11"
    subnet_id  = yandex_vpc_subnet.subnet_api.id
  }
}

# Backend group для API
resource "yandex_alb_backend_group" "api_backend" {
  name = "api-backend-group"

  http_backend {
    name             = "api-http-backend"
    port             = 8080
    target_group_ids = [yandex_alb_target_group.api_tg.id]

    healthcheck {
      http_healthcheck {
        path = "/health"
      }
      timeout  = "3s"
      interval = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }

    http2 = false
  }
}

# HTTP Router
resource "yandex_alb_http_router" "router" {
  name = "inpad-router"
}

# Virtual Host
resource "yandex_alb_virtual_host" "main" {
  name           = "main-host"
  http_router_id = yandex_alb_http_router.router.id
  authority      = ["*"]

  route {
    name = "api-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.api_backend.id
        timeout          = "3s"
      }
    }
  }
}

# ALB
resource "yandex_alb_load_balancer" "alb" {
  name               = "inpad-alb"
  network_id         = yandex_vpc_network.vpc.id
  security_group_ids = [yandex_vpc_security_group.alb_sg.id]

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.subnet_api.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = var.ip_address
        }
      }
      ports = [80]
    }
    http {
      redirects {
        http_to_https = true
      }
    }
  }

  listener {
    name = "https-listener"
    endpoint {
      address {
        external_ipv4_address {
          address = var.ip_address
        }
      }
      ports = [443]
    }
    tls {
      default_handler {
        certificate_ids = [var.certificate_id]
        http_handler {
          http_router_id = yandex_alb_http_router.router.id
        }
      }
    }
  }
}
