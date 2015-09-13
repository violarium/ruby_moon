require 'rails_helper'

describe 'Language' do
  
  it 'should be able to be english be defualt' do
    visit '/en'

    expect(page).to have_content 'Language'
  end

  it 'should be able to show hebrew' do
    visit '/he'

    expect(page).to have_content 'שפה'
  end

  it 'should be able to show russian' do
    visit '/ru'

    expect(page).to have_content 'Язык'
  end
  
  it 'should be able to be english be defualt' do
    visit ''
    click_link 'Language'
    click_link 'English'

    expect(page).to have_content 'About'
  end

  it 'should be able to show hebrew' do
    visit ''
    click_link 'Language'
    click_link 'עברית'

    expect(page).to have_content 'שפה'
  end

  it 'should be able to show russian' do
    visit ''
    click_link 'Language'
    click_link 'Русский'

    expect(page).to have_content 'Язык'
  end
end
