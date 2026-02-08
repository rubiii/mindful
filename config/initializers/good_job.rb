# frozen_string_literal: true

# Good Job configuration
Rails.application.configure do
  config.good_job.preserve_job_records = true
  config.good_job.cleanup_preserved_jobs_before_seconds_ago = 14.days
  config.good_job.cleanup_interval_jobs = 1_000
  config.good_job.cleanup_interval_seconds = 10.minutes
  config.good_job.enable_cron = false
  config.good_job.on_thread_error = ->(exception) { Rails.error.report(exception) }
  config.good_job.retry_on_unhandled_error = false
  config.good_job.dashboard_default_locale = :de
end
