class ApplicationController < ActionController::API
  include RethinkDB::Shortcuts

  before_action :create_connection
  after_action :close_connection

  protected

  def create_connection
    @r = RDB_CONFIG[:r]

    begin
      @conn = @r.connect(:host => RDB_CONFIG[:host], :port => RDB_CONFIG[:port], :db => RDB_CONFIG[:db])
    rescue Exception => err
      puts "Cannot connect to RethinkDB database #{RDB_CONFIG[:host]}:#{RDB_CONFIG[:port]} (#{err.message})"
      head 501
    end
  end

  def close_connection
     begin
      @rdb_connection.close if @rdb_connection
    rescue
      puts "Couldn't close connection"
    end
  end
end
