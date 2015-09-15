{
    :he=> {
        :date => {
		# hebrew adds a letter when a month's name is expressed with a day.
            :month_names => lambda { |key, options|
              if options[:format] && options[:format] =~ /%-?d %B/
                :'date.month_names_with_day'
              else
                :'date.month_names_standalone'
              end
            }
        }
    }
}
