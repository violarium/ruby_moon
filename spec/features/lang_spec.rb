require 'rails_helper'

describe 'Language' do

  it 'should be able to show english under /' do
    visit '/'

    expect(page).to have_content 'Language'
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

  it 'should be able to choose russian by link' do
    visit ''
    click_link 'Language'
    click_link 'Русский'

    expect(page).to have_content 'Язык'
  end


  describe 'user locale saving' do
    let(:user) { FactoryGirl.create(:user, password: 'password') }
    before { sign_in_with(user.email, 'password') }

    it 'should save selected language to user note' do
      expect { visit '/ru' }.to change { user.reload.locale }.from(:en).to(:ru)
    end
  end
end
