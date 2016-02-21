class TestsController < ActionController::Base
  def dangerously_import_db
    ActiveRecord::Base.connection.disconnect!

    raise "Can't drop db" unless system("dropdb pathways_test")
    raise "Can't import db" unless system("createdb -O rusl -T pathways_production pathways_test")

    ActiveRecord::Base.establish_connection

    render nothing: true, status: 200
  end
end
