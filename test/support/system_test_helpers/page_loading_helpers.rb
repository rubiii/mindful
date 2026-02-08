# frozen_string_literal: true

module SystemTestHelpers
  module PageLoadingHelpers
    # Wait for page content to load before using non-waiting methods
    #
    # @param content [String, nil] Specific content to wait for
    # @param selector [String, nil] Specific selector to wait for
    #
    # @example
    #   wait_for_page_load content: "user@example.com"
    #   wait_for_page_load selector: "tbody tr"
    def wait_for_page_load(content: nil, selector: nil)
      if content
        assert_text content
      elsif selector
        assert_selector selector, minimum: 1
      else
        # Default: wait for main content
        assert_selector "main"
      end
    end

    # Count table rows safely (waits for content first)
    #
    # @param selector [String] The CSS selector for rows (default: "tbody tr")
    # @param wait_for_content [String, nil] Optional content to wait for first
    #
    # @return [Integer] The number of matching rows
    #
    # @example
    #   count = count_table_rows
    #   count = count_table_rows selector: ".user-row"
    #   count = count_table_rows wait_for_content: "admin@example.com"
    def count_table_rows(selector: "tbody tr", wait_for_content: nil)
      wait_for_page_load(content: wait_for_content) if wait_for_content
      all(selector).count
    end
  end
end
