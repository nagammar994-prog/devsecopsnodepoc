output "security_build_name" {
  value = aws_codebuild_project.security_build.name
}

output "zap_build_name" {
  value = aws_codebuild_project.zap_dast.name
}

output "security_build_arn" {
  value = aws_codebuild_project.security_build.arn
}

output "zap_build_arn" {
  value = aws_codebuild_project.zap_dast.arn
}
