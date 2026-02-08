# Rails & Hotwire Patterns

This document covers conventions and best practices for working with Rails 8, Hotwire (Turbo & Stimulus), and Propshaft in this application.

## Hotwire Overview

Hotwire (HTML Over The Wire) is our approach to building modern, reactive web applications without writing much JavaScript. It consists of:

- **Turbo Drive**: Accelerates navigation by replacing page content
- **Turbo Frames**: Decomposes pages into independent contexts
- **Turbo Streams**: Delivers page changes as HTML fragments over WebSockets or in response to form submissions
- **Stimulus**: Sprinkles JavaScript behavior onto HTML

## Turbo Drive

Turbo Drive is automatically enabled and handles all link clicks and form submissions, converting them into AJAX requests.

### Best Practices

- No special setup needed - works automatically
- Use `data-turbo="false"` to disable Turbo for specific links/forms:
  ```erb
  <%= link_to "External Site", "https://example.com", data: { turbo: false } %>
  ```
- Listen to Turbo events in Stimulus controllers when needed:
  ```javascript
  document.addEventListener("turbo:load", () => {
    // Initialize third-party libraries
  });
  ```

## Turbo Frames

Turbo Frames decompose pages into independent contexts that can be lazy-loaded or updated independently.

### When to Use Turbo Frames

- **Modals and dialogs**: Load content without full page refresh
- **Inline editing**: Edit content in-place without navigation
- **Lazy loading**: Defer loading of non-critical content
- **Independent sections**: Update parts of a page independently

### Basic Usage

```erb
<!-- Define a frame -->
<%= turbo_frame_tag "user_profile" do %>
  <%= render @user %>
<% end %>

<!-- Link that targets the frame -->
<%= link_to "Edit", edit_user_path(@user), data: { turbo_frame: "user_profile" } %>
```

### Modal Pattern

```erb
<!-- In your layout or page -->
<%= turbo_frame_tag "modal" %>

<!-- Link that opens modal -->
<%= link_to "New User", new_user_path, data: { turbo_frame: "modal" } %>

<!-- In new.html.erb -->
<%= turbo_frame_tag "modal" do %>
  <div class="modal is-active">
    <div class="modal-background"></div>
    <div class="modal-card">
      <%= render "form", user: @user %>
    </div>
  </div>
<% end %>
```

### Breaking Out of Frames

Use `data-turbo-frame="_top"` to break out and navigate the whole page:

```erb
<%= link_to "Back to Dashboard", dashboard_path, data: { turbo_frame: "_top" } %>
```

## Turbo Streams

Turbo Streams deliver page changes as HTML fragments. Use them for real-time updates and multi-part page updates.

### When to Use Turbo Streams

- **Form submissions**: Update multiple parts of the page after save
- **Real-time updates**: Push changes via WebSockets (Action Cable)
- **Partial page updates**: Update several independent sections
- **Flash messages**: Show notifications without page refresh

### Controller Response

```ruby
def create
  @user = User.new(user_params)
  
  respond_to do |format|
    if @user.save
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.prepend("users", partial: "users/user", locals: { user: @user }),
          turbo_stream.update("user_form", partial: "users/form", locals: { user: User.new }),
          turbo_stream.update("flash", partial: "shared/flash", locals: { notice: "User created!" })
        ]
      end
      format.html { redirect_to @user, notice: "User created!" }
    else
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("user_form", partial: "users/form", locals: { user: @user })
      end
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

### Turbo Stream Actions

Available actions:

- `append` - Add content to the end of a target
- `prepend` - Add content to the beginning of a target
- `replace` - Replace the entire target
- `update` - Replace the content inside the target
- `remove` - Remove the target
- `before` - Insert before the target
- `after` - Insert after the target

### Accessibility with Turbo Streams

Always use `aria-live` regions for screen reader announcements:

```erb
<div id="flash" aria-live="polite" aria-atomic="true">
  <%= render "shared/flash" %>
</div>
```

## Stimulus Controllers

Stimulus adds JavaScript behavior to HTML elements through controllers.

### Naming Convention

- Controller files: `app/javascript/controllers/user_profile_controller.js`
- HTML attribute: `data-controller="user-profile"`

### Basic Controller

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  toggle() {
    this.menuTarget.classList.toggle("is-hidden")
  }
  
  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("is-hidden")
    }
  }
}
```

```erb
<div data-controller="dropdown" data-action="click@window->dropdown#hide">
  <button data-action="dropdown#toggle">Menu</button>
  <div data-dropdown-target="menu" class="is-hidden">
    <!-- Menu items -->
  </div>
</div>
```

### Stimulus Values

Use values to pass data from HTML to JavaScript:

```javascript
export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 5000 }
  }
  
  connect() {
    this.load()
    this.startRefreshing()
  }
  
  load() {
    fetch(this.urlValue)
      .then(response => response.text())
      .then(html => this.element.innerHTML = html)
  }
  
  startRefreshing() {
    this.refreshTimer = setInterval(() => {
      this.load()
    }, this.intervalValue)
  }
}
```

```erb
<div data-controller="auto-refresh" 
     data-auto-refresh-url-value="<%= status_path %>"
     data-auto-refresh-interval-value="10000">
</div>
```

### Stimulus Best Practices

- Keep controllers small and focused on one behavior
- Use targets instead of querySelector
- Use values for configuration
- Clean up in `disconnect()` (timers, event listeners)
- Use actions to handle events: `data-action="click->controller#method"`

## Propshaft (Asset Pipeline)

Propshaft is Rails 8's default asset pipeline - simpler than Sprockets.

### Asset Organization

- CSS: `app/assets/stylesheets/application.css`
- JavaScript: `app/javascript/application.js` (via importmap)
- Images: `app/assets/images/`

### Referencing Assets

In views:
```erb
<%= image_tag "logo.png" %>
<%= asset_path "logo.png" %>
```

In CSS:
```css
background-image: url("logo.png");
```

### Import Maps

JavaScript dependencies are managed via import maps (no npm/webpack needed):

```ruby
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
```

### Adding JavaScript Packages

```bash
bin/importmap pin package-name
```

## Common Patterns

### Infinite Scroll

```javascript
// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["scrollArea"]
  
  scroll() {
    const { scrollTop, scrollHeight, clientHeight } = this.scrollAreaTarget
    
    if (scrollTop + clientHeight >= scrollHeight - 100) {
      this.loadMore()
    }
  }
  
  loadMore() {
    if (this.loading || !this.hasUrlValue) return
    
    this.loading = true
    fetch(this.urlValue, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
    .finally(() => this.loading = false)
  }
}
```

### Dismissible Flash Messages

```javascript
// app/javascript/controllers/dismissible_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
```

```erb
<div data-controller="dismissible" class="notification">
  <button data-action="dismissible#dismiss" class="delete"></button>
  <%= notice %>
</div>
```

### Form Auto-Submit

```javascript
// app/javascript/controllers/autosubmit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 500 } }
  
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }
}
```

```erb
<%= form_with url: search_path, method: :get, data: { controller: "autosubmit", turbo_frame: "results" } do |f| %>
  <%= f.text_field :query, data: { action: "input->autosubmit#submit" } %>
<% end %>
```

## Testing Hotwire Features

### System Tests with Turbo

```ruby
test "creates user with turbo stream" do
  visit users_path
  
  click_on "New User"
  
  within "#modal" do
    fill_in "Name", with: "John Doe"
    click_on "Create User"
  end
  
  assert_text "John Doe"
  assert_no_selector "#modal" # Modal dismissed after creation
end
```

### Testing Stimulus Controllers

Use Capybara's built-in waiting:

```ruby
test "dropdown menu" do
  visit page_path
  
  click_on "Menu"
  assert_selector ".dropdown-menu:not(.is-hidden)"
  
  click_on "Outside"
  assert_selector ".dropdown-menu.is-hidden"
end
```

## Resources

- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Hotwire Discussion Forum](https://discuss.hotwired.dev/)