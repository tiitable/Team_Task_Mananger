require 'rails_helper'
RSpec.describe 'Home', type: :request do
  describe 'top page check' do
    it 'show words of Home#top' do
      visit '/'
      expect(page).to have_content('Home#top')
    end
  end
end
