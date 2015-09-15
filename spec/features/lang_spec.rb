require 'rails_helper'

describe 'Language' do
  
  it 'should be able to show english under /en' do
    visit '/en'

    expect(page).to have_content 'Language'
  end

  it 'should be able to show hebrew under /he' do
    visit '/he'

    expect(page).to have_content 'שפה'
  end

  it 'should be able to show russian under /ru' do
    visit '/ru'

    expect(page).to have_content 'Язык'
  end
  
  it 'should be able to choose english by link' do
    visit ''
    click_link 'Language'
    click_link 'English'

    expect(page).to have_content 'About'
  end

  it 'should be able to choose hebrew by link' do
    visit ''
    click_link 'Language'
    click_link 'עברית'

    expect(page).to have_content 'שפה'
  end

  it 'should be able to choose russian by link' do
    visit ''
    click_link 'Language'
    click_link 'Русский'

    expect(page).to have_content 'Язык'
  end
end
