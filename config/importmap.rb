# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

enable_integrity!

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# https://atomiks.github.io/tippyjs/v6/getting-started/
pin "tippy.js" # @6.3.7
pin "@popperjs/core", to: "popperjs_core.js" # @2.11.8
