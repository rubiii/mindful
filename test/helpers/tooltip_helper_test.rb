# frozen_string_literal: true

require "test_helper"

class TooltipHelperTest < ActionView::TestCase
  it "tooltip with valid placement generates correct markup" do
    result = tooltip("Help text", placement: "top") { "Button" }

    assert_match(/data-controller="tooltip"/, result)
    assert_match(/data-tooltip-target="trigger"/, result)
    assert_match(/data-tooltip-content="Help text"/, result)
    assert_match(/data-tooltip-placement="top"/, result)
    assert_match(/Button/, result)
  end

  it "tooltip defaults to left placement" do
    result = tooltip("Help text") { "Button" }

    assert_match(/data-tooltip-placement="left"/, result)
  end

  it "tooltip accepts all valid placements" do
    placements = %w[
      top top-start top-end
      right right-start right-end
      bottom bottom-start bottom-end
      left left-start left-end
      auto auto-start auto-end
    ]

    placements.each do |placement|
      result = tooltip("Help", placement: placement) { "Text" }
      assert_match(/data-tooltip-placement="#{placement}"/, result)
    end
  end

  it "tooltip raises error for invalid placement" do
    error = assert_raises(ArgumentError) do
      tooltip("Help", placement: "invalid") { "Text" }
    end

    assert_match(/Invalid placement: invalid/, error.message)
    assert_match(/valid placements:/, error.message)
  end

  it "tooltip merges additional classes" do
    result = tooltip("Help", class: "custom-class") { "Button" }

    assert_match(/class="custom-class"/, result)
  end

  it "tooltip merges additional data attributes" do
    result = tooltip("Help", data: { action: "click->custom#action" }) { "Button" }

    assert_match(/data-controller="tooltip"/, result)
    assert_match(/data-action="click-&gt;custom#action"/, result)
  end

  it "tooltip passes through other HTML attributes" do
    result = tooltip("Help", id: "my-tooltip", aria_label: "Helpful button") { "Button" }

    assert_match(/id="my-tooltip"/, result)
    assert_match(/aria_label="Helpful button"/, result)
  end
end
