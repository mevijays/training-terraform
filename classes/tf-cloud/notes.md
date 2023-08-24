# Terraform cloud

```VCS use-```  https://github.com/hashicorp/learn-terraform-cloud/blob/main/README.md


### Use remote backend as TF cloud
- Make a signup here [Sign up terraform](https://app.terraform.io/public/signup/account)   ( Free terraform cloud account ).
- Run command ``terraform login`` this command will redirect you to browser (no machine login available till terraform 1.5.5) for login. When you done with your login, you can close the browser and terraform login credentials will be stored here ``/<homedir>/.terraform.d/credentials.tfrc.json`` .
- Now you can use bellow terraform ``cloud`` configuration in your terraform block.

```yaml
terraform {
  cloud {
    organization = "organization-name"
    workspaces {
      name = "learn-terraform-cloud"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13.0"
    }
  }
```

### VCS use in cloud   

- terraform.tf
```yaml
terraform {

  cloud {
    organization = "organization-name"

    workspaces {
      name = "learn-terraform-cloud"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13.0"
    }
  }

  required_version = ">= 1.5.0"
}
```
- Variable.tf

```yaml
variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "EC2 instance name"
  default     = "Provisioned by Terraform"
}

```

- main.tf

```yaml
provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}

```

- Output.tf

```yaml
output "instance_ami" {
  value = aws_instance.ubuntu.ami
}

output "instance_arn" {
  value = aws_instance.ubuntu.arn
}

```
