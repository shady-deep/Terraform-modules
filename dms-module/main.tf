provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "default" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "test-dms-${var.env}-endpoints-kms-key"
  tags = var.tags

}

################################################################################
# Subnet group
################################################################################

resource "aws_dms_replication_subnet_group" "this" {
  count                                = length(var.subnet_groups)

  replication_subnet_group_id          = lookup(var.subnet_groups[count.index], "subnet_group_name", "test-subnet-group-${var.env}-${count.index}")
  replication_subnet_group_description = lookup(var.subnet_groups[count.index], "subnet_group_description", "test-subnet-group-${var.env}-${count.index}")
  subnet_ids                           = lookup(var.subnet_groups[count.index], "subnet_group_subnet_ids", null)

  tags = var.tags

}

################################################################################
# Instance
################################################################################

resource "aws_dms_replication_instance" "this" {
  count                        = length(var.replication_instances)

  allocated_storage            = lookup(var.replication_instances[count.index], "instance_allocated_storage", "20")
  auto_minor_version_upgrade   = lookup(var.replication_instances[count.index], "instance_auto_minor_version_upgrade", true)
  allow_major_version_upgrade  = lookup(var.replication_instances[count.index], "instance_allow_major_version_upgrade", true)
  apply_immediately            = lookup(var.replication_instances[count.index], "instance_apply_immediately", true)
  availability_zone            = lookup(var.replication_instances[count.index], "instance_availability_zone", "us-east-1a")
  engine_version               = lookup(var.replication_instances[count.index], "instance_engine_version", "put the latest one")
  kms_key_arn                  = var.create_kms_key ? aws_kms_key.default[0].arn : lookup(var.replication_instances[count.index], "instance_kms_key_arn", null)
  multi_az                     = lookup(var.replication_instances[count.index], "instance_multi_az", false)
  preferred_maintenance_window = lookup(var.replication_instances[count.index], "preferred_maintenance_window", null)
  replication_instance_class   = lookup(var.replication_instances[count.index], "instance_class", "choose your own")
  replication_instance_id      = lookup(var.replication_instances[count.index], "instance_id", "test")
  vpc_security_group_ids       = lookup(var.replication_instances[count.index], "instance_vpc_security_group_ids", null)
  replication_subnet_group_id  = length(var.subnet_groups) > 0 ? aws_dms_replication_subnet_group.this[var.replication_instances[count.index].subnet_group_index].id : lookup(var.replication_instances[count.index], "replication_subnet_group_id", null)

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]

}

################################################################################
# Endpoints
################################################################################

resource "aws_dms_endpoint" "source" {
  count                       = length(var.dms_source_endpoints)

  server_name                     = lookup(var.dms_source_endpoints[count.index], "host", null)
  username                        = lookup(var.dms_source_endpoints[count.index], "username", null)
  password                        = lookup(var.dms_source_endpoints[count.index], "pass", null)
  database_name                   = lookup(var.dms_source_endpoints[count.index], "db_name", null)
  endpoint_id                     = lookup(var.dms_source_endpoints[count.index], "endpoint_id", "test-${var.env}-${count.index}-source-endpoint")
  endpoint_type                   = "source"
  engine_name                     = lookup(var.dms_source_endpoints[count.index], "engine", null)
  extra_connection_attributes     = lookup(var.dms_source_endpoints[count.index], "extra_connection_attributes", null)
  kms_key_arn                     = var.create_kms_key ? aws_kms_key.default[0].arn : lookup(var.dms_source_endpoints[count.index], "kms_key_arn", null)
  port                            = lookup(var.dms_source_endpoints[count.index], "port", null)
  ssl_mode                        = lookup(var.dms_source_endpoints[count.index], "ssl_mode", "none")
  secrets_manager_arn             = lookup(var.dms_source_endpoints[count.index], "secrets_manager_arn", null)
  secrets_manager_access_role_arn = aws_iam_role.replication_task_source_endpoints_role[count.index].arn

  tags = var.tags

}

resource "aws_dms_endpoint" "target" {
  count                       = length(var.dms_target_endpoints)

  server_name                     = lookup(var.dms_target_endpoints[count.index], "host", null)
  username                        = lookup(var.dms_target_endpoints[count.index], "username", null)
  password                        = lookup(var.dms_target_endpoints[count.index], "pass", null)
  database_name                   = lookup(var.dms_target_endpoints[count.index], "db_name", null)
  endpoint_id                     = lookup(var.dms_target_endpoints[count.index], "endpoint_id", "test-${var.env}-${count.index}-target-endpoint")
  endpoint_type                   = "target"
  engine_name                     = lookup(var.dms_target_endpoints[count.index], "engine", null)
  extra_connection_attributes     = lookup(var.dms_target_endpoints[count.index], "extra_connection_attributes", null)
  kms_key_arn                     = var.create_kms_key ? aws_kms_key.default[0].arn : lookup(var.dms_target_endpoints[count.index], "kms_key_arn", null)
  port                            = lookup(var.dms_target_endpoints[count.index], "port", null)
  ssl_mode                        = lookup(var.dms_target_endpoints[count.index], "ssl_mode", "none")
  secrets_manager_arn             = lookup(var.dms_source_endpoints[count.index], "secrets_manager_arn", null)
  secrets_manager_access_role_arn = aws_iam_role.replication_task_target_endpoints_role[count.index].arn

  tags = var.tags

}

################################################################################
# Replication task
################################################################################

resource "aws_dms_replication_task" "tasks" {
  count                     = length(var.dms_replication_tasks)

  migration_type            = lookup(var.dms_replication_tasks[count.index], "migration_type", "full-load-and-cdc or choose your own")
  replication_instance_arn  = length(var.replication_instances) > 0 ? aws_dms_replication_instance.this[var.dms_replication_tasks[count.index].replication_instance_index].replication_instance_arn : lookup(var.dms_replication_tasks[count.index], "replication_instance_arn", null)
  replication_task_id       = lookup(var.dms_replication_tasks[count.index], "replication_task_id", "test--${var.env}")
  replication_task_settings = jsonencode(
            {
              BeforeImageSettings               = null
              ChangeProcessingDdlHandlingPolicy = {
                  HandleSourceTableAltered   = true
                  HandleSourceTableDropped   = true
                  HandleSourceTableTruncated = true
              }
              ChangeProcessingTuning            = {
                  BatchApplyMemoryLimit         = 500
                  BatchApplyPreserveTransaction = true
                  BatchApplyTimeoutMax          = 30
                  BatchApplyTimeoutMin          = 1
                  BatchSplitSize                = 0
                  CommitTimeout                 = 1
                  MemoryKeepTime                = 60
                  MemoryLimitTotal              = 1024
                  MinTransactionSize            = 1000
                  StatementCacheSize            = 50
              }
              CharacterSetSettings              = null
              ControlTablesSettings             = {
                  ControlSchema                 = ""
                  FullLoadExceptionTableEnabled = false
                  HistoryTableEnabled           = false
                  HistoryTimeslotInMinutes      = 5
                  StatusTableEnabled            = false
                  SuspendedTablesTableEnabled   = false
              }
              ErrorBehavior                     = {
                  ApplyErrorDeletePolicy                      = "IGNORE_RECORD"
                  ApplyErrorEscalationCount                   = 0
                  ApplyErrorEscalationPolicy                  = "LOG_ERROR"
                  ApplyErrorFailOnTruncationDdl               = false
                  ApplyErrorInsertPolicy                      = "LOG_ERROR"
                  ApplyErrorUpdatePolicy                      = "LOG_ERROR"
                  DataErrorEscalationCount                    = 0
                  DataErrorEscalationPolicy                   = "SUSPEND_TABLE"
                  DataErrorPolicy                             = "LOG_ERROR"
                  DataTruncationErrorPolicy                   = "LOG_ERROR"
                  FailOnNoTablesCaptured                      = false
                  FailOnTransactionConsistencyBreached        = false
                  FullLoadIgnoreConflicts                     = true
                  RecoverableErrorCount                       = -1
                  RecoverableErrorInterval                    = 5
                  RecoverableErrorStopRetryAfterThrottlingMax = false
                  RecoverableErrorThrottling                  = true
                  RecoverableErrorThrottlingMax               = 1800
                  TableErrorEscalationCount                   = 0
                  TableErrorEscalationPolicy                  = "STOP_TASK"
                  TableErrorPolicy                            = "SUSPEND_TABLE"
              }
              FailTaskWhenCleanTaskResourceFailed = false
              FullLoadSettings                  = {
                  CommitRate                      = 10000
                  CreatePkAfterFullLoad           = false
                  MaxFullLoadSubTasks             = 1
                  StopTaskCachedChangesApplied    = false
                  StopTaskCachedChangesNotApplied = false
                  TargetTablePrepMode             = "TRUNCATE_BEFORE_LOAD"
                  TransactionConsistencyTimeout   = 600
              }
              Logging                           = {
                  EnableLogging       = true
                  LogComponents       = [
                      {
                          Id       = "TRANSFORMATION"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "SOURCE_UNLOAD"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "IO"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "TARGET_LOAD"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "PERFORMANCE"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "SOURCE_CAPTURE"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "SORTER"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "REST_SERVER"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "VALIDATOR_EXT"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "TARGET_APPLY"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "TASK_MANAGER"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "TABLES_MANAGER"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "METADATA_MANAGER"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "FILE_FACTORY"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "COMMON"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "ADDONS"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "DATA_STRUCTURE"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "COMMUNICATION"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                      {
                          Id       = "FILE_TRANSFER"
                          Severity = "LOGGER_SEVERITY_DEFAULT"
                      },
                    ]
              }
              LoopbackPreventionSettings        = null
              PostProcessingRules               = null
              StreamBufferSettings              = {
                  CtrlStreamBufferSizeInMB = 5
                  StreamBufferCount        = 3
                  StreamBufferSizeInMB     = 8
              }
              TTSettings                        = {
                EnableTT          = false
                TTRecordSettings  = null
                TTS3Settings      = null
              }
              TargetMetadata                    = {
                  BatchApplyEnabled            = false
                  FullLobMode                  = false
                  InlineLobMaxSize             = 0
                  LimitedSizeLobMode           = true
                  LoadMaxFileSize              = 0
                  LobChunkSize                 = 64
                  LobMaxSize                   = 32
                  ParallelApplyBufferSize      = 0
                  ParallelApplyQueuesPerThread = 0
                  ParallelApplyThreads         = 0
                  ParallelLoadBufferSize       = 0
                  ParallelLoadQueuesPerThread  = 0
                  ParallelLoadThreads          = 0
                  SupportLobs                  = true
                  TargetSchema                 = "put your schema"
                  TaskRecoveryTableEnabled     = false
              }

              depends_on = [aws_dms_replication_instance.this]
          }
        )
  source_endpoint_arn       = length(var.dms_source_endpoints) > 0 ? aws_dms_endpoint.source[var.dms_replication_tasks[count.index].source_endpoint_index].endpoint_arn : lookup(var.dms_replication_tasks[count.index], "source_endpoint_arn", null)
  target_endpoint_arn       = length(var.dms_target_endpoints) > 0 ? aws_dms_endpoint.target[var.dms_replication_tasks[count.index].target_endpoint_index].endpoint_arn : lookup(var.dms_replication_tasks[count.index], "target_endpoint_arn", null)
  table_mappings            = lookup(var.dms_replication_tasks[count.index], "table_mappings", null)

  tags = var.tags
}


################################################################################
# IAM
################################################################################

resource "aws_iam_role" "replication_task_source_endpoints_role" {
  count = length(var.dms_source_endpoints)

  name = lookup(var.dms_source_endpoints[count.index], "endpoint_id", null) != null ? "${var.dms_source_endpoints[count.index].endpoint_id}-role-${var.env}" : "test-${count.index}-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.dms_secret_manager_assume_role_policy.json
  tags = var.tags
}

resource "aws_iam_policy" "replication_task_source_endpoints_policy" {
  count = length(var.dms_source_endpoints)

  name        = lookup(var.dms_source_endpoints[count.index], "endpoint_id", null) != null ? "${var.dms_source_endpoints[count.index].endpoint_id}-policy-${var.env}" : "test-${count.index}-policy-${var.env}"
  path        = "/"
  description = "test-role-policy-${var.env}"

  policy = data.aws_iam_policy_document.dms_secret_manager_source_endpoint_role_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "replication_task_source_endpoints_role_policy_attachment" {
  count = length(var.dms_source_endpoints)

  role       = aws_iam_role.replication_task_source_endpoints_role[count.index].name
  policy_arn = aws_iam_policy.replication_task_source_endpoints_policy[count.index].arn
}

resource "aws_iam_role" "replication_task_target_endpoints_role" {
  count = length(var.dms_target_endpoints)

  name = lookup(var.dms_target_endpoints[count.index], "endpoint_id", null) != null ? "${var.dms_target_endpoints[count.index].endpoint_id}-role-${var.env}" : "test-${count.index}-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.dms_secret_manager_assume_role_policy.json
  tags = var.tags
}

resource "aws_iam_policy" "replication_task_target_endpoints_policy" {
  count = length(var.dms_target_endpoints)

  name        = lookup(var.dms_target_endpoints[count.index], "endpoint_id", null) != null ? "${var.dms_target_endpoints[count.index].endpoint_id}-policy-${var.env}" : "test-${count.index}-policy-${var.env}"
  path        = "/"
  description = "test-role-policy-${var.env}"

  policy = data.aws_iam_policy_document.dms_secret_manager_target_endpoint_role_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "replication_task_target_endpoints_role_policy_attachment" {
  count = length(var.dms_target_endpoints)

  role       = aws_iam_role.replication_task_target_endpoints_role[count.index].name
  policy_arn = aws_iam_policy.replication_task_target_endpoints_policy[count.index].arn
}

resource "aws_iam_role" "dms-vpc-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_secret_manager_assume_role_policy.json
  name               = "dms-vpc-role"
}

resource "aws_iam_role_policy_attachment" "dms-vpc-role-AmazonDMSVPCManagementRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms-vpc-role.name
}

resource "aws_iam_role" "dms-cloudwatch-logs-role" {
  assume_role_policy = data.aws_iam_policy_document.dms_secret_manager_assume_role_policy.json
  name               = "dms-cloudwatch-logs-role"
}

resource "aws_iam_role_policy_attachment" "dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
  role       = aws_iam_role.dms-cloudwatch-logs-role.name
}