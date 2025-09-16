// Define teams for the stack and assing roles

resource "grafana_team" "backend_team" {
  provider = grafana.testing-stack

  name  = "backend"
  email = "backend@example.com"
  members = []

  preferences {
    home_dashboard_uid = ""
  }
}

resource "grafana_team" "frontend_team" {
  provider = grafana.testing-stack

  name  = "frontend"
  email = "frontend@example.com"
  members = []

  preferences {
    home_dashboard_uid = ""
  }
}

resource "grafana_team" "platform_team" {
  provider = grafana.testing-stack

  name  = "platform"
  email = "platform@example.com"
  members = []

  preferences {
    home_dashboard_uid = ""
  }
}

data "grafana_role" "gck6_editor" {
  provider = grafana.testing-stack

  name = "plugins:k6-app:editor"
}

data "grafana_role" "gck6_admin" {
  provider = grafana.testing-stack

  name = "plugins:k6-app:admin"
}

resource "grafana_role_assignment" "gck6_editor_role_assignment" {
  provider = grafana.testing-stack

  role_uid = data.grafana_role.gck6_editor.uid
  teams    = [grafana_team.backend_team.id, grafana_team.frontend_team.id]
}

resource "grafana_role_assignment" "gck6_admin_role_assignment" {
  provider = grafana.testing-stack

  role_uid = data.grafana_role.gck6_admin.uid
  teams    = [grafana_team.platform_team.id]
}