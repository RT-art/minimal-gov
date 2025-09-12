variable "log_group_name" {
  type    = string
  default = "/central/vpc-flow-logs"
}

variable "retention_in_days" {
  type    = number
  default = 90
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  tags = {
    Purpose = "Centralized VPC Flow Logs"
  }
}

resource "aws_cloudwatch_log_resource_policy" "flowlogs" {
  policy_name = "Allow-VPC-FlowLogs"
  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      }
    ]
  })
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}
