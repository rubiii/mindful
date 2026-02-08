# frozen_string_literal: true

require "test_helper"

class IconHelperTest < ActionView::TestCase
  it "renders an icon template in a .icon span" do
    # Test with an existing icon partial
    result = icon(:sign_out)

    assert_match(/<span/, result)
    assert_match(/class="icon"/, result)
    assert_match(/<svg/, result)
  end

  it "merges custom classes with icon class" do
    result = icon(:sign_out, class: "custom-class")

    assert_match(/class="custom-class icon"/, result)
  end

  it "passes through additional options" do
    result = icon(:sign_out, id: "my-icon", data: { action: "click->test#action" })

    assert_match(/id="my-icon"/, result)
    assert_match(/data-action="click-&gt;test#action"/, result)
  end
end
