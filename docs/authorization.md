# Authorization (Pundit)

This guide covers authorization patterns using Pundit in the Mindful application.

## Overview

We use [Pundit](https://github.com/varvet/pundit) for authorization. Pundit provides a simple, object-oriented approach to authorization through policy classes.

## Key Concepts

- **Policies**: Plain Ruby classes that define authorization rules for a given model
- **Scopes**: Define which records a user can see
- **Policy Methods**: Methods that return true/false for specific actions
- **Current User**: Automatically available in policies via `user`

## Policy Structure

Policies live in `app/policies/` and follow the naming convention `ModelNamePolicy`.

### Basic Policy Template

```ruby
class ArticlePolicy < ApplicationPolicy
  def index?
    true # Everyone can view the index
  end

  def show?
    true # Everyone can view articles
  end

  def create?
    user.present? # Only logged-in users can create
  end

  def update?
    user.admin? || record.user == user # Admins or owners can update
  end

  def destroy?
    user.admin? || record.user == user # Admins or owners can delete
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all # Admins see everything
      else
        scope.published # Others only see published articles
      end
    end
  end
end
```

### ApplicationPolicy

All policies should inherit from `ApplicationPolicy`, which provides:
- Default deny-all behavior (safer default)
- Standard CRUD action methods
- Base scope class

## Controller Authorization

### Authorize Actions

Use `authorize` to check if the current user can perform an action:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    authorize @article # Calls ArticlePolicy#show?
  end

  def create
    @article = Article.new(article_params)
    authorize @article # Calls ArticlePolicy#create?
    
    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  def destroy
    @article = Article.find(params[:id])
    authorize @article # Calls ArticlePolicy#destroy?
    @article.destroy
    redirect_to articles_path
  end
end
```

### Policy Scopes

Use policy scopes to filter records based on what the user can see:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = policy_scope(Article) # Calls ArticlePolicy::Scope#resolve
  end
end
```

### Strong Parameters with Policies

Use `permitted_attributes` to define which attributes a user can modify:

```ruby
class ArticlePolicy < ApplicationPolicy
  def permitted_attributes
    if user.admin?
      [:title, :body, :published, :featured]
    else
      [:title, :body]
    end
  end
end

# In controller:
def article_params
  params.require(:article).permit(*policy(@article || Article).permitted_attributes)
end
```

## View Authorization

### Checking Permissions in Views

Use `policy` helper to check permissions in views:

```erb
<% if policy(@article).update? %>
  <%= link_to "Edit", edit_article_path(@article) %>
<% end %>

<% if policy(@article).destroy? %>
  <%= link_to "Delete", article_path(@article), data: { turbo_method: :delete } %>
<% end %>

<% if policy(Article).create? %>
  <%= link_to "New Article", new_article_path %>
<% end %>
```

### Scoping in Views

```erb
<% policy_scope(Article).each do |article| %>
  <%= render article %>
<% end %>
```

## Admin Namespace

For admin areas, use a namespace and separate policies:

### Admin Policy

```ruby
module Admin
  class BasePolicy < ApplicationPolicy
    def index?
      user&.admin?
    end

    def show?
      user&.admin?
    end

    def create?
      user&.admin?
    end

    def update?
      user&.admin?
    end

    def destroy?
      user&.admin?
    end

    class Scope < Scope
      def resolve
        user&.admin? ? scope.all : scope.none
      end
    end
  end
end
```

### Admin Controllers

```ruby
module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    
    def index
      authorize [:admin, :user] # Uses Admin::UserPolicy
      @users = policy_scope([:admin, User])
    end

    def show
      @user = User.find(params[:id])
      authorize [:admin, @user]
    end
  end
end
```

## Testing Policies

### Unit Testing Policies

Use Minitest to test policies directly:

```ruby
require "test_helper"

class ArticlePolicyTest < ActiveSupport::TestCase
  def setup
    @user = users(:john)
    @admin = users(:admin)
    @article = articles(:published)
  end

  test "anyone can view articles" do
    assert ArticlePolicy.new(nil, @article).show?
    assert ArticlePolicy.new(@user, @article).show?
  end

  test "only logged in users can create articles" do
    refute ArticlePolicy.new(nil, Article.new).create?
    assert ArticlePolicy.new(@user, Article.new).create?
  end

  test "only owner or admin can update article" do
    own_article = @user.articles.first
    other_article = articles(:other_user_article)

    assert ArticlePolicy.new(@user, own_article).update?
    refute ArticlePolicy.new(@user, other_article).update?
    assert ArticlePolicy.new(@admin, other_article).update?
  end

  test "scope returns appropriate records" do
    scope = ArticlePolicy::Scope.new(@user, Article.all).resolve
    assert_includes scope, articles(:published)
    refute_includes scope, articles(:draft)
  end
end
```

### Testing Authorization in Controllers

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "non-admin cannot access admin actions" do
    sign_in users(:regular_user)
    article = articles(:published)
    
    delete article_path(article)
    assert_response :forbidden
  end

  test "admin can delete any article" do
    sign_in users(:admin)
    article = articles(:published)
    
    assert_difference "Article.count", -1 do
      delete article_path(article)
    end
  end
end
```

### Testing in System Tests

```ruby
class ArticlesTest < ApplicationSystemTestCase
  test "regular user does not see admin actions" do
    sign_in users(:regular_user)
    visit article_path(articles(:published))
    
    assert_no_link "Delete"
    assert_no_link "Edit"
  end

  test "admin sees all actions" do
    sign_in users(:admin)
    visit article_path(articles(:published))
    
    assert_link "Delete"
    assert_link "Edit"
  end
end
```

## Common Patterns

### Complex Authorization Logic

For complex authorization, extract to private methods:

```ruby
class ArticlePolicy < ApplicationPolicy
  def update?
    owner? || admin? || collaborator?
  end

  private

  def owner?
    record.user == user
  end

  def admin?
    user&.admin?
  end

  def collaborator?
    user && record.collaborators.include?(user)
  end
end
```

### Conditional Policies

```ruby
class ArticlePolicy < ApplicationPolicy
  def publish?
    return false unless user.present?
    return true if user.admin?
    owner? && record.complete?
  end

  private

  def owner?
    record.user == user
  end
end
```

### Headless Policies

For actions not tied to a specific record:

```ruby
class DashboardPolicy < Struct.new(:user, :dashboard)
  def show?
    user.present?
  end
end

# In controller:
def show
  authorize :dashboard, :show?
end
```

## Error Handling

### Handling Unauthorized Access

Pundit raises `Pundit::NotAuthorizedError` when authorization fails. Handle it in `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
```

### Ensuring Authorization

To ensure you don't forget authorization checks, add to `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
end
```

Skip verification for specific actions:

```ruby
class PagesController < ApplicationController
  skip_after_action :verify_authorized
end
```

## Best Practices

1. **Keep Policies Simple**: Policies should be easy to understand and test
2. **Use Scopes**: Always use `policy_scope` for index actions
3. **Test Thoroughly**: Write unit tests for all policy methods
4. **Consistent Naming**: Follow the `action?` naming convention
5. **Avoid Business Logic**: Keep business logic in models, authorization in policies
6. **Use Namespaces**: Organize admin policies in `Admin::` namespace
7. **Default Deny**: Start with denied access and explicitly allow
8. **Document Complex Rules**: Add comments for non-obvious authorization logic

## Resources

- [Pundit Documentation](https://github.com/varvet/pundit)
- [Testing Pundit Policies](https://github.com/varvet/pundit#testing)