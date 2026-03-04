variable "email" {
  type = string
  default = "thomas.yang2@gmail.com"
}

variable "repo_url" {
  type = string
  default = "https://github.com/TomWorld2026/unleash"
}

variable "sns_topic" {
  default = "arn:aws:sns:us-east-1:637226132888:Candidate-Verification-Topic"
}