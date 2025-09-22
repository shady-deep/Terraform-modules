resource "aws_iam_role" "role" {
  count                   = var.create_iam_role ? 1 : 0

  name                    = var.iam_role_name
  assume_role_policy      = data.aws_iam_policy_document.trust_policy_document.json
  tags                    = var.tags
}

resource "aws_iam_policy" "role_policy" {
  count   = var.create_iam_role ? 1 : 0
  name    = var.iam_role_policy_name
  policy  = data.aws_iam_policy_document.role_policy_document.json
}

resource "aws_iam_policy" "lambda_function_logging_policy" {
  count       = var.create_logging_policy ? 1 : 0
  name        = "test-${var.env}-lambda-policy"
  description = "Defines the function logging policy"
  policy      = data.aws_iam_policy_document.lambda_function_logging_policy.json

}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  count       = var.create_iam_role ? 1 : 0

  role        = aws_iam_role.role[0].name
  policy_arn  = aws_iam_policy.role_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_function_logging_policy_attach" {
  count       = var.create_iam_role && var.create_logging_policy ? 1 : 0
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.lambda_function_logging_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_function_vpc_access_attach" {
  count       = var.create_iam_role && var.create_logging_policy ? 1 : 0
  role       = aws_iam_role.role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}