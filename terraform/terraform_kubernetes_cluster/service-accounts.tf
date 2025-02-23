resource "yandex_iam_service_account" "docker-registry" {
  name        = "docker-registry"
  description = "service account to use container registry"
}

resource "yandex_iam_service_account" "instances-editor" {
  name        = "instances-editor"
  description = "service account to manage VMs"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.folder_id

  role = "editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.instances-editor.id}",
  ]

  depends_on = [
    "yandex_iam_service_account.instances-editor"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "pusher" {
  folder_id = var.folder_id

  role = "container-registry.images.pusher"

  members = [
    "serviceAccount:${yandex_iam_service_account.docker-registry.id}",
  ]

  depends_on = [
    "yandex_iam_service_account.docker-registry"
  ]
}
