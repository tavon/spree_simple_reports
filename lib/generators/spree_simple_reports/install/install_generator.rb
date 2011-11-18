module SpreeSimpleReport
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def add_javascripts
        append_file "app/assets/javascripts/admin/all.js", "//= require admin/spree_simple_reports\n"
      end

      def add_stylesheets
        inject_into_file "app/assets/stylesheets/admin/all.css", " *= require admin/spree_simple_reports\n", :before => /\*\//, :verbose => true
      end

      def add_migrations
      end

      def run_migrations
      end
    end
  end
end
