// Define teams for the stack and assing roles

resource "grafana_team" "backend_team" {
  name  = "backend"
  email = "backend@example.com"
  members = []

  preferences {
    home_dashboard_uid = ""
  }
}

resource "grafana_team" "frontend_team" {
  name  = "frontend"
  email = "frontend@example.com"
  members = []

  preferences {
    home_dashboard_uid = ""
  }
}

resource "grafana_team" "platform_team" {
  name  = "platform"
  email = "platform@example.com"
  members = []

  preferences {
    home_dashboard_uid = ""
  }
}

data "grafana_role" "gck6_editor" {
  name = "plugins:k6-app:editor"
}

data "grafana_role" "gck6_admin" {
  name = "plugins:k6-app:admin"
}

resource "grafana_role_assignment" "gck6_editor_role_assignment" {
  role_uid = data.grafana_role.gck6_editor.uid
  teams    = [grafana_team.backend_team.id, grafana_team.frontend_team.id]
}

resource "grafana_role_assignment" "gck6_admin_role_assignment" {
  role_uid = data.grafana_role.gck6_admin.uid
  teams    = [grafana_team.platform_team.id]
}