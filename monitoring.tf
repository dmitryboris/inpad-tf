resource "yandex_monitoring_dashboard" "api_vms_dashboard" {
  name        = "api-vms-dashboard"
  description = "Мониторинг API ВМ"
  title       = "API Servers Monitoring"

  # 1. CPU Usage для обеих ВМ
  widgets {
    chart {
      title    = "CPU Usage"
      chart_id = "api_cpu_chart"

      queries {
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.api[0].id}\"}"
        }
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.api[1].id}\"}"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
        yaxis_settings {
          left {
            max = 100
            min = 0
            title = "%"
            unit_format = "UNIT_PERCENT"
          }
        }
      }
    }

    position {
      h = 8
      w = 12
      x = 0
      y = 0
    }
  }

  # 3. Memory в ГБ
  widgets {
    chart {
      title    = "Memory Used (GB)"
      chart_id = "api_memory_gb_chart"

      queries {
        target {
          query = "memory_used{resource_id=\"${yandex_compute_instance.api[0].id}\"} / 1073741824"
        }
        target {
          query = "memory_used{resource_id=\"${yandex_compute_instance.api[1].id}\"} / 1073741824"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
        yaxis_settings {
          left {
            title = "GB"
            unit_format = "UNIT_BYTES_SI"
          }
        }
      }
    }

    position {
      h = 8
      w = 12
      x = 0
      y = 8
    }
  }

  # 4. Disk Usage
  widgets {
    chart {
      title    = "Disk Usage"
      chart_id = "api_disk_chart"

      queries {
        target {
          query = "disk_used_percent{resource_id=\"${yandex_compute_instance.api[0].id}\"}"
        }
        target {
          query = "disk_used_percent{resource_id=\"${yandex_compute_instance.api[1].id}\"}"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
        yaxis_settings {
          left {
            max = 100
            min = 0
            title = "%"
            unit_format = "UNIT_PERCENT"
          }
        }
      }
    }

    position {
      h = 8
      w = 12
      x = 12
      y = 8
    }
  }

  # 6. CPU Load Average
  widgets {
    chart {
      title    = "Load Average"
      chart_id = "api_load_chart"

      queries {
        target {
          query = "load1{resource_id=\"${yandex_compute_instance.api[0].id}\"}"
        }
        target {
          query = "load5{resource_id=\"${yandex_compute_instance.api[0].id}\"}"
        }
        target {
          query = "load1{resource_id=\"${yandex_compute_instance.api[1].id}\"}"
        }
        target {
          query = "load5{resource_id=\"${yandex_compute_instance.api[1].id}\"}"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
      }
    }

    position {
      h = 8
      w = 12
      x = 12
      y = 0
    }
  }
}

resource "yandex_monitoring_dashboard" "essential_dashboard" {
  name        = "inpad-essential-metrics"
  description = "Ключевые метрики всей инфраструктуры INPAD"
  title       = "INPAD Core Metrics"

  # 1. Все ВМ CPU в одном графике
  widgets {
    chart {
      title    = "Все серверы - CPU %"
      chart_id = "all_cpu"

      queries {
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.api[0].id}\"}"
        }
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.api[1].id}\"}"
        }
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.worker.id}\"}"
        }
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.rabbitmq.id}\"}"
        }
        target {
          query = "cpu_usage{resource_id=\"${yandex_compute_instance.postgres.id}\"}"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
        yaxis_settings {
          left {
            max = 100
            min = 0
            title = "CPU %"
            unit_format = "UNIT_PERCENT"
          }
        }
      }
    }

    position {
      h = 8
      w = 12
      x = 0
      y = 0
    }
  }

  # 2. Все ВМ Memory в одном графике
  widgets {
    chart {
      title    = "Все серверы - RAM %"
      chart_id = "all_memory"

      queries {
        target {
          query = "memory_usage{resource_id=\"${yandex_compute_instance.api[0].id}\"}"
        }
        target {
          query = "memory_usage{resource_id=\"${yandex_compute_instance.api[1].id}\"}"
        }
        target {
          query = "memory_usage{resource_id=\"${yandex_compute_instance.worker.id}\"}"
        }
        target {
          query = "memory_usage{resource_id=\"${yandex_compute_instance.rabbitmq.id}\"}"
        }
        target {
          query = "memory_usage{resource_id=\"${yandex_compute_instance.postgres.id}\"}"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
        yaxis_settings {
          left {
            max = 100
            min = 0
            title = "RAM %"
            unit_format = "UNIT_PERCENT"
          }
        }
      }
    }

    position {
      h = 8
      w = 12
      x = 12
      y = 0
    }
  }

  # 3. PostgreSQL - размер БД и дисковое пространство
  widgets {
    chart {
      title    = "PostgreSQL - Размер БД"
      chart_id = "postgres_disk_usage"

      queries {
        target {
          query = "postgresql_database_size_bytes{database=\"${var.pg_db}\"} / 1073741824"
        }
      }

      visualization_settings {
        type        = "VISUALIZATION_TYPE_LINE"
        aggregation = "SERIES_AGGREGATION_AVG"
        show_labels = true
        yaxis_settings {
          left {
            title = "Размер БД (GB)"
            unit_format = "UNIT_BYTES_SI"
          }
        }
      }
    }

    position {
      h = 8
      w = 12
      x = 0
      y = 8
    }
  }
}