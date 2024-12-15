
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

resource "aws_cognito_user_pool_domain" "tech-challenge_domain" {
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
  password   = "Jf#25061998"
  depends_on = [aws_cognito_user_pool.tech-challenge_admin_pool]
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



