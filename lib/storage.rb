
require 'mongo'
require 'config'
require 'set'

module Netmento
  module Storage

    class Entity
      @@fields = []
      
      def initialize ()
        Storage.store.addDirty(self)
      end
    
      def self.attr_stored(attrName)
        attr_accessor(attrName)
        @@fields.push attrName
      end
      
      def to_hash
        result = Hash.new
        @@fields.each { |field| result[field] = 33 }
        return result
      end
      
      attr_stored(:_id)
    end


    
    class Storage
      attr_reader(:dbName)
      attr_reader(:dirty)
    
      def initialize( )
        @dbName = Config::dbName
        @db = Mongo::MongoClient.new[Config::dbName]
        @dirty = Set.new
      end
      
      def self.store
        #TODO how to avoid memory/connection leak => How the the object finalize when not reachable
        Thread.current['netmento.storage.store'] ||= Storage.new        
      end
      
      def addDirty( entity )
        raise TypeError unless entity.is_a?(Entity)
        @dirty.add(entity)
      end
    end
    
  end
end