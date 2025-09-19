# Define GCk6 project permissions for the different teams

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

# Under the hood all k6 folders are created as subfolders of the root "k6-app" folder
# Granting permissions to this folder will propagate to all subfolders
# https://grafana.com/docs/grafana-cloud/testing/k6/projects-and-users/configure-rbac/manage-roles-and-permissions/#set-up-team-access-for-new-and-existing-projects

# IMPORTANT: This is commented out bc the root folder is hidden in the list folders API... So this won't work.
# data "grafana_folder" "root_gck6_folder" {
#   title = "k6-app"
# }

# resource "grafana_folder_permission" "root_folder_permission" {
#   folder_uid = data.grafana_folder.root_gck6_folder.uid
#   permissions {
#     team_id    = grafana_team.platform_team.id
#     permission = "Admin"
#   }
# }