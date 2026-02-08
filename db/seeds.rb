# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def password = "password"
def random_locale = User.available_locales.sample

puts %(Creating test user "user@example.com" with password "password".)
User.create!(email: "user@example.com", password:, locale: random_locale)

puts %(Creating admin "admin@example.com" with password "password".)
User.create!(email: "admin@example.com", password:, locale: random_locale, role: "admin")

no_of_test_users = 100
puts %(Creating #{no_of_test_users} test users for demonstration purposes)
User.insert_all!(
  no_of_test_users.times.map { |i|
    { email: "user#{i + 1}@example.com", encrypted_password: password, locale: random_locale }
  }
)
