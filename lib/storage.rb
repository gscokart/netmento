
require 'mongo'
require 'config'
require 'set'

module Netmento
  module Storage

    class Entity
      def initialize ()
        Storage.store.addDirty(self)
      end
    
      def self.attr_stored(attrName)
        attr_accessor(attrName)
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