# frozen_string_literal: true

module RailsData::Roo

  def set_headers(hash = {})
    if hash[:smart]
      @headers = {}
      @header_line = 1

      row1 = row(first_row)
      row1.each_with_index do |col, index|
        if (index < row1.length - 1 && col == row1[index + 1]) || (index == row1.length - 1 && col == row1[index - 1])
          obj = "#{col}·#{row(first_row + 1)[index]}"
          @header_line = first_row + 1
        else
          obj = col
        end

        if headers.keys.include?(obj)
          @headers.merge! "#{obj} #{index}" => index + 1
        else
          @headers.merge! obj => index + 1
        end
      end
    else
      super
    end
  end

end

Roo::Base.prepend RailsData::Roo
