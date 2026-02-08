# mindful

This is a Ruby on Rails 8 application template.

## Prerequisites

- Ruby 3.4.8
- PostgreSQL 18+

## Database Setup

You have two options for running PostgreSQL locally:

### Option A: Docker Compose (Recommended)

The easiest way to get started is with Docker Compose:

```bash
# Start PostgreSQL
docker compose up -d

# Check it's running
docker compose ps

# Stop when done
docker compose down
```

### Option B: Local PostgreSQL Installation

**macOS (Homebrew):**
```bash
brew install postgresql@18
brew services start postgresql@18
```

**Ubuntu/Debian:**
```bash
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Configure Database

The first time you run `bin/setup`, it will automatically create `config/database.yml` from the template.

If you need to reconfigure:

```bash
# Copy the example database configuration
cp config/database.example.yml config/database.yml

# Edit config/database.yml with your credentials
# For Docker Compose: username/password are both 'mindful'
# For local install: use your system username
```

## Environment Variables

The application uses environment variables for configuration. The first time you run `bin/setup`, it will automatically create a `.env` file from the template.

If you need to reconfigure:

```bash
# Copy the example environment configuration
cp .env.example .env

# Edit .env with your settings
# Key variables:
# - MAILER_SENDER: Email address for outgoing emails
# - MAILER_HOST: Host for URL generation in emails
# - SMTP_*: SMTP server settings (optional, for production)
```

For development, emails are previewed in the browser via [letter_opener_web](http://localhost:3000/letter_opener) instead of being sent.

## Getting Started

Clone the repository and run the setup script:

```bash
bin/setup
```

Then seed the database to test the application:

```bash
bin/rails db:seed
```

You can access the application at `http://localhost:3000`.

To start the server run:

```bash
bin/dev
```

## Tech Stack

* Framework: Rails 8.1.2
* Database: PostgreSQL 18+
* Frontend: Hotwire (Turbo & Stimulus) with Propshaft for assets
* Background jobs: Good Job
* Caching: Solid Cache
* WebSockets: Solid Cable
* Deployment: Kamal
* Authentication: Devise
* Authorization: Pundit
* Forms: SimpleForm
* Pagination: Pagy
* Error tracking: AppSignal (to be implemented)
* CSS Framework: Bulma
* Icons: heroicons
* Testing: Minitest, Capybara & FactoryBot
* Code Coverage: SimpleCov

## Development

### Code Quality & Security

We use several tools to maintain code quality and security:

* **RuboCop:** Enforces code style. Run with `bin/rubocop`.
* **Herb:** Static analysis for HTML+ERB templates. Run with `bin/herb analyze .`.
* **Brakeman:** Static analysis for security vulnerabilities. Run with `bin/brakeman`.
* **Bundler Audit:** Checks for vulnerable Ruby gems. Run with `bin/bundler-audit`.
* **Importmap Audit:** Checks for vulnerable NPM packages. Run with `bin/importmap audit`.
* **SimpleCov:** Tracks test coverage. Reports generated automatically when running tests.

### Testing

Run the standard test suite:

```bash
bin/rails test
```

Run system tests (end-to-end):

```bash
bin/rails test:system
```

### Test Coverage

Test coverage is tracked with SimpleCov and reports are generated automatically when running tests:

```bash
# Run tests (generates coverage report)
bin/rails test

# View coverage report
open coverage/index.html
```

### Continuous Integration

You can run the full CI workflow locally, which includes setup, style checks, security audits, and tests:

```bash
bin/ci
```

## Documentation

For detailed guidance on specific topics, see:

- [Rails & Hotwire Patterns](/docs/rails_patterns.md)
- [Background Jobs (Good Job)](/docs/background_jobs.md)
- [Authentication (Devise)](/docs/authentication.md)
- [Authorization (Pundit)](/docs/authorization.md)
- [Testing Guidelines](/docs/testing.md)
- [Database Best Practices](/docs/database.md)
