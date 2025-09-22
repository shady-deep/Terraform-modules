################################POLICY DOCUMENT##################################
variable "trust_policy_document" {
  description = "A valid IAM policy JSON document."
  type        = string
  default     = null
}

variable "role_policy_document" {
  description = "A valid IAM policy JSON document."
  type        = string
  default     = null
}

variable "logging_role_policy_document" {
  description = "A valid IAM policy JSON document."
  type        = string
  default     = null
}
#######################################CREATE RESOURCES##########################
variable "create_iam_role" {
  description = "Determines if IAM role should be created"
  type        = bool
  default     = false
}

variable "create_logging_policy" {
  description = "Determines if IAM role should be created"
  type        = bool
  default     = false
}

variable "create_security_group" {
  description = "Determines if IAM role should be created"
  type        = bool
  default     = false
}

variable "vpc_id" {
  type = string
  default = null
}
###################################NAMES AND TAGS###############################
variable "iam_role_name" {
  description = "Name for the IAM role."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "iam_role_policy_name" {
  description = "Name for the IAM role policy."
  type        = string
  default     = null
}

variable "env" {
  description = "The environement usage"
  type        = string
  default     = null
}

variable "team" {
  description = "The environement usage"
  type        = string
  default     = null
}
################################LAMBDA FUNCTION################################
variable "lambda_function_handler" {
  description = "Lambda handler"
  type        = string
  default     = null
}

variable "lambda_function_memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = null
}

variable "lambda_function_runtime" {
  description = "runtime type"
  type        = string
  default     = null
}

variable "lambda_function_timeout" {
  description = "function timeout"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "terraform_state_bucket" {
  type        = string
  default     = null
}

variable "vpc_state_path" {
  type        = string
  default     = null
}

variable "create_lambda_function" {
  description = "create lambda or not"
  type        = bool
  default     = false
}

variable "kinesis_arn" {
  description = "kinesis arn"
  type        = string
  default     = null
}

variable "starting_position" {
  type        = string
  default     = null
}

variable "create_event_invocation" {
  type        = bool
  default     = false
}

variable "s3_bucket" {
  type        = string
  default     = null
}

variable "s3_key" {
  type        = string
  default     = null
}