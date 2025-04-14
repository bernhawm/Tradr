# Stop on first error
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Zipping Lambda functions..."

# Remove old zip files if they exist
if (Test-Path "lambda\lambda.zip") { Remove-Item "lambda\lambda.zip" }
if (Test-Path "lambda\lambda2.zip") { Remove-Item "lambda\lambda2.zip" }
if (Test-Path "lambda\lambda3.zip") { Remove-Item "lambda\lambda3.zip" }

# Zip the Lambda files
Compress-Archive -Path "lambda\readLambda\index.js" -DestinationPath "lambda\lambda.zip"
Compress-Archive -Path "lambda\writelambda\index.js" -DestinationPath "lambda\lambda2.zip"
Compress-Archive -Path "lambda\postConfirmation\index.js" -DestinationPath "lambda\lambda3.zip"

Write-Host "Lambda functions zipped."

Write-Host ""
Write-Host "Running Terraform Init..."
terraform init

Write-Host ""
# Write-Host "Running Terraform Plan..."
# $planOutput = terraform plan -out="tfplan.out" 2>&1

# if ($LASTEXITCODE -eq 0) {
#     Write-Host "Terraform plan completed successfully."
# } else {
#     Write-Host "Terraform plan failed:"
#     Write-Host $planOutput
#     exit 1
# }
# terraform plan
Write-Host ""
$response = Read-Host "Do you want to apply this plan? (yes/no)"
if ($response -eq "yes") {
    Write-Host "Applying Terraform changes..."
    terraform apply
    Write-Host "Terraform apply completed."
} else {
    Write-Host "Terraform apply cancelled."
}
$dbHost = terraform output -raw db_host
$dbPort = terraform output -raw db_port
$dbUser = terraform output -raw db_username
$dbName = terraform output -raw db_name

Write-Host "Retrieved RDS details:"
Write-Host "DB Host: $dbHost"
Write-Host "DB Port: $dbPort"
Write-Host "DB User: $dbUser"
Write-Host "DB Name: $dbName"


$createTableQuery = @"
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  cognito_sub UUID NOT NULL UNIQUE,
  username VARCHAR NOT NULL,
  email VARCHAR NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

$psqlCreateTableCommand = "psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c `"$createTableQuery`""


# Run the command to create the table
Invoke-Expression -Command $psqlCreateTableCommand
Write-Host "Table 'users' created successfully."

# Step 5: Insert Users into RDS DB
$sqlQuery = @"
INSERT INTO users (cognito_sub, username, email, password_hash)
VALUES
('sub1', 'username1', 'user1@example.com', 'hashedpassword1'),
('sub2', 'username2', 'user2@example.com', 'hashedpassword2');
"@


# Construct the psql command to insert users
$psqlInsertCommand = "psql -h $dbHost -p $dbPort -U $dbUser -d $dbName -c `"$sqlQuery`""

# Run the command to insert users
Invoke-Expression -Command $psqlInsertCommand
Write-Host "Users inserted successfully."

# Step 6: Sync Users to Cognito
$userPoolId = "tradr-user-pool"
$region = "us-east-2"

$users = @(
    @{ cognito_sub = 'sub1'; username = 'username1'; email = 'user1@example.com' },
    @{ cognito_sub = 'sub2'; username = 'username2'; email = 'user2@example.com' }
)

foreach ($user in $users) {
    $command = "aws cognito-idp admin-create-user --user-pool-id $userPoolId --username $($user.username) --user-attributes Name=email,Value=$($user.email) --desired-delivery-mediums EMAIL --region $region"
    Invoke-Expression -Command $command
    Write-Host "User $($user.username) created in Cognito."
}

Write-Host "All users synced to Cognito."