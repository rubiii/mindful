# Documentation Guidelines

We strive for consistent and clean documentation across the project. This guide outlines the standards for writing documentation in Markdown and documenting Ruby code.

## Markdown Style Guide

We follow a specific style for all Markdown files in this project (including this one).

### Lists
* Use asterisks `*` for unordered lists, not hyphens `-`.
* Use 2 spaces for indentation of nested lists.

Example:
```markdown
* Level 1
  * Level 2
  * Level 2
* Level 1
```

### Formatting
* Avoid using bold text (`**text**`). Use headers, code blocks, or just plain text to emphasize structure.
* Use backticks for technical terms, file paths, and command names.

### Headers
* Use ATX-style headers (`#`, `##`, etc.).
* Leave one blank line before and after headers.

## Code Documentation (Ruby)

We use [YARD](https://yardoc.org/) syntax for documenting Ruby classes and methods. This allows for consistent inline documentation that is easy to read and can be parsed by tools.

### General Rules
* Document all public classes and methods.
* Keep descriptions concise but informative.
* Use full sentences ending with a period.

### Common Tags

#### `@param`
Describes a method argument.

```ruby
# @param email [String] The user's email address
# @param force [Boolean] Whether to bypass validation
def invite(email, force: false)
```

#### `@return`
Describes the return value of a method.

```ruby
# @return [User] The newly created user
# @return [nil] If the creation failed
def create_user(params)
```

#### `@raise`
Documents exceptions that can be raised.

```ruby
# @raise [ArgumentError] If the email is invalid
def validate_email!(email)
```

#### `@example`
Provides a code example for usage.

```ruby
# @example Calculate the total
#   calculator.add(5, 10) #=> 15
def add(a, b)
```

### Example Class Documentation

```ruby
# Handles user notifications via email and WebSocket.
class NotificationService
  # Sends a welcome notification to a user.
  #
  # @param user [User] The recipient of the notification
  # @param message [String] The body of the message
  # @return [Boolean] True if delivered successfully
  def send_welcome(user, message)
    # ...
  end
end
```
