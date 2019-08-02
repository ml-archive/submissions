workflow "Auto docs" {
  on = "release"
  resolves = ["Jazzy docs"]
}

action "Jazzy docs" {
  uses = "nodes-vapor/github-actions/actions/jazzy-docs@master"
  secrets = [
    "GITHUB_TOKEN"
  ]
  env = {
    TARGET = "Submissions"
  }
}
