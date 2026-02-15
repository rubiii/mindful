# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

enable_integrity!

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# https://atomiks.github.io/tippyjs/v6/getting-started/
# Using Skypack bundled versions for CSP compliance (locally vendored)
pin "tippy.js", to: "tippy.js" # @6.3.7
pin "/-/@popperjs/core@v2.11.2-7HHj50CzBHDvkIAwMPdO/dist=es2019,mode=imports/optimized/@popperjs/core.js", to: "popper-core.js" # @2.11.2
