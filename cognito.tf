
resource "aws_cognito_user_pool" "tech-challenge_admin_pool" {
  name = "tech-challenge-admin-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  username_attributes      = []
  mfa_configuration        = "OFF"
  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_user_pool_domain" "tech-challenge-domain" {
  domain       = "tech-challenge-domain"
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
}

resource "aws_cognito_user_pool_client" "tech-challenge_client" {
  name                                 = "tech-challenge-client"
  user_pool_id                         = aws_cognito_user_pool.tech-challenge_admin_pool.id
  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  prevent_user_existence_errors        = "ENABLED"
  callback_urls                        = ["https://localhost/"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user" "admin_user" {
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
  username     = "admin@email.com"
  attributes = {
    email = "admin@email.com"
  }
  password   = var.cognito_password_temp
  depends_on = [aws_cognito_user_pool.tech-challenge_admin_pool]
}

resource "aws_cognito_user_group" "gp_administradores" {
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
  name         = "Administrador"
}

resource "aws_cognito_user_in_group" "add_user_in_group_adm" {
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
  group_name   = aws_cognito_user_group.gp_administradores.name
  username     = aws_cognito_user.admin_user.username
}




resource "aws_cognito_user" "prepline_user" {
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
  username     = "cozinha@email.com"
  attributes = {
    email = "cozinha@email.com"
  }
  password   = var.cognito_password_temp
  depends_on = [aws_cognito_user_pool.tech-challenge_admin_pool]
}

resource "aws_cognito_user_group" "gp_cozinha" {
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
  name         = "Cozinha"
}

resource "aws_cognito_user_in_group" "add_user_in_group_cozinha" {
  user_pool_id = aws_cognito_user_pool.tech-challenge_admin_pool.id
  group_name   = aws_cognito_user_group.gp_cozinha.name
  username     = aws_cognito_user.prepline_user.username
}


output "cognito_client_id" {
  value = aws_cognito_user_pool_client.tech-challenge_client.id
  sensitive = true
}

output "cognito_client_secret" {
  value = aws_cognito_user_pool_client.tech-challenge_client.client_secret
  sensitive = true
}


output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.tech-challenge_admin_pool.id
  sensitive = true
}



