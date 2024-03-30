# Section-1
## What is terraform?
HashiCorp Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.
## What is IaaC?
IaaC stand for Infrastructure as code.  
Infrastructure as Code (IaC) tools allow you to manage infrastructure with configuration files rather than through a graphical user interface. IaC allows you to build, change, and manage your infrastructure in a safe, consistent, and repeatable way by defining resource configurations that you can version, reuse, and share.  Terraform is HashiCorp's infrastructure as code tool.   

- Terraform can manage infrastructure on multiple cloud platforms.
- The human-readable configuration language helps you write infrastructure code quickly.
- Terraform's state allows you to track resource changes throughout your deployments.
- You can commit your configurations to version control to safely collaborate on infrastructure.

## manage any infrastructure
>Terraform plugins called providers let Terraform interact with cloud platforms and other services via their application programming interfaces (APIs). HashiCorp and the Terraform community have written over 1,000 providers to manage resources on Amazon Web Services (AWS), Azure, Google Cloud Platform (GCP), Kubernetes, Helm, GitHub, Splunk, and DataDog, just to name a few. Find providers for many of the platforms and services you already use in the Terraform Registry

To deploy infrastructure with Terraform:

**Scope** - Identify the infrastructure for your project.  
**Author** - Write the configuration for your infrastructure.  
**Initialize** - Install the plugins Terraform needs to manage the infrastructure.  
**Plan** - Preview the changes Terraform will make to match your configuration.  
**Apply** - Make the planned changes.   
![Terraform workflow](./asset/assets1.webp)

## Track your infrastructure
Terraform keeps track of your real infrastructure in a state file, which acts as a source of truth for your environment. Terraform uses the state file to determine the changes to make to your infrastructure so that it will match your configuration.

## Collaborate
Terraform allows you to collaborate on your infrastructure with its remote state backends. When you use Terraform Cloud (free for up to five users), you can securely share your state with your teammates, provide a stable environment for Terraform to run in, and prevent race conditions when multiple people make configuration changes at once.

You can also connect Terraform Cloud to version control systems (VCSs) like GitHub, GitLab, and others, allowing it to automatically propose infrastructure changes when you commit configuration changes to VCS. This lets you manage changes to your infrastructure through version control, as you would with application code.

## How does Terraform work?
Terraform creates and manages resources on cloud platforms and other services through their application programming interfaces (APIs). Providers enable Terraform to work with virtually any platform or service with an accessible API. HashiCorp and the Terraform community have already written thousands of providers to manage many different types of resources and services. You can find all publicly available providers on the [Terraform Registry](https://registry.terraform.io/), including Amazon Web Services (AWS), Azure, Google Cloud Platform (GCP), Kubernetes, Helm, GitHub, Splunk, DataDog, and many more..    
![Terraform](./asset/assets.avif)
>The core Terraform workflow consists of three stages:

- **Write:** You define resources, which may be across multiple cloud providers and services. For example, you might create a configuration to deploy an application on virtual machines in a Virtual Private Cloud (VPC) network with security groups and a load balancer.  
- **Plan:** Terraform creates an execution plan describing the infrastructure it will create, update, or destroy based on the existing infrastructure and your configuration.  
- **Apply:** On approval, Terraform performs the proposed operations in the correct order, respecting any resource dependencies. For example, if you update the properties of a VPC and change the number of virtual machines in that VPC, Terraform will recreate the VPC before scaling the virtual machines.
The Terraform workflow has three steps: Write, Plan, and Apply
![terraform stages](./asset/assets2.avif)

# Section-2
## Installation of terraform CLI
The installation can be donein a very easy way on windows and linux both.
- **Windows:**  
Windows 11 powershell winget install.
```powershell
 winget install Hashicorp.Terraform
 ```
If winget is not working then download the exe binary and add binary in path same like given [here](https://www.radishlogic.com/terraform/how-to-install-terraform-in-windows-11/) 
 - **Linux:**  
 Any linux binary install way ..    
 Check for the latest release version [here](https://github.com/hashicorp/terraform/releases)

 ```bash
 wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip
 unzip terraform_1.5.5_linux_amd64.zip
 sudo chmod +x terraform
 sudo mv terraform /usr/local/bin/
 ```
 - **MacOS**
 ```zsh
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
 ```

 Enable terraform auto complete.
 ```bash
 terraform -install-autocomplete
 ```

 # Section-3
 ## First Setup with aws provider

 Generate aws api secret key and access key. Now add environment variable**
```bash 
export AWS_ACCESS_KEY_ID=xxxx
```
```bash
export AWS_SECRET_ACCESS_KEY=xxxxx
```

main.tf file, **Example-1**

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

```

main.tf file, **Example-2**
```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "192.168.1.0/24"
}
```

# Section-4

## Terraform providers
**What is terraform providers?**  
Terraform relies on plugins called providers to interact with cloud providers, SaaS providers, and other APIs.  
**What Providers Do?**
Each provider adds a set of resource types and/or data sources that Terraform can manage.
Every resource type is implemented by a provider; without providers, Terraform can't manage any kind of infrastructure.   
**Where Providers Come From?**   
Providers are distributed separately from Terraform itself, and each provider has its own release cadence and version numbers.

The [Terraform Registry](https://registry.terraform.io/) is the main directory of publicly available Terraform providers, and hosts providers for most major infrastructure platforms.   
**Provider Installation**  
- Terraform Cloud and Terraform Enterprise install providers as part of every run.

- Terraform CLI finds and installs providers when initializing a working directory. It can automatically download providers from a Terraform registry, or load them from a local mirror or cache. If you are using a persistent working directory, you must reinitialize whenever you change a configuration's providers.

| Tier  |Description|Namespace|
|-------|-----------|---------|
|Official|Official providers are owned and maintained by HashiCorp|Hashicorp|
|Partner|Partner providers are written, maintained, validated and published by third-party companies against their own APIs. |Third-party orgnizations|
|Community|Community providers are published to the Terraform Registry by individual maintainers| maintainer's individual|

### provider configurations

## Providers example (all 3 major cloud)
### AWS
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
variable "secret_key" {
}
/*
// environment variable way
sh-
% export AWS_ACCESS_KEY_ID="anaccesskey"
% export AWS_SECRET_ACCESS_KEY="asecretkey"
powershell-
$env:AWS_ACCESS_KEY_ID="anaccesskey"
$env:AWS_SECRET_ACCESS_KEY="asecretkey"
*/
provider "aws" {
  region = "us-east-1"
/*
secret option
access_key = "my-access-key"
secret_key = var.secret_key 
*/
}

resource "aws_vpc" "this" {
  cidr_block = "192.168.0.0/22"
}
```
### Azure
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
variable "client_secret" {
}
//Authentication option as environment variables.
/*
# sh
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="12345678-0000-0000-0000-000000000000"
export ARM_TENANT_ID="10000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="20000000-0000-0000-0000-000000000000"
# PowerShell
> $env:ARM_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
> $env:ARM_CLIENT_SECRET = "12345678-0000-0000-0000-000000000000"
> $env:ARM_TENANT_ID = "10000000-0000-0000-0000-000000000000"
> $env:ARM_SUBSCRIPTION_ID = "20000000-0000-0000-0000-000000000000"
*/
provider "azurerm" {
  features {}
/*
  client_id       = "00000000-0000-0000-0000-000000000000"
  client_secret   = var.client_secret
  tenant_id       = "10000000-0000-0000-0000-000000000000"
  subscription_id = "20000000-0000-0000-0000-000000000000"
*/
}

resource "azurerm_resource_group" "this" {
  name     = "krlabrg"
  location = "West Europe"
}
```
### GCP
```
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.7.0"
    }
  }
}
/*
Environment variable way
export GOOGLE_APPLICATION_CREDENTIALS=key.json
*/
provider "google" {
  project     = "my-project-id"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}
```


```bash
provider "google" {
  project = "acme-app"
  region  = "us-central1"
}

```
#### Alias providers.   
```powershell
# The default provider configuration; resources that begin with `aws_` will use
# it as the default, and it can be referenced as `aws`.
provider "aws" {
  region = "us-east-1"
}

# Additional provider configuration for west coast region; resources can
# reference this as `aws.west`.
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

```   
Use of alias providers in terraform resources   
```bash
resource "aws_instance" "foo" {
  provider = aws.west

  # ...
}

```


### Version Constraints
Anywhere that Terraform lets you specify a range of acceptable versions for something, it expects a specially formatted string known as a version constraint. Version constraints are used when configuring:

- Modules
- Provider requirements
- The required_version setting in the terraform block.
### Version Constraint Syntax   
``` bash
version = ">= 1.2.0, < 2.0.0"
```
The following operators are valid:

- **= (or no operator):** Allows only one exact version number. Cannot be combined with other conditions.

- **!=:** Excludes an exact version number.

- **>, >=, <, <=:** Comparisons against a specified version, allowing versions for which the comparison is true. "Greater-than" requests newer versions, and "less-than" requests older versions.

- **~>:** Allows only the rightmost version component to increment. For example, to allow new patch releases within a specific minor release, use the full version number: ~> 1.0.4 will allow installation of 1.0.5 and 1.0.10 but not 1.1.0. This is usually called the pessimistic constraint operator.



















 ** we never hardcode any credentials in code.
