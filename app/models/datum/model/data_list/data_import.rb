module Datum
  module Model::DataList::DataImport
    extend ActiveSupport::Concern

    def template
      io = StringIO.new
      workbook = WriteXLSX.new(io)

      sheet = workbook.add_worksheet
      sheet.write_row(0, 0, headers)

      workbook.close
      io.string
    end

    def headers
      export.columns.values.map(&->(i){ i[:header] })
    end

    class_methods do
      def sync
        RailsCom::Imports.imports.each do |klass|
          r = Datum::DataImport.find_or_initialize_by(data_table: klass.to_s)
          r.title = klass.name
          r.save
        end
      end
    end

  end
end
