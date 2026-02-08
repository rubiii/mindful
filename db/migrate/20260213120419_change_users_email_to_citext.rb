# frozen_string_literal: true

class ChangeUsersEmailToCitext < ActiveRecord::Migration[8.1]
  def up
    # Change email column to citext for case-insensitive operations.
    # Enables natural sorting and case-insensitive searching/filtering.
    change_column :users, :email, :citext
  end

  def down
    change_column :users, :email, :string
  end
end
