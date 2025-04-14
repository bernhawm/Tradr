resource "aws_cognito_user_pool" "user_pool" {
  name = "tradr-user-pool"

#   lambda_config {
#     post_confirmation = aws_lambda_function.postconfirmation.arn
#   }
#     depends_on = [aws_lambda_permission.allow_cognito_invoke]

  schema {
    name                = "email"
    required            = true
    attribute_data_type = "String"
    mutable             = true
  }

  schema {
    name                = "preferred_username"
    required            = true
    attribute_data_type = "String"
    mutable             = true
  }
    auto_verified_attributes = ["email"]
  lambda_config {
    post_confirmation = aws_lambda_function.postconfirmation.arn
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "tradr-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  callback_urls = ["https://yourfrontend.com/callback"] # to change
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "tradr-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.user_pool_client.id
    provider_name = aws_cognito_user_pool.user_pool.endpoint
  }
}


resource "aws_lambda_permission" "allow_cognito_invoke" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postconfirmation.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}
# resource "aws_cognito_user_pool_lambda_config" "lambda_config" {
#   user_pool_id      = aws_cognito_user_pool.user_pool.id
#   post_confirmation = aws_lambda_function.postconfirmation.arn

#   depends_on = [aws_lambda_permission.allow_cognito_invoke]
# }