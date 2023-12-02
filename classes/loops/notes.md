
# Looping Constructs in Terraform
By default, a resource block configures one object. Using a loop, you can manage several similar objects without writing a separate block for each one. This reduces the amount of code you need to write and makes your scripts cleaner.

Two meta-arguments can be used to do this in Terraform:

- ``count –`` This looping construct creates a fixed number of resources based on a count value.  
- `for_each –` This looping construct allows you to create multiple instances of a resource based on a set of input values, such as a list or map.

```yaml
resource "aws_instance" "server" {
  count = 4 # create four similar EC2 instances

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index}"
  }
}
```
### The ``count`` Object
In blocks where count is set, an additional count object is available in expressions, so you can modify the configuration of each instance. This object has one attribute:

- ```count.index —``` The distinct index number (starting with 0) corresponding to this instance.

Example create ec2 based on each subnet.

```yaml
variable "subnet_ids" {
  type = list(string)
}

resource "aws_instance" "server" {
  # Create one instance for each subnet
  count = length(var.subnet_ids)

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_ids[count.index]

  tags = {
    Name = "Server ${count.index}"
  }
}
```
### The ```for_each``` Object


### Basic Syntax
for_each is a meta-argument defined by the Terraform language. It can be used with modules and with every resource type.

#### Map:
```yaml
resource "azurerm_resource_group" "rg" {
  for_each = {
    a_group = "eastus"
    another_group = "westus2"
  }
  name     = each.key
  location = each.value
}
```

#### Set of strings:
```yaml
resource "aws_iam_user" "the-accounts" {
  for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
  name     = each.key
}
```
#### Child module:
```yaml
# my_buckets.tf
module "bucket" {
  for_each = toset(["assets", "media"])
  source   = "./publish_bucket"
  name     = "${each.key}_bucket"
}
```

Bucket module:

```yaml
# publish_bucket/bucket-and-cloudfront.tf
variable "name" {} # this is the input parameter of the module

resource "aws_s3_bucket" "example" {
  # Because var.name includes each.key in the calling
  # module block, its value will be different for
  # each instance of this module.
  bucket = var.name

  # ...
}

resource "aws_iam_user" "deploy_user" {
  # ...
}
```

### Chaining
```yaml
variable "vpcs" {
  type = map(object({
    cidr_block = string
  }))
}

resource "aws_vpc" "example" {
  # One VPC for each element of var.vpcs
  for_each = var.vpcs

  # each.value here is a value from var.vpcs
  cidr_block = each.value.cidr_block
}

resource "aws_internet_gateway" "example" {
  # One Internet Gateway per VPC
  for_each = aws_vpc.example

  # each.value here is a full aws_vpc object
  vpc_id = each.value.id
}

output "vpc_ids" {
  value = {
    for k, v in aws_vpc.example : k => v.id
  }

  # The VPCs aren't fully functional until their
  # internet gateways are running.
  depends_on = [aws_internet_gateway.example]
}

```
### Using map
Example  

```yaml
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "local" {
  # Configuration options
}

resource "local_file" "foo" {
 for_each ={
     name = "vijay"
     age  = "42"
     value= "money"
 }
  content  = "foo! this is file ${each.value}"
  filename = "${path.module}/foo.bar${each.key}"
}
```

### Using Set
Example-1   
```yaml
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "local" {
  # Configuration options
}

resource "local_file" "foo" {
    for_each = toset( ["vijay", "42"])      
    content  = "foo! content is this ${each.key}"
    filename = "${path.module}/foo${each.key}.bar"
}
```

Example-2   
```yaml
locals {
  subnet_ids = toset([
    "subnet-abcdef",
    "subnet-012345",
  ])
}

resource "aws_instance" "server" {
  for_each = local.subnet_ids

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id     = each.key # note: each.key and each.value are the same for a set

  tags = {
    Name = "Server ${each.key}"
  }
}
```
# Dynamic block
Some Terraform resources include repeatable nested blocks in their arguments. These nested blocks represent separate resources that are related to the containing resource. 

Terraform provides the dynamic block to create repeatable nested blocks within a resource. A dynamic block is similar to the for expression. Where for creates repeatable top-level resources.

### Simple resource creation with for_each

```hcl
# VPC variable
variable “vpc-cidr” {
    default = “10.0.0.0/16”}
# Subnets variable
variable “vpc-subnets” {
    default = [“10.0.0.0/20”,“10.0.16.0/20”,“10.0.32.0/20”]
}

resource “aws_vpc” “vpc” {
	cidr_block = var.vpc-cidr
}

resource “aws_subnet” “main-subnet” {
	for_each = toset(var.vpc-subnets)
	cidr_block = each.value
	vpc_id = aws_vpc.vpc.id
}
```

### Dynamic block Security rules

```hcl
locals {
	inbound_ports = [80, 443]
	outbound_ports = [443, 1433]
	}
# Security Groups
resource “aws_security_group” “sg-webserver” {
	vpc_id = aws_vpc.vpc.id
	name = “webserver”
	description = “Security Group for Web Servers”
	dynamic “ingress” {
		for_each = local.inbound_ports
		content {
			from_port = ingress.value
			to_port = ingress.value
			protocol = “tcp”
			cidr_blocks = [ “0.0.0.0/0” ]
		}
	}
	dynamic “egress” {
		for_each = local.outbound_ports
		content {
			from_port = egress.value
			to_port = egress.value
			protocol = “tcp”
			cidr_blocks = [ var.vpc-cidr ]
		}
	}
}
```

### How to use Terraform dynamic blocks with lists

```hcl
locals {
	db_instance = “10.0.32.50/32”
	inbound_ports = [80, 443]
	outbound_rules = [{
        port = 443,
		cidr_blocks = [ var.vpc-cidr ]
	},{
        port = 1433,
		cidr_blocks = [ local.db_instance ]
	}]
}
# Security Groups
resource “aws_security_group” “sg-webserver” {
	vpc_id              = aws_vpc.vpc.id
	name                = “webserver”
	description         = “Security Group for Web Servers”
	dynamic “ingress” {
		for_each = local.inbound_ports
		content {
			from_port   = ingress.value
			to_port     = ingress.value
			protocol    = “tcp”
			cidr_blocks = [ “0.0.0.0/0” ]
		}
	}
	dynamic “egress” {
		for_each = local.outbound_rules
		content {
			from_port   = egress.value.port
			to_port     = egress.value.port
			protocol    = “tcp”
			cidr_blocks = egress.value.cidr_blocks
		}
	}
}
```