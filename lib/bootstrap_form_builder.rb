class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, to: :@template

  # Get full errors for field
  #
  # @param field [Symbol]
  #
  # @return [String]
  def full_errors_for(field)
    errors = @object.errors.full_messages_for(field)
    if errors.length > 0
      content_tag(:div, class: 'text-danger') do
        content = []
        errors.each do |error|
          content.push content_tag(:div, error)
        end

        content.join.html_safe
      end
    end
  end

  # Get form group for field.
  #
  # @param field [Symbol]
  #
  # @return [String]
  def form_group(field)
    form_group_classes = ['form-group']
    form_group_classes.push('has-error') if @object.errors.full_messages_for(field).length > 0
    content_tag(:div, class: form_group_classes.join(' ')) do
      yield if block_given?
    end
  end
end