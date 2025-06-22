require 'rails_helper'

RSpec.describe 'Home', type: :system do
  describe 'top page check' do
    it 'show words of Home#top' do
      visit '/'
      expect(page).to have_content('Home#top')
    end
  end

  describe 'basic page structure' do
    before { visit '/' }

    it 'displays the page title' do
      expect(page).to have_title('Team Task Manager')
    end

    it 'has proper HTML structure' do
      expect(page).to have_css('html')
      expect(page).to have_css('body')
      expect(page).to have_css('h1')
    end

    it 'displays the main heading' do
      expect(page).to have_css('h1', text: 'Home#top')
    end

    it 'displays the instruction text' do
      expect(page).to have_content('Find me in app/views/home/top.html.erb')
    end

    it 'has correct styling classes' do
      expect(page).to have_css('h1.font-bold.text-4xl.text-red-500')
    end
  end
end
