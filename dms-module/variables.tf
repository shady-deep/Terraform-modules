###############################################################
########################## generic ############################

variable "aws_region" {
  type        = string
  description = ""
  default     = "us-east-1"
}

variable "env" {
  type        = string
  description = ""
  default     = "sbx"
}
###############################################################
########################## KMS key ############################

variable "create_kms_key" {
  type    = bool
  default = false
}


###############################################################
########################## subnet group #######################

variable "subnet_groups" {
  description = "Subnet groups will be associate to the Replication instance"
  type        = list(any)
  default     = []
}

##############################################################
########################## replication instance ###############

variable "replication_instances" {
  type        = list(any)
  description = "Replication instances that will hold the Tasks"
  default     = []
}

##############################################################
########################## source endpoint ###################

variable "dms_source_endpoints" {
  type        = list(any)
  description = "DMS source endpoint to connect to have the migrated data"
  default     = []
}

##############################################################
########################## target endpoint ###################

variable "dms_target_endpoints" {
  type        = list(any)
  description = "DMS target endpoint to put in the data cames from source "
  default     = []
}

##############################################################
########################## replicatoin task ##################

variable "dms_replication_tasks" {
  type        = list(any)
  description = "replication tasks that will be created"
  default     = []
}

##############################################################
########################## replicatoin task ##################

variable "tags" {
  type        = map(string)
  description = "Resources tag"
  default     = {}
}