require 'rails_helper'

describe ApplicationHelper do
  describe '#full_title' do
    it 'should return default title with no arguments' do
      expect(full_title).to eq 'Ruby Moon'
    end

    it 'should add print correct title when argument is received' do
      expect(full_title('Home')).to eq 'Home | Ruby Moon'
    end
  end
end