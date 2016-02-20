require 'spec_helper'

describe "the signin process", :type => :feature do
  after :each do
    ActiveRecord::Base.connection.disconnect!

    host = Capybara.current_session.server.host
    port = Capybara.current_session.server.port
    url = "http://#{host}:#{port}/dangerously_import_db"

    Net::HTTP.get(URI(url))

    ActiveRecord::Base.establish_connection
  end
  
  it "shows the login page" do

    visit '/login'
    expect(page).to have_content 'Log in'
  end

  it "shows the login page again" do
    visit '/login'
    expect(page).to have_content 'Log in'
  end
end
