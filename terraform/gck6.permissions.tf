// Define GCk6 project permissions for the different teams

resource "grafana_folder_permission" "backend_folder_permission" {
  folder_uid = grafana_k6_project.backend_project.grafana_folder_uid
  permissions {
    team_id    = grafana_team.backend_team.id
    permission = "Admin"
  }
  permissions {
    team_id    = grafana_team.frontend_team.id
    permission = "View"
  }
}

resource "grafana_folder_permission" "web_app_folder_permission" {
  folder_uid = grafana_k6_project.web_app_project.grafana_folder_uid
  permissions {
    team_id    = grafana_team.frontend_team.id
    permission = "Edit"
  }
  permissions {
    team_id    = grafana_team.backend_team.id
    permission = "View"
  }
}