# Validator for hour
class HourValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.nil?
      if (/^\d+$/ =~ value.to_s).nil? || value.to_i < 0 || value.to_i > 23
        record.errors.add(attribute, options[:message] || :incorrect_hour)
      end
    end
  end
end