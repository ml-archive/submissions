workflow "Auto docs" {
  on = "release"
  resolves = ["Jazzy docs"]
}

action "Jazzy docs" {
  uses = "nodes-vapor/github-actions/actions/jazzy-docs@master"
  secrets = [
    "GITHUB_TOKEN",
    "GH_USER",
    "GH_EMAIL",
  ]
  env = {
    TARGET = "Submissions"
  }
}
