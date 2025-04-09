
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_policy_attachment" "lambda_basic" {
  name       = "lambda_basic_attach"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dynamodb_access" {
  name   = "lambda_dynamodb_access"
  description = "Policy to allow Lambda to interact with DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem","dynamodb:UpdateItem", "dynamodb:PutItem", "dynamodb:Query"
        ],
        Resource = aws_dynamodb_table.users_collections.arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "dynamodb_policy_attach" {
  name       = "attach_dynamo"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.dynamodb_access.arn
}





resource "aws_lambda_function" "get_collections" {
  filename         = "lambda/lambda.zip"
  function_name    = "get_collections"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("lambda/lambda.zip")
  timeout          = 10
    environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.users_collections.name
      RDS_HOST       = aws_db_instance.users_db.address
      RDS_USER       = var.DBusername
      RDS_PASSWORD   = var.DBpassword  # this is just here for default use since it is spun down after test
      RDS_DATABASE   = "TradrRDSDB"
    }
  }
  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "create_collection" {
  filename         = "lambda/lambda2.zip"
  function_name = "CreateCollectionFunction"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  source_code_hash      = filebase64sha256("lambda/lambda2.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_collections.name
    }
  }
}


resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}
