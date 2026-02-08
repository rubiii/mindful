# frozen_string_literal: true

module SystemTestHelpers
  extend ActiveSupport::Concern

  included do
    include SystemTestHelpers::AuthenticationHelpers
    include SystemTestHelpers::ModalHelpers
    include SystemTestHelpers::TurboStreamHelpers
    include SystemTestHelpers::ConfirmationHelpers
    include SystemTestHelpers::PageLoadingHelpers
    include SystemTestHelpers::AuthorizationHelpers
    include SystemTestHelpers::CrudHelpers
  end
end
