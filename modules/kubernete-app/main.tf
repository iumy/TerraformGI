# ============================================================================
# KUBERNETES APP MODULE - modules/kubernetes-app/main.tf
# ============================================================================
# Purpose: Deploy sample web application to EKS cluster

# ============================================================================
# NAMESPACE
# ============================================================================
# Purpose: Isolate application resources
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_name

    labels = {
      name        = var.app_name
      environment = var.environment
      owner       = var.owner_name
    }
  }
}

# ============================================================================
# CONFIGMAP - Custom HTML Content
# ============================================================================
# Purpose: Store custom HTML content as ConfigMap
resource "kubernetes_config_map" "webapp_html" {
  metadata {
    name      = "${var.app_name}-html"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "index.html" = templatefile("${path.module}/index.html.tpl", {
      owner_name   = var.owner_name
      environment  = var.environment
      cluster_name = var.cluster_name
    })
  }
}

# ============================================================================
# DEPLOYMENT
# ============================================================================
# Purpose: Deploy nginx web server pods with custom HTML
resource "kubernetes_deployment" "webapp" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app         = var.app_name
      environment = var.environment
      owner       = var.owner_name
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    # Rolling update strategy
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1 # One extra pod during update
        max_unavailable = 0 # All replicas available during update
      }
    }

    template {
      metadata {
        labels = {
          app         = var.app_name
          environment = var.environment
          owner       = var.owner_name
        }
      }

      spec {
        # Pod anti-affinity: Spread pods across different nodes/AZs
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app"
                    operator = "In"
                    values   = [var.app_name]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        # Container specification
        container {
          name  = "nginx"
          image = "nginx:1.25-alpine"

          # Resource requests and limits
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          # Container port
          port {
            container_port = 80
            protocol       = "TCP"
          }

          # Liveness probe: Check if container is healthy
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          # Readiness probe: Check if container is ready to serve traffic
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          # Mount custom HTML from ConfigMap
          volume_mount {
            name       = "html-content"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }
        }

        # Define volume from ConfigMap
        volume {
          name = "html-content"
          config_map {
            name = kubernetes_config_map.webapp_html.metadata[0].name
          }
        }
      }
    }
  }
}

# ============================================================================
# SERVICE - LoadBalancer
# ============================================================================
# Purpose: Expose deployment via AWS Application Load Balancer
resource "kubernetes_service" "webapp" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app = var.app_name
    }

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
      # Cross-zone load balancing
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
    }
  }

  spec {
    selector = {
      app = var.app_name
    }

    # Service port configuration
    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

