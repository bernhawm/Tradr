
output "api_endpoint" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "db_host" {
  value = aws_db_instance.users_db.endpoint
}

output "db_port" {
  value = aws_db_instance.users_db.port
}

output "db_username" {
  value = aws_db_instance.users_db.username
}

output "db_name" {
  value = "TradrRDSDB"
}
