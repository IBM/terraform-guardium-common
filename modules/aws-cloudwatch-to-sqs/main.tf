# SQS Queue for log events
resource "aws_sqs_queue" "guardium_q" {
  name = "${var.name_prefix}-queue"
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "guardium_q" {
  statement {
    sid    = "First"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "sqs:ListQueues",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [aws_sqs_queue.guardium_q.arn]
  }
}

resource "aws_sqs_queue_policy" "guardium_q" {
  queue_url = aws_sqs_queue.guardium_q.id
  policy    = data.aws_iam_policy_document.guardium_q.json

  lifecycle {
    create_before_destroy = true
  }
}

# Lambda function to process logs
data "aws_iam_policy_document" "sqs_lambda_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sqs_lambda_role" {
  name               = "${var.name_prefix}-CloudWatch-to-SQS-Lambda-Role"
  assume_role_policy = data.aws_iam_policy_document.sqs_lambda_role.json
  tags               = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy" "AmazonSQSFullAccess" { name  = "AmazonSQSFullAccess" }

data "aws_iam_policy" "CloudWatchLogsFullAccess" { name  = "CloudWatchLogsFullAccess" }

data "aws_iam_policy" "CloudWatchEventsFullAccess" { name  = "CloudWatchEventsFullAccess" }

resource "aws_iam_policy_attachment" "sqs_lambda_role_sqs" {
  name       = "${var.name_prefix}_sqs_lambda_role_sqs-attachment"
  policy_arn = data.aws_iam_policy.AmazonSQSFullAccess.arn
  roles      = [aws_iam_role.sqs_lambda_role.name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "sqs_lambda_role_logs" {
  name       = "${var.name_prefix}_sqs_lambda_role_logs-attachment"
  policy_arn = data.aws_iam_policy.CloudWatchLogsFullAccess.arn
  roles      = [aws_iam_role.sqs_lambda_role.name]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy_attachment" "sqs_lambda_role_events" {
  name       = "${var.name_prefix}_sqs_lambda_role_events-attachment"
  policy_arn = data.aws_iam_policy.CloudWatchEventsFullAccess.arn
  roles      = [aws_iam_role.sqs_lambda_role.name]

  lifecycle {
    create_before_destroy = true
  }
}

data "archive_file" "sqs_lambda" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = "${path.module}/files/function.zip"
}

resource "aws_lambda_function" "guardium" {
  function_name    = "${var.name_prefix}-Export-CloudWatch-Logs-To-SQS-${var.datastore_type}"
  role             = aws_iam_role.sqs_lambda_role.arn
  handler          = var.handler
  filename         = data.archive_file.sqs_lambda.output_path
  source_code_hash = data.archive_file.sqs_lambda.output_base64sha256
  runtime          = var.lambda_runtime
  environment {
    variables = {
      GROUP_NAME = var.log_group
      QUEUE_NAME = aws_sqs_queue.guardium_q.id
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_event_rule" "guardium" {
  name                = "${var.name_prefix}-cloudwatchToSqs"
  description         = "Capture cloudwatch events"
  schedule_expression = "rate(2 minutes)"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_event_target" "guardium" {
  target_id = var.name_prefix
  rule      = aws_cloudwatch_event_rule.guardium.name
  arn       = aws_lambda_function.guardium.arn

  depends_on = [aws_cloudwatch_event_rule.guardium]

  lifecycle {
    create_before_destroy = true
  }
}

# Add Lambda permission to allow CloudWatch Events to invoke the function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.guardium.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardium.arn

  lifecycle {
    create_before_destroy = true
    # Ignore changes to prevent permission errors during destroy
    ignore_changes = [
      function_name,
      source_arn
    ]
  }
}