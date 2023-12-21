provider "random" {
}

resource "random_string" "secret" {
  length  = 16
  special = true 
}

resource "aws_ssm_parameter" "audit_secret" {
  name  = "audit_secret"
  type  = "SecureString"
  value = random_string.secret.result

  description = "Password for Audit log access"
}
