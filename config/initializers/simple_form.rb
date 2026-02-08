# frozen_string_literal: true

# https://github.com/heartcombo/simple_form

module CustomFormComponents
  def blank_space(_wrapper_options = nil)
    " "
  end
end

SimpleForm::Inputs::Base.include CustomFormComponents

SimpleForm.setup do |config|
  # Default wrapper
  config.wrappers :bulma, tag: "div", class: "field", error_class: "has-error" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label, class: "label"
    b.wrapper tag: "div", class: "control" do |ba|
      ba.use :input, class: "input", error_class: "is-danger"
    end
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
  end

  # Select wrapper
  config.wrappers :bulma_select, tag: "div", class: "field", error_class: "has-error" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label, class: "label"
    b.wrapper tag: "div", class: "control" do |ba|
      ba.wrapper tag: "div", class: "select is-fullwidth" do |bb|
        bb.use :input, error_class: "is-danger"
      end
    end
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
  end

  config.default_wrapper = :bulma

  # Horizontal wrapper for checkboxes and radio buttons
  config.wrappers :h_bool, tag: "div", class: "field", error_class: "has-error" do |b|
    b.wrapper tag: "div", class: "control" do |ba|
      ba.wrapper tag: "label", class: "checkbox" do |bb|
        bb.use :input
        bb.use :blank_space
        bb.use :label_text
      end
    end
    b.use :error, wrap_with: { tag: "p", class: "help is-danger" }
    b.use :hint,  wrap_with: { tag: "p", class: "help" }
  end

  # Render check boxes and radio buttons as input + label.
  # Use :h_bool or :v_bool wrappers for check boxes and radio buttons.
  config.boolean_style = :inline

  # Default class for buttons
  config.button_class = "button"

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = false

  # Prevent SimpleForm from adding the input type class (e.g. .select) to the wrapper,
  # as this conflicts with Bulma's .select class.
  config.generate_additional_classes_for = []
end
