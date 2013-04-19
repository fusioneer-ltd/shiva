# -*- encoding : utf-8 -*-
describe Shiva::Database do

  context "'Integer', 'integer'" do
    subject { Shiva::Database.new('Integer', 'integer') }

    its(:migration_path) { should eq 'db/migrate/integer/' }
    its(:schema_path) { should eq 'db/schema/integer_schema.rb' }
    its(:seeds_path) { should eq 'db/seeds/integer.rb' }
    its(:base_model) { should be Integer }
  end

  context "'Symbol', 'symbolic_state'" do
    subject { Shiva::Database.new('Symbol', 'symbolic_state') }

    its(:migration_path) { should eq 'db/migrate/symbolic_state/' }
    its(:schema_path) { should eq 'db/schema/symbolic_state_schema.rb' }
    its(:seeds_path) { should eq 'db/seeds/symbolic_state.rb' }
    its(:base_model) { should be Symbol }
  end

end
