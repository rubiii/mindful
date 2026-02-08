# frozen_string_literal: true

# Define an application-wide permissions policy.
#
# See the Permissions Policy Guide for more information:
# https://github.com/w3c/webappsec-permissions-policy

Rails.application.config.permissions_policy do |policy|
  policy.accelerometer :none
  policy.autoplay      :none
  policy.camera        :none
  policy.encrypted_media :none
  policy.fullscreen    :self
  policy.geolocation   :none
  policy.gyroscope     :none
  policy.magnetometer  :none
  policy.microphone    :none
  policy.midi          :none
  policy.payment       :none
  policy.picture_in_picture :self
  policy.usb :none
end
