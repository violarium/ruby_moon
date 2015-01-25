module ApplicationHelper
  # Get full title for page.
  def full_title(title = '')
    postfix = 'Ruby Moon'
    if title.empty?
      postfix
    else
      "#{title} | #{postfix}"
    end
  end
end
