# Web Application Firewall v2

resource "aws_wafv2_regex_pattern_set" "invalid_url" {
  name        = "invalid_url"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = "admin"
  }

  regular_expression {
    regex_string = "login"
  }
}

resource "aws_wafv2_web_acl" "waf_iot" {
  name        = "waf_iot"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    action {
      block {}
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.invalid_url.arn
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 1
          type = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "waf-blocked-url-metrics"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "waf-metrics"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "waf_iot_association" {
  resource_arn = aws_lb.iot-web-alb.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_iot.arn
}



