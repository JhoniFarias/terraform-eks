
resource "kubernetes_deployment" "tech_challenge_deployment" {
  metadata {
    name      = "tech-challenge-deployment"
    namespace = var.kubernetes_namespace
  }

  spec {
    selector {
      match_labels = {
        app = "tech-challenge-deployment"
      }
    }

    template {
      metadata {
        labels = {
          app = "tech-challenge-deployment"
        }
      }

      spec {
        toleration {
          key      = "key"
          operator = "Equal"
          value    = "value"
          effect   = "NoSchedule"
        }

        container {
          name  = "tech-challenge-api"
          image = "jhonideveloper/tech-challenge-api:2.11"

          resources {
            requests = {
              memory : "512Mi"
              cpu : "500m"
            }
            limits = {
              memory = "1Gi"
              cpu    = "1"
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.general-settings.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.api-secrets.metadata[0].name
            }
          }

          port {
            container_port = 3000
          }
        }
      }
    }
  }

  depends_on = [aws_eks_node_group.tech_challenge_node_group]
}


resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
  metadata {
    name = "hpa"
    namespace = "default" # Substitua pelo namespace correto, se necessário
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "tech-challenge-deployment"
    }

    min_replicas = 1
    max_replicas = 10

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type               = "Utilization"
          average_utilization = 60
        }
      }
    }

 behavior {
      scale_up {
        stabilization_window_seconds = 0

        policy {
          type          = "Pods"
          value         = 2
          period_seconds = 10
        }

        select_policy = "Max" # Usa a política com o valor máximo
      }

      scale_down {
        stabilization_window_seconds = 30

        policy {
          type          = "Pods"
          value         = 2
          period_seconds = 30
        }

        select_policy = "Max" # Usa a política com o valor máximo
      }
    }
  }
}


resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = "default" # Ajuste o namespace conforme necessário
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:latest"

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "500m"
            }
          }

          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis"
    namespace = "default" # Ajuste o namespace conforme necessário
  }

  spec {
    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }

    type = "ClusterIP"
  }
}




resource "kubernetes_secret" "api-secrets" {
  metadata {
    name = "api-secrets"
  }

  type = "Opaque"

  data = {
    POSTGRES_DB       = var.postgres_db
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    USER_TOKEN_SECRET = var.user_token_secret
    COGNITO_CLIENT_ID = var.cognito_client_id
    COGNITO_USER_POOL_ID = var.cognito_user_pool_id
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "kubernetes_config_map" "general-settings" {
  metadata {
    name = "general-settings"
  }
  data = {
    NODE_ENV                   = "development"
    APP_NAME                   = "tech-challenge"
    APP_PORT                   = "3000"
    APP_VERSION                = "1.0.0"
    APP_DOCUMENTATION_ENDPOINT = "/api"
    POSTGRES_PORT              = "5432"
    POSTGRES_HOST              = var.postgres_host
    USER_TOKEN_EXPIRES_IN      = "900"
    CACHE_SERVICE_HOST         = "redis"
    CACHE_SERVICE_PORT         = "6379"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "kubernetes_service" "api_service" {
  metadata {
    name      = "api-service"
    namespace = var.kubernetes_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" : "nlb",
      "service.beta.kubernetes.io/aws-load-balancer-scheme" : "internal",
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" : "true"
    }
  }
  spec {
    selector = {
      app = "tech-challenge-api"
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress_v1" "api_ingress" {
  metadata {
    name      = "ingress-api"
    namespace = var.kubernetes_namespace
  }

  spec {
    rule {
      http {
        path {
          path      = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.api_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

}

data "kubernetes_service" "api_service_data" {
  metadata {
    name      = kubernetes_service.api_service.metadata[0].name
    namespace = kubernetes_service.api_service.metadata[0].namespace
  }
}
