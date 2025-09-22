data "aws_iam_policy_document" "trust_policy_document" {
    source_policy_documents = compact([
        var.trust_policy_document 
    ])
}

data "aws_iam_policy_document" "role_policy_document" {
    source_policy_documents = compact([
        var.role_policy_document 
    ])
}

data "aws_iam_policy_document" "lambda_function_logging_policy" {
    source_policy_documents = compact([
        var.logging_role_policy_document 
    ])
}