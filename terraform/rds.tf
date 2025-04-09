resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "Main subnet group"
  }
}

resource "aws_db_instance" "users_db" {
  identifier              = "tradrdatabase"
  allocated_storage       = 20
  engine                  = "postgres" # or "mysql"
  engine_version          = "15.12"
  instance_class          = "db.t3.micro"
  db_name = "TradrRDSDB"
  username                = var.DBusername
  password                = var.DBpassword 
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow RDS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ wide open for testing, lock this down later
  }
ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.lambda_sg.id]  # Lambda's SG
}
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "RDS subnet group"
  }
}
