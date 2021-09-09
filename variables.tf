variable "AWS_REGION" {
    type = string
    default = "eu-west-3"
}

variable "AWS_REGION_AMIS" {
    type = map
    default = {
        "eu-west-3" : "ami-0f7cd40eac2214b37"
    }
}

variable "AWS_ACCESS_KEY" {
  type        = string
}

variable "AWS_SECRET_KEY" {
  type        = string
}

variable "AWS_INSTANCE_TYPE" {
  type        = string
  default     = "t2.micro"
}

variable "AWS_KEY_NAME" {
    type= string
}

variable "AWS_SCRIPTS" {
    type = list
}

variable "S3_NAME" {
    type= string
}

variable "NAME" {
    type= string
}