# frozen_string_literal: true

class AddLocaleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :locale, :string, null: false
  end
end
