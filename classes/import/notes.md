### TF Import
WIth aws Portal or CLI create following ( you can change names based on your choice)
```
Name: MyVM
Instance ID: i-0b9be609418aa0609
Type: t2.micro
VPC ID: vpc-1827ff72
```
### Create main.tf and Set Provider Configuration
```yaml
// Provider configuration
terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 3.0"
   }
 }
}
 
provider "aws" {
 region = "eu-central-1"
}
```
### Run terraform init to initialize the Terraform modules. 

Write Config for Resource To Be Imported
```yaml
resource "aws_instance" "myvm" {
 ami           = "unknown"
 instance_type = "unknown"
}
```
### Import
```
terraform import aws_instance.myvm <Instance ID>
```