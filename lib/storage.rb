
require 'mongo'
require 'config'

module Netmento
  module Storage

    class Entity
      def self.attr_stored(attrName)
        attr_accessor(attrName)
      end
      
      attr_stored(:_id)
    end


    
    class Storage
      attr_reader(:dbName)
    
      def initialize( )
        @dbName = Config::dbName
        @db = Mongo::MongoClient.new[Config::dbName]
      end
      
      def createUser(user)
        @db.collection("users").save(user)
      end
    end
    
  end
end