require 'rails_helper'

describe CalendarFormatter do
  describe '#define' do
    it 'returns what it has been set' do
      registry = Registry.instance
      registry.define(:key, 'value')
      expect(registry.get(:key)).to eq 'value'
    end
  end

  describe '#[] - array get' do
    it 'works like get' do
      registry = Registry.instance
      registry.define(:key, 'value')
      expect(registry[:key]).to eq registry.get(:key)
    end
  end

  describe '#define_lazy' do
    it 'returns result of the block' do
      registry = Registry.instance
      registry.define_lazy(:key) do
        'message'
      end
      expect(registry.get(:key)).to eq 'message'
    end

    it 'executes block only when it is called every time' do
      registry = Registry.instance

      obj = double('obj')
      registry.define_lazy(:key) do
        obj.test
      end

      expect(obj).to receive(:test).twice

      registry.get(:key)
      registry.get(:key)
    end
  end

  describe '#export' do
    it 'exports saved values' do
      registry = Registry.instance
      registry.define(:key, 'value')
      expect(registry.export[:key]).to eq 'value'
    end
  end

  describe '#import' do
    it 'imports values' do
      registry = Registry.instance
      registry.define(:key, 'value')
      registry.import(test: 'test')

      expect(registry.get(:key)).to eq 'value'
      expect(registry.get(:test)).to eq 'test'
    end
  end
end