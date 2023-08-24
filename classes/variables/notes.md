# Environment variables
Terraform refers to a number of environment variables to customize various aspects of its behavior. None of these environment variables are required when using Terraform, but they can be used to change some of Terraform's default behaviors in unusual situations, or to increase output verbosity for debugging.

### 1. TF_LOG
Enables detailed logs to appear on stderr which is useful for debugging. For example:
```yaml
export TF_LOG=trace
```

To disable, either unset it, or set it to off. For example:
```yaml
export TF_LOG=off
```
### 2. TF_LOG_PATH

This specifies where the log should persist its output to. Note that even when TF_LOG_PATH is set, TF_LOG must be set in order for any logging to be enabled. For example, to always write the log to the directory you're currently running terraform from:
```yaml
export TF_LOG_PATH=./terraform.log
```
### 3. TF_VAR_name

Environment variables can be used to set variables.
```yaml
export TF_VAR_region=us-west-1
export TF_VAR_ami=ami-049d8641
export TF_VAR_alist='[1,2,3]'
export TF_VAR_amap='{ foo = "bar", baz = "qux" }'
```

### 4. TF_WORKSPACE

For multi-environment deployment, in order to select a workspace, instead of doing terraform workspace select your_workspace, it is possible to use this environment variable. Using TF_WORKSPACE allow and override workspace selection.

For example:
```yaml
export TF_WORKSPACE=your_workspace
```
# Input variables

Input variables let you customize aspects of Terraform modules without altering the module's own source code. This functionality allows you to share modules across different Terraform configurations, making your module composable and reusable.

### Declaring an Input Variable
Each input variable accepted by a module must be declared using a variable block:

```yaml
variable "image_id" {
  type = string
}
variable "user_information" {
  type = object({
    name    = string
    address = string
  })
  sensitive = true
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-west-1a"]
}

variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
}

```
Type- we can have values to define type as string, number or bool.

### Variable validation
We can setup a variable validation as well while defining so that wrong value may not be use.
```yaml
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}
```
### variable using in block

```yaml
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = var.image_id
}
```
### Variable Definition Precedence
The above mechanisms for setting variables can be used together in any combination. If the same variable is assigned multiple values, Terraform uses the last value it finds, overriding any previous values. Note that the same variable cannot be assigned multiple values within a single source.  

Terraform loads variables in the following order, with later sources taking precedence over earlier ones:
   
Environment variables   
The terraform.tfvars file, if present.   
The terraform.tfvars.json file, if present.   
Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.  
Any -var and -var-file options on the command line, in the order they are provided. (This includes variables set by a Terraform Cloud workspace.)   

# Defining in configuration variable with locals block
Terraform local values (or "locals") assign a name to an expression or value. Using locals simplifies your Terraform configuration – since you can reference the local multiple times, you reduce duplication in your code.  
The major diffrence between locals and variable block is that locals gave you option to define any repetative variable value within the configuration file itself and not allowed to override value from outside where in variable give you option to 
- Define a default value within configuration file
- Define variable and pass using *.tfvars or *.auto.tfvars
- Define value using -var CLI argument
- Define value using -var-file option to select and use specific *.tfvar file.

#### Define local
Simple definition   
```yaml
locals {
  service_name = "forum"
  owner        = "Community Team"
}
```
Can use with variables and functions also and as well one local block can call to another.

```yaml
locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}

```

#### using local values
```json
resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}

```

# Output Values
Output values make information about your infrastructure available on the command line, and can expose information for other Terraform configurations to use. Output values are similar to return values in programming languages.

### Declaring an Output Value
Each output value exported by a module must be declared using an output block:

```json
output "instance_ip_addr" {
  value = aws_instance.server.private_ip
}
```

### Accessing Child Module Outputs
In a parent module, outputs of child modules are available in expressions as module.<MODULE NAME>.<OUTPUT NAME>. For example, if a child module named web_server declared an output named instance_ip_addr, you could access that value as module.web_server.instance_ip_addr

This is also importent with output block to use explicit dependancy Example:

```yaml

output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."

  depends_on = [
    # Security group rule must be created before this IP address could
    # actually be used, otherwise the services will be unreachable.
    aws_security_group_rule.local_access,
  ]
}
```