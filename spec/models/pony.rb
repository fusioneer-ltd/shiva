class Pony < ActiveRecord::Base
  establish_connection adapter: SQLITE_ADAPTER, database: File.join(SPEC_ROOT, 'tmp', 'ponies.sqlite')
end
