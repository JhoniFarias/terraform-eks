
data "aws_lb" "tech_challenge_lb" {
  tags = {
    "kubernetes.io/service-name" = "default/service-tech_challenge-app"
  }

  depends_on = [kubernetes_service.api_service]
}

data "aws_lb_listener" "tech_challenge_lb_listener" {
  load_balancer_arn = data.aws_lb.tech_challenge_lb.arn
  port              = 80

  depends_on = [kubernetes_service.api_service]
}

# Cria a API Gateway do tipo HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "tech_challenge_http_api"
  protocol_type = "HTTP"
  description   = "tech_challenge HTTP API"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "ANY /api/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.loadBalancer_eks.id}"

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_apigatewayv2_integration.loadBalancer_eks]
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name = "tech_challenge_vpc_link"
  subnet_ids = [
    aws_subnet.tech_challenge_private_subnet_1.id,
    aws_subnet.tech_challenge_private_subnet_2.id
  ]
  security_group_ids = [
    aws_security_group.api_gw_sg.id,
    aws_security_group.eks_security_group.id,
  ]

  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_apigatewayv2_integration" "signin_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.signIn.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "signin_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /signin"

  target = "integrations/${aws_apigatewayv2_integration.signin_integration.id}"
}

resource "aws_lambda_permission" "allow_apigateway_signin" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signIn.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}



resource "aws_apigatewayv2_integration" "signup_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.signUp.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "signup_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /signup"

  target = "integrations/${aws_apigatewayv2_integration.signup_integration.id}"
}

resource "aws_lambda_permission" "allow_apigateway_signup" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signUp.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}





resource "aws_apigatewayv2_integration" "loadBalancer_eks" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = data.aws_lb_listener.tech_challenge_lb_listener.arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.vpc_link.id

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [kubernetes_service.api_service]
}

resource "aws_security_group" "api_gw_sg" {
  name        = "api-gw-sg"
  description = "Allow API Gateway access"
  vpc_id      = aws_vpc.tech_challenge_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

