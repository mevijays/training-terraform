terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source = "hashicorp/random"
      version = "3.3.2"
    }
  }
}

provider "local" {
  # Configuration options
}

provider "random" {

}

variable list {
  type        = list
  default     = ["rakesh","vijay","imtiyaz","rahul"]
  description = "description"
}

resource "random_id" "server" {
  byte_length = 2
}


resource "local_file" "foo" {
    count  = length(var.list)
    content  = "foo! content is this ${count.index}"
    filename = "${path.module}/foo${count.index}-${random_id.server.hex}.bar"
}
