resource "aws_security_group" "default" {
  count = var.create_security_group ? 1 : 0
  name   = "${var.env}-lambda-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["10.0.0.0/8"]
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "lambda_function" {
  count         = var.create_lambda_function ? 1 : 0
  function_name = "test-lambda-${var.env}"
  role          = aws_iam_role.role[0].arn
  handler       = var.lambda_function_handler
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  memory_size = var.lambda_function_memory_size
  runtime     = var.lambda_function_runtime
  timeout     = var.lambda_function_timeout
  tags        = var.tags

  dynamic "environment" {
    for_each = length("${keys(var.environment_variables)}") == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  vpc_config {
    subnet_ids = split(
      ",",
      join(",", data.terraform_remote_state.vpc.outputs.private_subnets),
    )
    security_group_ids = [aws_security_group.default[0].id]
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  count             = var.create_event_invocation ? 1 : 0
  event_source_arn  = var.kinesis_arn
  function_name     = aws_lambda_function.lambda_function[0].arn
  starting_position = var.starting_position
}
