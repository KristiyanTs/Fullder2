# frozen_string_literal: true
class AddLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locale, :string
  end
end