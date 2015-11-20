module LangHelper
  # Get lang variants for current request params.
  #
  # @param request_params [Hash]
  #
  # @return [Array]
  def lang_variants(request_params)
    variants = []
    User::ALLOWED_LOCALES.each do |locale, name|
      locale_param = I18n.default_locale == locale ? nil : locale
      locale_params = request_params.merge({:locale => locale_param})
      active = I18n.locale == locale

      variants.push({ name: name, params: locale_params, active: active})
    end
    variants
  end
end