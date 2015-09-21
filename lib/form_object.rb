# Basic module for form objects.
module FormObject
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model

    # Scope to localize errors and attribute names.
    #
    # @return [Symbol]
    def self.i18n_scope
      :form_object
    end
  end
end