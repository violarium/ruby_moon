module ApplicationHelper
  # Get full title for page.
  #
  # @param title [String]
  #
  # @return [String]
  def full_title(title = '')
    postfix = t('project_name')
    if title.empty?
      postfix
    else
      "#{title} | #{postfix}"
    end
  end

  # Get text direction CSS-selector for current language.
  #
  # @return [String]
  def text_direction_css
    rtl_languages = [:he]
    if rtl_languages.include?(I18n.locale.to_sym)
      'direction-rtl'
    else
      'direction-ltr'
    end
  end

  # Get human attribute name for active model object.
  #
  # @param object [ActiveModel::Model]
  # @param attribute [Symbol]
  #
  # @return [String]
  def human_attribute(object, attribute)
    object.class.human_attribute_name(attribute)
  end
end
