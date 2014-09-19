
require 'mongo'
require 'config'
require 'set'

module Netmento

  class Entity
    
    def initialize ( )
      raise "collectionName must be defined.  Please invoke use_collection_name class method" \
        unless self.class.class_variable_defined?(:@@collectionName)
      Storage.store.addDirty(self)
    end
  
    def self.attr_stored(attrName)
      attr_accessor(attrName)
      class_variable_set(:@@fields, fields.push(attrName))
    end
    
    def to_hash
      result = Hash.new
      self.class.fields().each { |field| result[field] = self.instance_variable_get(("@" + field.to_s).to_sym) }
      result[:_id] = @_id if  @_id
      return result
    end
    
    def eql? (other)
      return self.equal?(other) || self.to_hash().eql?(other.to_hash())
    end
    
    def self.use_collection_name(colName) 
      class_variable_set(:@@collectionName, colName)
    end
    
    def self.fields() 
      if class_variable_defined?(:@@fields) 
        return class_variable_get(:@@fields) 
      else
        return []
      end
    end
    
    def collectionName
      self.class.class_variable_get(:@@collectionName)
    end
    
    attr_accessor(:_id)

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
    
    def flush()
      @dirty.each { |entity|
        persist(entity)
      }
    end
    
    def persist ( entity )        
      raise TypeError unless entity.is_a?(Entity)
      entity._id = @db.collection(entity.collectionName).save(entity.to_hash)
      @dirty.delete(entity)
    end
    
    def find ( collectionClass , id)        
      return find_one(collectionClass, {"_id" => id})
    end
    
    def find_one ( collectionClass , query)
      colName = collectionClass.class_variable_get(:@@collectionName)
      hash = @db.collection(colName).find_one(query)
      ##TODO If this entity is already loaded, I should maybe reuse the same
      return createFromHash(collectionClass, hash)
    end
    
    
    def createFromHash( collectionClass, hash)
      result = collectionClass.new
      hash.each { |key, value| 
        result.instance_variable_set(eval(":@"+key), value)
      }
      return result
    end
    
  end
    
end