data "aws_iam_policy_document" "dms_secret_manager_assume_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["dms.us-east-1.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dms_secret_manager_source_endpoint_role_policy" {
  dynamic "statement" {
    for_each =  toset(var.dms_source_endpoints)

    content {
      effect    = "Allow"
      actions   = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [
        statement.value.secrets_manager_arn
      ]
    }
  }
}

data "aws_iam_policy_document" "dms_secret_manager_target_endpoint_role_policy" {
  dynamic "statement" {
    for_each =  toset(var.dms_target_endpoints)

    content {
      effect    = "Allow"
      actions   = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [
        statement.value.secrets_manager_arn
      ]
    }
  }
}