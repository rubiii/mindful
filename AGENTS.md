# AGENTS.md

## Project Context & Setup

Before working on any task, you must read the following files to understand the project:

1. `README.md` - Start here for:
   - Complete tech stack information
   - Database and environment setup instructions
   - Available commands (`bin/setup`, `bin/dev`, `bin/ci`, etc.)
   - Development tools and their usage

2. `/docs` directory - Detailed guidance on specific topics:
   - Rails & Hotwire patterns
   - Background jobs (Good Job)
   - Authentication (Devise)
   - Authorization (Pundit)
   - Testing guidelines
   - Database best practices

## Agent Governance & Protocol

### Core Mandate: Planning Before Action
You are prohibited from implementing code changes immediately. You must follow this mandatory three-step sequence for every task:

1. Analysis & Questions: Analyze the request. If any detail is ambiguous, you must ask for clarification before proposing a solution.
2. Proposed Plan: Present a detailed technical plan outlining:
   * Which files will be modified or created.
   * The specific logic or architecture to be used.
   * Potential risks or side effects.
3. Explicit Confirmation: End your plan with the exact phrase: "Do you approve this plan? Please confirm to proceed with implementation.".

### Operational Constraints
* No Autonomy on Implementation: Do not write, delete, or modify code until the user provides explicit consent.
* One Step at a Time: Break complex tasks into small, reviewable milestones. Seek approval after each milestone.
* Least Privilege: Only modify files directly related to the current task. Do not perform repo-wide refactors unless specifically ordered. Ask for permission to refactor if you see potential improvements.

### Tool Usage Hierarchy
You must use tools in this strict order of preference. Never skip to lower levels without exhausting higher levels first.

#### Level 1: Specialized Editor Tools (ALWAYS PREFER THESE)
* `edit_file` - For creating, editing, or overwriting files
* `read_file` - For reading file contents
* `move_path` - For moving or renaming files
* `copy_path` - For copying files
* `delete_path` - For deleting files
* `create_directory` - For creating directories

Why: These tools are purpose-built, handle edge cases, maintain file integrity, and provide proper error handling.

#### Level 2: Code Intelligence Tools
* `grep` - For searching code content (prefer over find_path for symbols)
* `find_path` - For finding files by pattern
* `list_directory` - For exploring directory structure
* `diagnostics` - For checking errors and warnings

Why: These tools understand code structure and provide formatted, parseable output.

#### Level 3: Terminal Commands (USE SPARINGLY)
* `terminal` - Only when specialized tools cannot accomplish the task
* Examples of acceptable use:
  - Running tests: `bin/rails test`
  - Database operations: `bin/rails db:migrate`
  - Package management: `bundle install`, `npm install`
  - Git operations: `git status`, `git add`
  - Build/compile operations

Why: Terminal commands are brittle, platform-dependent, and harder to debug.

#### Level 4: Shell Scripts/Heredocs (AVOID)
* `cat`, `echo`, `printf` with heredocs
* Multi-line shell scripts
* Complex piping and redirection

Why: These are error-prone (syntax errors, escaping issues), non-portable, and obscure intent.

### Tool Usage Rules
1. Never use terminal for file operations if `edit_file`, `read_file`, etc. are available
2. Never use `cat` or `echo`, to create files use `edit_file` in `create` mode instead
3. Never use heredocs, they frequently fail with syntax errors
4. Never use shell scripts for multi-file operations, use multiple tool calls
5. If a tool fails, analyze why and try a different approach with the same level of tools
6. Document tool failures, when reporting issues, don't silently fall back to inferior tools

## Standards

Make sure to always follow these established standards!

#### Code Quality & Security
* RuboCop: Enforces code style. Run with `bin/rubocop`.
* Herb: Static analysis for HTML+ERB templates. Run with `bin/herb analyze .`.
* Brakeman: Static analysis for security vulnerabilities. Run with `bin/brakeman`.
* Bundler Audit: Checks for vulnerable gem versions. Run with `bin/bundler-audit`.
* Importmap Audit: Checks for vulnerable NPM packages. Run with `bin/importmap audit`.
* i18n-tasks: Checks for missing and unused translations.
* SimpleCov: Tracks test coverage. Reports should be monitored over time to improve coverage.

See `README.md` for complete details on running these tools and the CI workflow.

#### Internationalization (I18n)
* Use standard Rails I18n for translations.
* Ensure all strings are translated incl. aria labels.
* Always prefix locale keys for aria attributes with `aria_`.
* Don't reuse existing keys w/o an `aria_` prefix for aria labels. Duplicating translations is fine in case of conflict.
* Use Rails lazy lookup for translations. Prefer relative keys like `t(".add_user")` over absolute paths like `t("admin.users.index.add_user")`. Absolute paths must be reserved for special global values like `t("locales.de")`.

#### Accessibility (A11y)
* Always use semantic HTML5 tags (e.g., <main>, <nav>, <button>).
* Every form field must have a corresponding <label>.
* Ensure all interactive elements are keyboard-accessible.
* Always ensure that all interactive elements are accessible to screen readers.
* Use `aria-label` and other accessibility attributes where appropriate.
* Use `aria-live` for Turbo Stream updates to notify screen readers.
* Default to WCAG 2.1 AA compliance for colors and contrast.
* Include accessibility assertions in system tests using `assert_accessible` (axe-core).
* Never miss or skip or comment out `assert_accessible` checks. If a test fails accessibility, report the underlying issue in the application code and propose a fix.

#### Testing (Minitest & Capybara)
* Make sure we unit test all important code.
* Use system tests to test every feature end-to-end.
* Use Minitest::Spec DSL for test organization.
* Use FactoryBot for data setup.
* Use `within` to scope actions to specific parts of the UI.
* Never use `sleep`; rely on Capybara's automatic waiting.
* Use `describe` and `context` blocks with `it` for test definitions:
  - `describe "#method"` or `describe ".class_method"` - Group tests by method
  - `context "description"` - Group tests by state/condition (e.g., "when user is admin")
  - `it "description"` - Define individual test cases
  - Use `before` for setup, `after` for teardown
  - Example: `describe "#create?" do` / `it "allows admins" do` / `end` / `end`
  - For simple test files with only a few tests, flat structure is fine
