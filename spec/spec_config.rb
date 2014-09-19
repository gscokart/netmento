
require 'config'
require 'mongo'

Mongo::MongoClient.new["rspec"].collections.each { |c| c.drop }

module Netmento

  module Config
    def self.dbName; "rspec" end
  end

end