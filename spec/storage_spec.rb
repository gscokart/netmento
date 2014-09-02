
require "storage"
require "config"

module Netmento

  module Config
    def self.dbName; "rspec" end
  end

  class MyEntity < Storage::Entity
    attr_stored(:aField)
  end

  
  describe Storage::Storage do
    it 'conect to rspec database in test' do
      expect(Storage::Storage.store.dbName).to eq("rspec")
    end
    it 'has an instance per thread' do
      other = nil
      Thread.new {
        other = Storage::Storage.store
      }.join
      expect(Storage::Storage.store).not_to be other
    end
    
    it 'persist all dirty entities' do
      entity = MyEntity.new
      Storage::Storage.store.dirty.add(entity)
      Storage::Storage.store.flush
      #TODO check we have persisted the entity
    end
    
    it 'remove persisted entities from the dirty set of entities' do
      entity = MyEntity.new
      Storage::Storage.store.dirty.add(entity)
      Storage::Storage.store.persist(entity)
      expect(Storage::Storage.store.dirty).not_to include(entity)
    end

    it 'provides the _id to the persisted entities' do
      #TODO
    end
  end
  
  describe Storage::Entity do
    it 'has an _id attribute' do
      subject._id = 33
      expect(subject._id).to eq(33)
    end
    
    it 'register as dirty entity on creation' do
      expect(Storage::Storage.store.dirty).to include(subject)
    end
    
    it 'provides hash of values' do
      subject = MyEntity.new
      subject.aField = 33
      expect(subject.to_hash).to include(:aField => 33)
    end
    
    it 'map to a collection defaulting to the class name' do
      subject = MyEntity.new
      expect(subject.collectionName).to eq("MyEntity")
    end

    it 'allow subclass to define the collection name' do
      class OtherEntity < Storage::Entity
        def initialize()
          super("CollectionName")
        end
      end

      subject = OtherEntity.new
      expect(subject.collectionName).to eq("CollectionName")
    end

    
  end

end
