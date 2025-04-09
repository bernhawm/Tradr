# Stop on first error
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Zipping Lambda functions..."

# Remove old zip files if they exist
if (Test-Path "lambda\lambda.zip") { Remove-Item "lambda\lambda.zip" }
if (Test-Path "lambda\lambda2.zip") { Remove-Item "lambda\lambda2.zip" }

# Zip the Lambda files
Compress-Archive -Path "lambda\readLambda\index.js" -DestinationPath "lambda\lambda.zip"
Compress-Archive -Path "lambda\writelambda\index.js" -DestinationPath "lambda\lambda2.zip"

Write-Host "Lambda functions zipped."

Write-Host ""
Write-Host "Running Terraform Init..."
terraform init

Write-Host ""
Write-Host "Running Terraform Plan..."
# $planOutput = terraform plan -out="tfplan.out" 2>&1

# if ($LASTEXITCODE -eq 0) {
#     Write-Host "Terraform plan completed successfully."
# } else {
#     Write-Host "Terraform plan failed:"
#     Write-Host $planOutput
#     exit 1
# }
terraform plan
Write-Host ""
$response = Read-Host "Do you want to apply this plan? (yes/no)"
if ($response -eq "yes") {
    Write-Host "Applying Terraform changes..."
    terraform apply
    Write-Host "Terraform apply completed."
} else {
    Write-Host "Terraform apply cancelled."
}
