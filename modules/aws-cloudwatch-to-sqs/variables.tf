variable "name_prefix" {
  type        = string
  description = "Name prefix for resources"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "lambda_source_file" {
    type = string
    description = "The code to be used for the lamda function"
}

variable "datastore_type" {
    type = string
    description = "This will be placed as a suffix when creating SQS objects to avoid collisions"
}

variable "log_group" {
  type = string
  description = "The name of the cloudwatch log group"
}

variable "handler" {
  type = string
  description = "The name of the handler. This should be in the pattern of filename.function_name"
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime for the Lambda function"
  default     = "python3.13"
}