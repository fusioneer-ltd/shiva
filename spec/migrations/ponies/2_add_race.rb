# -*- encoding : utf-8 -*-
class AddRace < ActiveRecord::Migration
  def self.up
    add_column :ponies, :race, :string
  end

  def self.down
    remove_column :ponies, :race
  end

  def up; self.class.up; end
  def down; self.class.down; end
end
