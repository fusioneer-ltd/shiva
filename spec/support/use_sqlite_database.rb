# -*- encoding : utf-8 -*-
module UseSqliteDatabase
  def use_sqlite_database(database_name)
    before :each do
      database_name += '.sqlite' if database_name[-7,7] != '.sqlite'
      FileUtils.cp File.join(FIXTURES_ROOT, 'databases', database_name), File.join(SPEC_ROOT, 'tmp', database_name)
    end
  end
end

RSpec.configure do |config|
  config.extend UseSqliteDatabase
end
