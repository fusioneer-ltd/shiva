# -*- encoding : utf-8 -*-
ActiveRecord::Schema.define(:version => 1) do
  create_table "ponies", :force => true do |t|
    t.string  "name"
  end
end
