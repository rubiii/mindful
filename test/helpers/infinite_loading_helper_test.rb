# frozen_string_literal: true

require "test_helper"
require "ostruct"

class InfiniteLoadingHelperTest < ActionView::TestCase
  def setup
    @pagy_with_next = OpenStruct.new(next: 2, page: 1)
    @pagy_without_next = OpenStruct.new(next: nil, page: 1)
  end

  describe "#infinite_loading" do
    it "returns nil when no next page" do
      result = infinite_loading(pagy: @pagy_without_next)

      assert_nil result
    end

    it "raises ArgumentError when no pagy available" do
      error = assert_raises(ArgumentError) do
        infinite_loading
      end

      assert_match(/Missing pagy: argument or @pagy variable/, error.message)
    end
  end

  describe "#refresh_infinite_loading" do
    it "raises ArgumentError when no pagy available" do
      error = assert_raises(ArgumentError) do
        refresh_infinite_loading
      end

      assert_match(/Missing pagy: argument or @pagy variable/, error.message)
    end
  end
end
