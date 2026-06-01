output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "pipeline_role_arn" {
  value = aws_iam_role.pipeline_role.arn
}
