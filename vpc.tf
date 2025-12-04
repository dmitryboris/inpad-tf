# VPC
resource "yandex_vpc_network" "vpc" {
  name = "inpad-vpc"
}

//
// Create a new VPC NAT Gateway.
//
resource "yandex_vpc_gateway" "nat" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

//
// Create a new VPC Route Table.
//
resource "yandex_vpc_route_table" "nat_route" {
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# Подсеть для API и Worker
resource "yandex_vpc_subnet" "subnet_api" {
  name           = "subnet-api"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

# Подсеть для БД и RabbitMQ
resource "yandex_vpc_subnet" "subnet_db" {
  name           = "subnet-db"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["10.0.2.0/24"]
  route_table_id = yandex_vpc_route_table.nat_route.id
}

# Security Group для ALB
resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = yandex_vpc_subnet.subnet_api.v4_cidr_blocks
  }
}

# Security Group для API ВМ
resource "yandex_vpc_security_group" "api_sg" {
  name       = "api-sg"
  network_id = yandex_vpc_network.vpc.id

  ingress {
    description    = "Allow SSH from bastion"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = yandex_vpc_subnet.subnet_api.v4_cidr_blocks
  }

  ingress {
    description       = "Allow from ALB"
    protocol          = "TCP"
    port              = 8080
    security_group_id = yandex_vpc_security_group.alb_sg.id
  }

  ingress {
    description    = "Allow from Yandex ALB infrastructure"
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["198.18.235.0/24"]
  }

  ingress {
    description    = "Allow PostgreSQL access"
    protocol       = "TCP"
    port           = 5432
    v4_cidr_blocks = yandex_vpc_subnet.subnet_db.v4_cidr_blocks
  }

  ingress {
    description    = "Allow RabbitMQ access"
    protocol       = "TCP"
    port           = 5672
    v4_cidr_blocks = yandex_vpc_subnet.subnet_db.v4_cidr_blocks
  }

  egress {
    description    = "Allow outbound to PostgreSQL"
    protocol       = "TCP"
    port           = 5432
    v4_cidr_blocks = yandex_vpc_subnet.subnet_db.v4_cidr_blocks
  }

  egress {
    description    = "Allow outbound to RabbitMQ"
    protocol       = "TCP"
    port           = 5672
    v4_cidr_blocks = yandex_vpc_subnet.subnet_db.v4_cidr_blocks
  }

  egress {
    description    = "Allow outbound to S3"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow outbound HTTP for dependencies"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Outbound SSH for GitHub"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
