module ApplicationHelper
  # Get full title for page.
  def full_title(title = '')
    postfix = t('project_name')
    if title.empty?
      postfix
    else
      "#{title} | #{postfix}"
    end
  end
end
