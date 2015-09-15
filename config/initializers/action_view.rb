# File to put settings for action view.

# Disable wrapping fields with error divs. It's useless and make html dirty.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.html_safe
end