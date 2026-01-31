module Datum
  class Importer
    attr_reader :sheet, :headers

    def initialize(table_list)
      @table_list = table_list
      @sheet_file = table_list.file
      if @sheet_file.filename.extension == '.xlsx'
        @sheet_file.open do |file|
          @xlsx = Xsv.open(file)
        end
      else
        raise '请使用 xlsx 格式!'
      end
      @sheet = @xlsx.sheet(@xlsx.sheets[0])

      @config = @table_list.data_list.export
      @column_index = init_header.compact
    end

    def init_header
      @headers = @config.columns.map { |_, v| v[:header] }
      file_header = @sheet.row(1)

      @headers.map do |header|
        file_header.find_index(header)
      end
    end

    def run
      @table_list.headers = @headers
      @sheet.each do |row|
        @table_list.table_items.build fields: @column_index.map { |index| row[index] }
      end
      @table_list.done = true
      @table_list.save
    end

  end
end
