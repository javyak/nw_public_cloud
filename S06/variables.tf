
variable "region" {
  default = "eu-west-1"
}
variable "amis" {
  type = map
  default = {
    "eu-west-1" = "ami-035966e8adab4aaad"
  }
}

variable "ami_user" {
  default = "ubuntu"
}

variable "web_server_image" {
  default = "./web_server_files/goku.jpg"
}

variable "alb_certificate_arn" {
  default = "arn:aws:acm:eu-west-1:151803822585:certificate/6eaada10-2f24-4f77-8b14-c914678f7b78"
}