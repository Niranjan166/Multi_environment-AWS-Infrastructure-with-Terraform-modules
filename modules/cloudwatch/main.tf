# Cloudwatch Log Group

resource "aws_cloudwatch_log_group" "ec2" {
    name = "${var.project_name}-${var.environment}-ec2"
    retention_in_days = var.log_retention_days

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-log-group"
    })
}

# cloudwatch metrics filter

resource "aws_cloudwatch_log_metric_filter" "application_errors" {
    name = "${var.project_name}-${var.environment}-error-filter"
    log_group_name = aws_cloudwatch_log_group.ec2.name

    pattern = "ERROR"

    metric_transformation {
      name = "ApplicationErrors"
      namespace = "${var.project_name}-${var.environment}"
      value = "1"
    }
}

# sns topic

resource "aws_sns_topic" "alerts" {
    name = "${var.project_name}-${var.environment}-alerts"

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-alerts"
    })
}

# email subscription

resource "aws_sns_topic_subscription" "email" {
    topic_arn = aws_sns_topic.alerts.arn
    protocol = "email"
    endpoint = var.alert_email
}

# ec2 CPU alarm

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name = "${var.project_name}-${var.environment}-cpu-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilisation"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = var.cpu_threshold
    alarm_description = "Alarm when EC2 CPU exceeds ${var.cpu_threshold}%"

    dimensions = {
      AutoScalingGroupName = var.asg_name
    }

    alarm_actions = [aws_sns_topic.alerts.arn]
    ok_actions = [aws_sns_topic.alerts.arn]

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-ec2-cpu-alarm"
    })
}

# EC2 status check alarm

resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
    alarm_name = "${var.project_name}-${var.environment}-status-check"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "StatusCheckFailed"
    namespace = "AWS/EC2"
    period = 60
    statistic = "Maximum"
    threshold = 1

    alarm_description = "Alarm when EC2 instance status check fails"
    dimensions = {
      AutoScalingGroupName = var.asg_name
    }
    alarm_actions = [aws_sns_topic.alerts.arn]

    tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-status-check-alarm"
  })
}

# RDS CPU Alarm

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
    alarm_name = "${var.project_name}-${var.environment}-rds-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/RDS"
    period = 120
    statistic = "Average"
    threshold = 80

    alarm_description = "Alarm when RDS CPU exceeds 80%"

    dimensions = {
      DBInstanceIdentifier = var.db_instance_identifier
    }

    alarm_actions = [aws_sns_topic.alerts.arn]
    ok_actions = [aws_sns_topic.alerts.arn]

    tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-cpu-alarm"
  })
}

# application error alarm

resource "aws_cloudwatch_metric_alarm" "application_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-application-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApplicationErrors"
  namespace           = "${var.project_name}/${var.environment}"
  period              = 300
  statistic           = "Sum"
  threshold           = 5

  alarm_description = "Alarm when application logs contain too many ERROR entries"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-application-error-alarm"
  })
}
