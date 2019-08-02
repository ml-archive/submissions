workflow "Auto docs" {
  resolves = ["Jazzy docs"]
  on = "release"
}

action "Jazzy docs" {
  uses = "nodes-vapor/github-actions/actions/jazzy-docs@develop"
  secrets = [
    "GITHUB_TOKEN",
  ]
  env = {
    TARGET = "Submissions"
  }
}
