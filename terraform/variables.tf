variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ansible-nginx-setup"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP address allowed to connect through SSH"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "Ubuntu AMI ID used for the EC2 instance"
  type        = string
}
