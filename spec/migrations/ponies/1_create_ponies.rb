# -*- encoding : utf-8 -*-
class CreatePonies < ActiveRecord::Migration
  def self.up
    create_table "ponies", :force => true do |t|
      t.string  "name"
    end
  end

  def self.down
    drop_table "ponies"
  end

  def up; self.class.up; end
  def down; self.class.down; end
end
