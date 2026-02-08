# Authentication with Devise

This guide covers authentication patterns using Devise in this Rails application.

## Overview

We use [Devise](https://github.com/heartcombo/devise) for user authentication, which provides:

- Database authenticatable (email/password)
- Recoverable (password reset)
- Rememberable (remember me cookie)
- Trackable (sign in tracking)
- Validatable (email/password validation)

## Configuration

Devise is configured in:
- `config/initializers/devise.rb` - Main configuration
- `config/locales/devise.en.yml` - Email and message translations
- `app/models/user.rb` - User model with Devise modules

## User Model

The `User` model includes these Devise modules:

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
```

### Adding Custom Attributes

When adding custom attributes to users:

1. Generate a migration:
   ```bash
   bin/rails g migration AddFieldToUsers field:type
   ```

2. Update strong parameters in `ApplicationController` or a custom registrations controller:
   ```ruby
   before_action :configure_permitted_parameters, if: :devise_controller?

   def configure_permitted_parameters
     devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
     devise_parameter_sanitizer.permit(:account_update, keys: [:name])
   end
   ```

## Routes

Devise routes are mounted in `config/routes.rb`:

```ruby
devise_for :users
```

This provides standard routes:
- `GET /users/sign_in` - Sign in page
- `POST /users/sign_in` - Process sign in
- `DELETE /users/sign_out` - Sign out
- `GET /users/sign_up` - Registration page
- `POST /users` - Process registration
- `GET /users/password/new` - Request password reset
- `GET /users/password/edit` - Reset password form

## Controllers

### Authenticating Actions

Require authentication in controllers:

```ruby
class ArticlesController < ApplicationController
  before_action :authenticate_user!
end
```

Skip authentication for specific actions:

```ruby
class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
end
```

### Current User

Access the current user:

```ruby
current_user # => User instance or nil
user_signed_in? # => true/false
```

### Customizing Devise Controllers

To customize Devise behavior, generate controllers:

```bash
bin/rails g devise:controllers users
```

Then update routes:

```ruby
devise_for :users, controllers: {
  sessions: 'users/sessions',
  registrations: 'users/registrations'
}
```

## Views

### Customizing Views

Generate Devise views to customize:

```bash
bin/rails g devise:views
```

This creates views in `app/views/devise/` that you can modify.

### View Helpers

```erb
<% if user_signed_in? %>
  <%= link_to "Sign out", destroy_user_session_path, data: { turbo_method: :delete } %>
<% else %>
  <%= link_to "Sign in", new_user_session_path %>
<% end %>
```

**Important:** Always use `data: { turbo_method: :delete }` for sign out links with Hotwire.

## Email Configuration

Devise sends emails for:
- Password reset instructions
- Email confirmation (if confirmable module enabled)
- Account unlock instructions (if lockable module enabled)

### Development

In development, emails open in the browser via [letter_opener_web](http://localhost:3000/letter_opener).

### Production

Configure SMTP settings in `.env`:

```
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_DOMAIN=example.com
SMTP_USERNAME=your_username
SMTP_PASSWORD=your_password
```

## Password Requirements

Default requirements (configured in `config/initializers/devise.rb`):
- Minimum 6 characters
- Must match confirmation

Customize in the initializer:

```ruby
config.password_length = 8..128
```

## Testing

### System Tests

Test authentication flows:

```ruby
test "user can sign in" do
  user = create(:user, email: "test@example.com", password: "password")
  
  visit new_user_session_path
  fill_in "Email", with: "test@example.com"
  fill_in "Password", with: "password"
  click_button "Log in"
  
  assert_text "Signed in successfully"
end
```

### Controller Tests

Use Devise test helpers:

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  test "requires authentication" do
    get articles_path
    assert_redirected_to new_user_session_path
  end
  
  test "allows authenticated user" do
    user = create(:user)
    sign_in user
    
    get articles_path
    assert_response :success
  end
end
```

## Session Management

### Session Timeout

Configure in `config/initializers/devise.rb`:

```ruby
config.timeout_in = 30.minutes
```

Requires the `:timeoutable` module in the User model.

### Remember Me

The `:rememberable` module provides "Remember me" functionality:

```erb
<%= f.check_box :remember_me %>
```

Configure duration:

```ruby
config.remember_for = 2.weeks
```

## Security Best Practices

1. **Always use HTTPS in production** - Devise sets secure cookies automatically
2. **Use strong passwords** - Consider password complexity requirements
3. **Enable paranoid mode** - Prevents user enumeration via error messages
4. **Rate limit authentication attempts** - Consider using Rack::Attack
5. **Monitor failed sign-in attempts** - Use the `:trackable` module
6. **Expire sessions appropriately** - Use `:timeoutable` for sensitive applications

## Common Patterns

### Redirect After Sign In

Override `after_sign_in_path_for`:

```ruby
class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
```

### Redirect After Sign Out

Override `after_sign_out_path_for`:

```ruby
def after_sign_out_path_for(resource_or_scope)
  root_path
end
```

### Conditional Navigation

```erb
<nav>
  <% if user_signed_in? %>
    <%= link_to "Dashboard", dashboard_path %>
    <%= link_to "Profile", edit_user_registration_path %>
    <%= link_to "Sign out", destroy_user_session_path, 
                data: { turbo_method: :delete } %>
  <% else %>
    <%= link_to "Sign in", new_user_session_path %>
    <%= link_to "Sign up", new_user_registration_path %>
  <% end %>
</nav>
```

## Troubleshooting

### Sign Out Not Working with Turbo

Ensure you use `data: { turbo_method: :delete }`:

```erb
<%= link_to "Sign out", destroy_user_session_path, 
            data: { turbo_method: :delete } %>
```

### "Filter chain halted" Error

This occurs when `authenticate_user!` blocks access. Check that:
1. The user is signed in
2. The before_action is in the correct order
3. Skip authentication for public actions if needed

### Email Not Sending

Check:
1. SMTP configuration in `.env`
2. `config.action_mailer.delivery_method` in environment configs
3. Letter opener in development: http://localhost:3000/letter_opener

## Further Reading

- [Devise Documentation](https://github.com/heartcombo/devise)
- [Devise Wiki](https://github.com/heartcombo/devise/wiki)
- [Rails Guides: Action Controller Overview](https://guides.rubyonrails.org/action_controller_overview.html#filters)