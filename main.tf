resource "newrelic_alert_policy" "test-tt1" {
  name                = "raj1"
  incident_preference = "PER_CONDITION"
}

resource "newrelic_nrql_alert_condition" "foo123" {
  count                           = length(var.rj_conditions)
  account_id                      = 4439970
  policy_id                       = newrelic_alert_policy.test-tt1.id
  type                            = var.rj_conditions[count.index].type
  name                            = var.rj_conditions[count.index].name
  enabled                         = true
  violation_time_limit_seconds    = var.rj_conditions[count.index].violation_time_limit_seconds
  fill_option                     = var.rj_conditions[count.index].fill_option
  fill_value                      = var.rj_conditions[count.index].fill_value
  aggregation_window              = var.rj_conditions[count.index].aggregation_window
  aggregation_method              = var.rj_conditions[count.index].aggregation_method
  aggregation_delay               = var.rj_conditions[count.index].aggregation_delay
  expiration_duration             = var.rj_conditions[count.index].expiration_duration
  open_violation_on_expiration    = true
  close_violations_on_expiration  = true
  slide_by                        = var.rj_conditions[count.index].slide_by
  baseline_direction              = "upper_only"

  nrql {
    query = var.rj_conditions[count.index].query
  }

  critical {
    operator              = "above"
    threshold             = var.rj_conditions[count.index].thresholdC
    threshold_duration    = var.rj_conditions[count.index].threshold_durationC
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = var.rj_conditions[count.index].thresholdW
    threshold_duration    = var.rj_conditions[count.index].threshold_durationW
    threshold_occurrences = "ALL"
  }
}

resource "newrelic_notification_destination" "foo" {
  account_id = "4439970"
  name       = "email-example"
  type       = "EMAIL"

  property {
    key   = "email"
    value = "raj0572.be20@chitkara.edu.in"
  }
}

resource "newrelic_notification_channel" "foo1" {
  account_id    = "4439970"
  name          = "email-example"
  type          = "EMAIL"
  destination_id = newrelic_notification_destination.foo.id
  product       = "IINT"

  property {
    key   = "payload"
    value = "{}"
    label = "Payload Template"
  }
}

resource "newrelic_workflow" "foo-workflow" {
  name                  = "workflow-example1"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator  = "EXACTLY_MATCHES"
      values    = [newrelic_alert_policy.test-tt1.id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.foo1.id
  }
}

resource "newrelic_alert_muting_rule" "muting_rule" {
  name        = "Example Muting Rule"
  enabled     = true
  description = "muting rule test."
  condition {
    conditions {
      attribute = "accountId"
      operator  = "EQUALS"
      values    = ["APM"]
    }
    operator = "AND"
  }
  schedule {
    start_time          = "2024-08-01T15:30:00"
    end_time            = "2024-08-01T16:30:00"
    time_zone           = "Asia/Kolkata"
    repeat              = "WEEKLY"
    weekly_repeat_days  = ["THURSDAY"]
    repeat_count        = 42
  }
}
