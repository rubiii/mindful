# Background Jobs with Good Job

This document covers patterns and best practices for working with background jobs using [Good Job](https://github.com/bensheldon/good_job) in this application.

## Overview

Good Job is a multithreaded, Postgres-based ActiveJob backend for Ruby on Rails. It's configured to run in async mode for production deployments, meaning jobs execute in-process without requiring a separate worker process.

## Dashboard

The Good Job dashboard is available at `/admin/good_job` and requires admin authentication.

## Creating a Job

Generate a new job using Rails generators:

```bash
bin/rails generate job ProcessData
```

This creates `app/jobs/process_data_job.rb`:

```ruby
class ProcessDataJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
```

## Queue Priority

Organize jobs by priority using different queues:

```ruby
class UrgentJob < ApplicationJob
  queue_as :urgent
  
  def perform
    # Time-sensitive work
  end
end

class LowPriorityJob < ApplicationJob
  queue_as :low_priority
  
  def perform
    # Background maintenance work
  end
end
```

Configure queue priorities in `config/initializers/good_job.rb`:

```ruby
config.good_job.queues = 'urgent:4;default:2;low_priority:1'
```

## Error Handling and Retries

Good Job automatically retries failed jobs. Customize retry behavior:

```ruby
class RetryableJob < ApplicationJob
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  discard_on ActiveJob::DeserializationError
  
  def perform
    # Work that might fail
  end
end
```

## Idempotency

Always design jobs to be idempotent (safe to run multiple times):

```ruby
class UpdateUserStatsJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    
    # Use database operations that are idempotent
    user.update_columns(
      total_posts: user.posts.count,
      last_calculated_at: Time.current
    )
  end
end
```

## Scheduled Jobs (Cron)

Configure recurring jobs in `config/initializers/good_job.rb`:

```ruby
config.good_job.cron = {
  daily_cleanup: {
    cron: "0 2 * * *", # 2 AM every day
    class: "DailyCleanupJob"
  },
  hourly_sync: {
    cron: "0 * * * *", # Every hour
    class: "HourlySyncJob"
  }
}
```

## Batching Jobs

Process multiple items efficiently using batches:

```ruby
class BulkProcessJob < ApplicationJob
  def perform(item_ids)
    Item.where(id: item_ids).find_each do |item|
      process_item(item)
    end
  end
  
  private
  
  def process_item(item)
    # Process single item
  end
end

# Enqueue in batches of 100
User.ids.each_slice(100) do |batch|
  BulkProcessJob.perform_later(batch)
end
```

## Testing Jobs

### Unit Testing

Test job logic in isolation:

```ruby
require "test_helper"

class ProcessDataJobTest < ActiveJob::TestCase
  test "processes data correctly" do
    user = create(:user)
    
    ProcessDataJob.perform_now(user.id)
    
    user.reload
    assert user.processed?
  end
  
  test "handles missing records gracefully" do
    assert_nothing_raised do
      ProcessDataJob.perform_now(999999)
    end
  end
end
```

### Testing Job Enqueuing

Verify jobs are enqueued correctly:

```ruby
test "enqueues job on user creation" do
  assert_enqueued_with(job: WelcomeEmailJob) do
    create(:user)
  end
end

test "enqueues job with correct arguments" do
  user = create(:user)
  
  assert_enqueued_with(job: ProcessDataJob, args: [user.id]) do
    user.trigger_processing
  end
end
```

### System Tests with Jobs

In system tests, jobs run inline by default (test environment uses `:inline` adapter):

```ruby
test "user sees confirmation after background processing" do
  sign_in create(:user)
  
  visit data_path
  click_on "Process Data"
  
  # Job runs immediately in test
  assert_text "Processing complete"
end
```

## Performance Considerations

### Avoid N+1 Queries

```ruby
# Bad
class NotifyUsersJob < ApplicationJob
  def perform(user_ids)
    user_ids.each do |id|
      user = User.find(id) # N+1 query
      UserMailer.notification(user).deliver_now
    end
  end
end

# Good
class NotifyUsersJob < ApplicationJob
  def perform(user_ids)
    User.where(id: user_ids).find_each do |user|
      UserMailer.notification(user).deliver_now
    end
  end
end
```

### Break Down Large Jobs

Split large jobs into smaller ones:

```ruby
class ProcessAllUsersJob < ApplicationJob
  def perform
    User.find_each do |user|
      ProcessSingleUserJob.perform_later(user.id)
    end
  end
end

class ProcessSingleUserJob < ApplicationJob
  def perform(user_id)
    # Process one user
  end
end
```

### Use perform_all_later for Bulk Enqueuing

More efficient than individual `perform_later` calls:

```ruby
# Good - single database write
jobs = users.map { |user| ProcessUserJob.new(user.id) }
ActiveJob.perform_all_later(jobs)

# Less efficient - multiple database writes
users.each { |user| ProcessUserJob.perform_later(user.id) }
```

## Monitoring and Debugging

### View Job Status

Check job status in the dashboard at `/admin/good_job` or via Rails console:

```ruby
# Check queued jobs
GoodJob::Job.queued.count

# Check running jobs
GoodJob::Job.running.count

# Check failed jobs
GoodJob::Job.finished.where.not(error: nil)

# Find specific job
job = GoodJob::Job.find_by(active_job_id: "job-uuid")
```

### Cleanup Old Jobs

Good Job automatically cleans up finished jobs. Configure cleanup in the initializer:

```ruby
config.good_job.cleanup_preserved_jobs_before_seconds_ago = 7.days
config.good_job.cleanup_discarded_jobs = true
```

## Common Patterns

### Send Email Asynchronously

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome!")
  end
end

# In controller or model
UserMailer.welcome_email(user).deliver_later
```

### Process Uploaded Files

```ruby
class ProcessUploadJob < ApplicationJob
  def perform(upload_id)
    upload = Upload.find(upload_id)
    
    upload.update(status: :processing)
    
    begin
      process_file(upload.file)
      upload.update(status: :completed)
    rescue => e
      upload.update(status: :failed, error_message: e.message)
      raise
    end
  end
  
  private
  
  def process_file(file)
    # File processing logic
  end
end
```

### Rate Limiting with Delays

```ruby
class ApiSyncJob < ApplicationJob
  def perform(page: 1)
    response = ExternalApi.fetch(page: page)
    process_response(response)
    
    # Continue to next page after delay
    if response.has_next_page?
      ApiSyncJob.set(wait: 1.second).perform_later(page: page + 1)
    end
  end
end
```

## Migration from Solid Queue

If migrating from Solid Queue, the main differences are:

1. **Dashboard**: Good Job has a web UI at `/admin/good_job`
2. **Polling**: Good Job uses `LISTEN/NOTIFY` for immediate job pickup
3. **Recurring Jobs**: Use `config.good_job.cron` instead of Solid Queue's scheduler
4. **Execution Mode**: Configured via `config.good_job.execution_mode`

Job code remains the same - both use ActiveJob interface.