require 'rails_helper'

RSpec.describe 'Cuprite smoke', type: :system do
  it 'shows home' do
    puts "Current driver: #{Capybara.current_driver}"
    visit '/'
    expect(page).to have_content('Home#top')
  end
end
