# Registry class which is singleton and stores values.
class Registry
  include Singleton


  # Define simple value. Like a constant.
  #
  # @param key [Symbol]
  # @param value
  def define(key, value)
    container[key] = value
  end


  # Define value (block required) which will be calculated when it will be need.
  # It will calculate it every time when it will be needed.
  #
  # @param key [Symbol]
  # @param block [Proc]
  def define_lazy(key, &block)
    container[key] = LazyValue.new(&block)
  end


  # Get value.
  #
  # @param key [Symbol]
  #
  # @return
  def get(key)
    value = container[key]
    if value.is_a?(LazyValue)
      value = value.call
    end

    value
  end


  # Get value (hash access).
  #
  # @param key [Symbol]
  #
  # @return
  def [](key)
    get(key)
  end


  # Export all the values.
  # Replacing values of returned hash won't change registry.
  #
  # @return [Hash]
  def export
    container.clone
  end


  # Import hash data to registry
  #
  # @param data [Hash]
  def import(data)
    data.each do |key, value|
      @container[key] = value
    end
  end


  private

  # Get container.
  #
  # @return [Hash]
  def container
    @container ||= {}
  end


  # Class to store lazy value.
  class LazyValue
    def initialize(&block)
      @block = block
    end

    def call
      @block.call
    end
  end
end