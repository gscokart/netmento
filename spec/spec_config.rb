
require 'config'
require 'mongo'

Mongo::MongoClient.new.drop_database("rspec")

module Netmento

  module Config
    def self.dbName; "rspec" end
  end

end