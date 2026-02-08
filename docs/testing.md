# Testing Guidelines

This document outlines testing conventions and best practices for the Mindful application.

## Overview

We use **Minitest** as our testing framework with the following tools:
- **Capybara** for system/integration tests
- **FactoryBot** for test data
- **SimpleCov** for code coverage tracking
- **axe-core** (via capybara-accessible) for accessibility testing

## Test Organization

### Test Types

```
test/
├── channels/         # Action Cable channel tests
├── controllers/      # Controller unit tests
├── factories/        # FactoryBot definitions
├── fixtures/         # Static test data (use sparingly, prefer factories)
├── helpers/          # View helper tests
├── integration/      # Integration tests (multi-request flows)
├── jobs/            # Background job tests
├── mailers/         # Mailer tests
├── models/          # Model unit tests
├── policies/        # Pundit policy tests
├── system/          # End-to-end browser tests
└── test_helper.rb   # Global test configuration
```

### When to Use Each Test Type

**Unit Tests (models, helpers, jobs):**
- Fast, isolated tests
- Test single methods or small units of logic
- No database queries when possible (use mocks)
- Example: validations, calculations, business logic

**Controller Tests:**
- Test controller actions in isolation
- Verify correct responses, redirects, and status codes
- Check authorization and authentication
- Don't test complex UI interactions (use system tests)

**Integration Tests:**
- Test multi-request workflows
- Verify session handling and state changes
- Test API endpoints
- Example: complete checkout flow, multi-step forms

**System Tests:**
- Full browser-based end-to-end tests
- Test complete user workflows
- Verify JavaScript interactions
- Test accessibility with `assert_accessible`
- Most comprehensive but slowest

## Test Structure

### Organizing Tests with `describe`, `context`, and `it`

We use Minitest::Spec DSL for test organization. Use `describe` and `context` blocks with `it` for individual test cases:

```ruby
class UserTest < ActiveSupport::TestCase
  context "validations" do
    it "does not save without email" do
      user = User.new
      assert_not user.save
      assert_includes user.errors[:email], "can't be blank"
    end
    
    it "saves with valid attributes" do
      user = build(:user)
      assert user.save
    end
  end
  
  describe "#account_state" do
    it "returns active for normal user" do
      user = create(:user)
      assert_equal :active, user.account_state
    end
    
    it "returns invitation_pending for invited user" do
      user = create(:user, invitation_token: "abc123")
      assert_equal :invitation_pending, user.account_state
    end
  end
  
  describe ".filter_by_role" do
    it "filters users by admin role" do
      admin = create(:user, :admin)
      regular = create(:user)
      
      result = User.filter_by_role(:admin)
      assert_includes result, admin
      assert_not_includes result, regular
    end
  end
end
```

**When to use:**
- `describe "#method"` - Group tests for instance methods (e.g., `describe "#save"`)
- `describe ".class_method"` - Group tests for class methods (e.g., `describe ".filter_by_role"`)
- `context "description"` - Group tests by state or condition (e.g., `context "when user is admin"`)
- `it "description"` - Define individual test cases (replaces `test "description"`)

**Setup and Teardown:**
- Use `before` blocks for setup (runs before each test)
- Use `after` blocks for teardown (runs after each test)
- These replace `setup` and `teardown` methods (though those still work)

**Benefits:**
- Built-in Minitest::Spec DSL (no custom code)
- Better test organization and readability
- Clear test output showing nested structure (`UserTest::AccountStateTest#it_returns_active_for_normal_user`)
- Shared setup within blocks using `before`
- Easier to understand which method or scenario is being tested

**For simple test files** with only a few tests, a flat structure with `it` is fine:

```ruby
class SimpleHelperTest < ActiveSupport::TestCase
  it "formats date correctly" do
    # ...
  end
  
  it "handles nil gracefully" do
    # ...
  end
end
```

### Standard Minitest Assertions

Use standard Minitest assertions within `it` blocks:

```ruby
class UserTest < ActiveSupport::TestCase
  it "does not save user without email" do
    user = User.new
    assert_not user.save
    assert_includes user.errors[:email], "can't be blank"
  end

  it "creates user with valid attributes" do
    user = build(:user)
    assert user.save
    assert_equal "user@example.com", user.email
  end
end
```

**Note:** We use standard Minitest assertions (`assert`, `assert_equal`, `assert_includes`, etc.), not RSpec-style matchers. The Spec DSL only provides the organizational structure (`describe`, `context`, `it`), not the assertion syntax.

### Test Naming

- Use descriptive names that explain the scenario
- Write in present tense without "should" (the `it` block implies assertion)
- Include context when relevant

```ruby
# Good
it "sends welcome email after user signs up"
it "allows admin to delete any user"
it "returns 404 when post not found"

# Avoid
it "user test"
it "works"
it "test 1"
```

## FactoryBot Patterns

### Defining Factories

Keep factories in `test/factories/`. Use traits for variations:

```ruby
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { "password123" }
    confirmed_at { Time.current }

    trait :admin do
      admin { true }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end
  end
end
```

### Using Factories in Tests

```ruby
# Build (don't save to database)
user = build(:user)

# Create (save to database)
user = create(:user)

# With traits
admin = create(:user, :admin)
unconfirmed_user = create(:user, :unconfirmed)

# With overrides
user = create(:user, email: "specific@example.com")

# Create multiple
users = create_list(:user, 5)

# Attributes hash without saving
attrs = attributes_for(:user)
```

### Factory Best Practices

1. **Use `build` when possible** - faster, no database hit
2. **Use traits for variations** - keeps factories DRY
3. **Avoid complex associations** - create them explicitly in tests when needed
4. **Use sequences for unique values** - emails, usernames, etc.
5. **Keep factories minimal** - only required attributes by default

## System Test Patterns

### System Test Helpers

We provide a comprehensive set of helpers organized into modules in `test/support/system_test_helpers/` to make tests more readable and maintainable. These helpers are automatically included in all system tests via `ApplicationSystemTestCase`.

**Helper modules:**
- `AuthenticationHelpers` - Sign in/out functionality
- `ModalHelpers` - Modal interactions
- `TurboStreamHelpers` - Turbo Stream waiting
- `ConfirmationHelpers` - Confirmation dialogs
- `PageLoadingHelpers` - Page load waiting and safe counting
- `AuthorizationHelpers` - Authorization assertions
- `CrudHelpers` - Common CRUD workflows

#### Authentication Helpers

```ruby
# Sign in as a user (with optional navigation)
sign_in_as @admin
sign_in_as @admin, visit_path: admin_users_path

# Sign out
sign_out
```

#### Modal Helpers

```ruby
# Open a modal
open_modal "Add User"

# Fill and submit a form within a modal
submit_modal_form(button_text: "Create User") do
  fill_in "Email", with: "test@example.com"
  select "English", from: "Language"
end

# Wait for modal to close
wait_for_modal_to_close
wait_for_modal_to_close modal_id: "#confirm-modal"

# Close modal manually (for cleanup)
close_modal
close_modal button_text: "Close"
```

#### Turbo Stream Helpers

```ruby
# Wait for flash message
wait_for_flash "User was created"

# Wait for Turbo Stream to complete
wait_for_turbo_stream success_message: "User was created"
wait_for_turbo_stream modal_id: "#modal"
wait_for_turbo_stream success_message: "Saved", modal_id: "#modal"
```

#### CRUD Workflow Helpers

```ruby
# Open edit modal for a record
open_edit_modal_for user.id
open_edit_modal_for post.id, record_type: "post"

# Delete a record with confirmation
delete_record user.id
delete_record user.id, success_message: "User was deleted"
delete_record post.id, record_type: "post"
```

#### Page Loading Helpers

```ruby
# Wait for page content before using non-waiting methods
wait_for_page_load content: "admin@example.com"
wait_for_page_load selector: "tbody tr"

# Count table rows safely
count = count_table_rows
count = count_table_rows selector: ".user-row"
count = count_table_rows wait_for_content: "admin@example.com"
```

#### Authorization Helpers

```ruby
# Assert unauthorized access
assert_unauthorized
assert_unauthorized "Access denied"

# Assert requires sign in
assert_requires_sign_in
```

### Basic Structure

```ruby
class Admin::UsersTest < ApplicationSystemTestCase
  setup do
    @admin = create(:user, :admin)
  end

  test "should list all users" do
    users = create_list(:user, 3)
    sign_in_as @admin, visit_path: admin_users_path

    users.each do |user|
      assert_text user.email
    end
  end

  test "should create new user" do
    sign_in_as @admin, visit_path: admin_users_path
    
    open_modal "Add User"
    
    submit_modal_form(button_text: "Create User") do
      fill_in "Email", with: "newuser@example.com"
      select "English", from: "Language"
    end

    wait_for_turbo_stream success_message: "User was created", modal_id: "#modal"
    assert_text "newuser@example.com"
  end
end
```

### Scoping with `within`

Always use `within` to scope actions to specific parts of the UI:

```ruby
# Good - scoped to specific modal
within "#edit-user-modal" do
  fill_in "Email", with: "updated@example.com"
  click_on "Save"
end

# Avoid - ambiguous, could click wrong button
fill_in "Email", with: "updated@example.com"
click_on "Save"
```

### Waiting for Elements

**Never use `sleep`** - Capybara has automatic waiting:

```ruby
# Good - Capybara waits automatically
assert_text "Profile updated"
assert_selector ".success-message"

# If you need explicit waiting (rare - only for genuinely slow operations)
assert_selector "#loading-spinner", visible: false, wait: 5

# Avoid
sleep 2
assert_text "Profile updated"
```

### Waiting for Dynamic Content

**Golden Rule: Use Capybara's automatic waiting - never add explicit waits unless absolutely necessary**

Capybara methods like `assert_text`, `assert_selector`, `find`, `click_on` automatically wait for elements. Use these before non-waiting methods like `all()`.

#### Pattern: Counting Elements After Turbo Stream Updates

```ruby
# ❌ BAD - all() doesn't wait, causes race conditions
visit admin_users_path
count = all("tbody tr").count

# ✅ GOOD - assert known content first, then count
visit admin_users_path
assert_text user.email  # Waits for content to load
count = all("tbody tr").count  # Now safe - no explicit wait needed

# ✅ BETTER - avoid all() entirely
visit admin_users_path
assert_selector "tbody tr", count: 5  # Waits automatically
```

#### Pattern: Before Using Non-Waiting Methods

If you must use non-waiting methods (`all`, `first`, etc.), ensure content is loaded first:

```ruby
# Step 1: Use a waiting method to confirm content loaded
assert_selector ".user-row", minimum: 1

# Step 2: Now safe to use non-waiting methods
rows = all(".user-row")
rows.each { |row| assert row.has_text?("Active") }
```

#### When to Use Explicit `wait:` Parameter

Only use explicit `wait:` when:
- Default wait time (2 seconds) is genuinely insufficient
- Testing slow operations (complex calculations, external API calls)
- Testing loading/spinner disappearance

```ruby
# Acceptable use case - waiting for slow operation
click_on "Generate Report"
assert_selector ".report-complete", wait: 10  # Complex calculation takes time
```

**Never add explicit waits for normal page loads or Turbo Stream updates** - Capybara's automatic waiting is sufficient for 99% of cases.

#### Pattern: Verifying Page Navigation with Positive Assertions

Always use positive assertions (checking for presence) rather than negative assertions (checking for absence) when verifying navigation:

```ruby
# ❌ BAD - negative assertion can pass before page navigates
fill_in "Email", with: user.email
fill_in "Password", with: "password"
click_button "Log in"
assert_no_selector "h1", text: "Log in"  # Might pass too early!

# ✅ GOOD - positive assertion waits for destination page
fill_in "Email", with: user.email
fill_in "Password", with: "password"
click_button "Log in"
assert_selector "button[aria-label='Sign out']"  # Confirms we're signed in

# ❌ BAD - checking that old content is gone
click_on "Delete"
refute_text "Item name"  # Might pass before Turbo Stream completes

# ✅ GOOD - wait for modal to close, then check
click_on "Delete"
assert_no_selector "#modal .modal.is-active"  # Wait for action to complete
refute_text "Item name"  # Now safe to check
```

**Why positive assertions are better:**
- Negative assertions can pass immediately if the element isn't present yet
- Positive assertions wait for elements to appear, ensuring the page has loaded
- More reliable for navigation and dynamic content updates

### Testing Turbo Frames and Modals

```ruby
test "should edit user in modal" do
  user = create(:user)
  visit admin_users_path

  within "#user-#{user.id}" do
    click_on "Edit"
  end

  # Wait for modal to appear
  assert_selector "#edit-user-modal[open]"

  within "#edit-user-modal" do
    fill_in "Email", with: "updated@example.com"
    click_on "Save"
  end

  # Wait for modal to close
  assert_no_selector "#edit-user-modal[open]"
  assert_text "updated@example.com"
end
```

### Testing Pagination and Infinite Scroll

Our pagination limit is environment-specific for testing efficiency:
* Test environment: 3 items per page (minimize test data)
* All other environments: 30 items per page

This is configured in `config/initializers/pagy.rb`.

#### Pattern: Infinite Scroll / Dynamic Loading

```ruby
# ❌ BAD - explicit wait parameter, unnecessary complexity
assert_selector "tbody tr", count: 20, wait: 5
page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
assert_selector "tbody tr", minimum: initial_count + 1, wait: 5

# ✅ GOOD - no explicit waits needed, automatic waiting does the job
assert_selector "tbody tr", minimum: 1
page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
assert_selector "tbody tr", minimum: 4  # Waits automatically
```

## Accessibility Testing

Use `assert_accessible` to verify WCAG compliance:

```ruby
test "should be accessible" do
  visit admin_users_path
  assert_accessible
end

test "should have accessible form" do
  visit new_admin_user_path

  within "#user-form" do
    assert_accessible
  end
end
```

### Common Accessibility Issues

- Missing labels on form inputs
- Missing alt text on images
- Poor color contrast
- Missing ARIA attributes on interactive elements
- Missing focus indicators

## Testing Authentication & Authorization

### Testing with Devise

```ruby
class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "should get index when signed in" do
    get users_path
    assert_response :success
  end

  test "should redirect to login when not signed in" do
    sign_out @user
    get users_path
    assert_redirected_to new_user_session_path
  end
end
```

### Testing Pundit Policies

```ruby
class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = create(:user, :admin)
    @user = create(:user)
    @other_user = create(:user)
  end

  test "admin can destroy any user" do
    policy = UserPolicy.new(@admin, @other_user)
    assert policy.destroy?
  end

  test "user can only destroy themselves" do
    policy = UserPolicy.new(@user, @user)
    assert policy.destroy?

    policy = UserPolicy.new(@user, @other_user)
    assert_not policy.destroy?
  end
end
```

## Testing Background Jobs

### Testing Job Enqueuing

```ruby
test "should enqueue welcome email job" do
  assert_enqueued_with(job: WelcomeEmailJob) do
    create(:user)
  end
end

test "should enqueue job with correct arguments" do
  user = create(:user)

  assert_enqueued_with(job: WelcomeEmailJob, args: [user]) do
    WelcomeEmailJob.perform_later(user)
  end
end
```

### Testing Job Execution

```ruby
class WelcomeEmailJobTest < ActiveJob::TestCase
  test "should send welcome email" do
    user = create(:user)

    assert_emails 1 do
      WelcomeEmailJob.perform_now(user)
    end
  end

  test "should handle missing user gracefully" do
    assert_nothing_raised do
      WelcomeEmailJob.perform_now(nil)
    end
  end
end
```

## Test Coverage

### Running Tests with Coverage

```bash
# Generate coverage report
bin/rails test

# View report
open coverage/index.html
```

### Coverage Goals

* Overall: Aim for 80%+ coverage
* Models: 90%+ (business logic is critical)
* Controllers: 80%+ (verify all actions)
* Jobs: 90%+ (background work needs reliability)
* Policies: 100% (authorization is security-critical)

### What Not to Over-Test

* Framework code (Rails, Devise, Pundit internals)
* Third-party gems
* Database migrations
* Simple delegations and attr_accessors

## Performance Tips

1. Use transactional fixtures - tests are faster with rollback
2. Prefer `build` over `create` - avoid unnecessary DB writes
3. Use `create_list` efficiently - only create what you need
4. Parallelize tests - Rails supports parallel testing
5. Profile slow tests - use `--profile` flag

```bash
# Run tests in parallel
bin/rails test --parallel

# Profile slowest tests
bin/rails test --profile
```

## Common Pitfalls

### ❌ Don't use `sleep`

```ruby
# Bad
click_on "Save"
sleep 2
assert_text "Saved"

# Good
click_on "Save"
assert_text "Saved"
```

### ❌ Don't test implementation details

```ruby
# Bad - tests internal method
test "should call send_email" do
  user = create(:user)
  user.expects(:send_email)
  user.welcome
end

# Good - tests behavior
test "should send email on welcome" do
  user = create(:user)
  assert_emails 1 do
    user.welcome
  end
end
```

### ❌ Don't create unnecessary data

```ruby
# Bad - creates 100 users but only tests one
users = create_list(:user, 100)
assert users.first.valid?

# Good - creates only what's needed
user = create(:user)
assert user.valid?
```

### ❌ Don't skip accessibility tests

```ruby
# Bad - no accessibility check
test "should display user form" do
  visit new_user_path
  assert_selector "form"
end

# Good - includes accessibility
test "should display accessible user form" do
  visit new_user_path
  assert_selector "form"
  assert_accessible
end
```

## Running Tests

```bash
# All tests
bin/rails test

# Specific file
bin/rails test test/models/user_test.rb

# Specific test by line number
bin/rails test test/models/user_test.rb:10

# System tests only
bin/rails test:system

# With coverage
bin/rails test

# Full CI suite (style, security, tests)
bin/ci
```

### Debugging System Tests with Visible Browser

By default, system tests run in headless Chrome for speed. To debug failing tests, you can run them in a visible browser:

```bash
# Run with visible browser (great for debugging)
HEADLESS=false bin/rails test:system test/system/admin/users/create_test.rb

# Run specific test with visible browser
HEADLESS=false bin/rails test test/system/admin/users/create_test.rb:28

# Run all system tests with visible browser
HEADLESS=false bin/rails test:system
```

When to use visible browser mode:
* Debugging failing tests to see what's actually happening
* Understanding complex user interactions
* Verifying visual behavior
* Troubleshooting timing/waiting issues

Tips for debugging:
* Add `binding.pry` or `debugger` in your test to pause execution
* Watch the browser to see exactly what Capybara is doing
* Check the browser console for JavaScript errors
* Use the Rails screenshot feature for failed tests (automatically saved to `tmp/screenshots/`)

```ruby
# Add a pause point to inspect the page
test "admin can create user" do
  visit admin_users_path
  click_on "Add User"
  
  binding.pry # Pauses here - inspect browser state
  
  fill_in "Email", with: "test@example.com"
  click_on "Create"
end
```

## Chrome Browser Configuration

System tests use a customized Chrome configuration optimized for stability, performance, and CI compatibility.

### Configuration Overview

The Chrome driver is configured in `test/application_system_test_case.rb` with:

```ruby
driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |options|
  # Password manager preferences
  options.add_preference("profile.password_manager_leak_detection", false)
  options.add_preference("credentials_enable_service", false)
  options.add_preference("profile.password_manager_enabled", false)

  # Core stability arguments
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")

  # Hide automation indicators
  options.add_argument("--disable-blink-features=AutomationControlled")
  options.add_argument("--disable-infobars")

  # Performance and consistency
  options.add_argument("--disable-extensions")
  options.add_argument("--disable-background-timer-throttling")
  options.add_argument("--disable-backgrounding-occluded-windows")
  options.add_argument("--disable-renderer-backgrounding")

  # Disable unnecessary features
  options.add_argument("--disable-features=TranslateUI")
  options.add_argument("--disable-popup-blocking")

  # Ensure consistent window size
  options.add_argument("--window-size=1400,1400")
end
```

### Why These Settings Are Necessary

**Password Manager Settings:**
- Chrome's password leak detection shows "Change your password" popups
- Password manager prompts "Save password?" dialogs
- These native browser popups block Capybara from interacting with page elements
- Cannot be dismissed by Capybara commands (they're part of Chrome's UI, not the DOM)

**Core Stability Arguments:**
- `--no-sandbox`: Required for Docker and CI environments without proper sandboxing
- `--disable-dev-shm-usage`: Prevents shared memory issues in containers (critical for CI)
- `--disable-gpu`: Disables GPU hardware acceleration (helps on macOS/Linux CI)

**Automation Hiding:**
- `--disable-blink-features=AutomationControlled`: Prevents sites from detecting automation
- `--disable-infobars`: Removes "Chrome is being controlled" message

**Performance Optimizations:**
- `--disable-extensions`: Faster startup, no extension interference
- `--disable-background-timer-throttling`: Prevents timing inconsistencies
- `--disable-backgrounding-occluded-windows`: Keeps rendering consistent
- `--disable-renderer-backgrounding`: Prevents background tab throttling

**Feature Disabling:**
- `--disable-features=TranslateUI`: No translate popups
- `--disable-popup-blocking`: Allows popups (sometimes needed for auth flows)

### Test Password Convention

Use the password `"password"` consistently in tests:

```ruby
def sign_in(user)
  visit new_user_session_path
  fill_in "Email", with: user.email
  fill_in "Password", with: "password"  # Standard test password
  click_button "Log in"
  assert_selector "button[aria-label='Sign out']"
end
```

This is safe because:
- Tests run in an isolated browser session
- Password manager is disabled
- Test data is cleaned up after each test
- No real user data is involved

### Benefits

- ✅ **Stable:** No intermittent failures from browser popups
- ✅ **Fast:** ~20% faster test execution with optimizations
- ✅ **CI-Ready:** Works in Docker, GitHub Actions, and other CI environments
- ✅ **Consistent:** Same behavior across macOS, Linux, and CI
- ✅ **Debuggable:** Works in both headless and visible browser modes

## References

* [Minitest Documentation](https://github.com/minitest/minitest)
* [Capybara Documentation](https://github.com/teamcapybara/capybara)
* [FactoryBot Documentation](https://github.com/thoughtbot/factory_bot)
* [SimpleCov Documentation](https://github.com/simplecov-ruby/simplecov)
