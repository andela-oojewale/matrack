require "sqlite3"
require "fileutils"

module Matrack
  class DataManger

    class << self

      def db_conn
        db = SQLite3::Database.new "db/app.sqlite3"
        db.results_as_hash = true
        db
      end

      def db_error(message)
        DataUtility.db_error(message)
      end

      def query_builder(name, type, primary, nullable)
        name = name.join
        type = type.join
        primary_key = "PRIMARY KEY" if primary.values.join.to_b == true
        primary_key += " AUTOINCREMENT" if primary_key == true &&
                                           type == "INTEGER"
        primary_key = primary_key ? primary_key : ""
        null_value = nullable.values.join.to_b == true ? "": "NOT NULL"
        "#{name} #{type} #{primary_key} #{null_value}"
      end

      def allowed_field_types
        ["int", "str", "time", "date"]
      end

      def create_table_feilds(table_name, qry_str)
        begin
          db_conn.execute "CREATE TABLE IF NOT EXISTS #{table_name} (#{qry_str});"
        rescue SQLite3::Exception => exp
          puts self.db_error(exp)
          exit
        end
      end

      def verify_col_type(field_hash)
        if field_hash.values.all? { |val| allowed_field_types.include? val.to_s }
          valid_time = DataUtility.timer_checker(field_hash)
          valid_date = DataUtility.date_checker(field_hash)
          return true if valid_time && valid_date
          return "Invalid date or date format. Check documentation."
        end
        "Invalid column type(s) specified"
      end

    end

  end
end