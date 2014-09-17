
require "storage"
require "config"

module Netmento

  module Config
    def self.dbName; "rspec" end
  end

  class MyEntity < Storage::Entity
    use_collection_name "MyEntity"
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
      expect(Storage::Storage.store.find(MyEntity, entity._id)).not_to be_nil
    end
    
    it 'remove persisted entities from the dirty set of entities' do
      entity = MyEntity.new
      Storage::Storage.store.dirty.add(entity)
      Storage::Storage.store.persist(entity)
      expect(Storage::Storage.store.dirty).not_to include(entity)
    end

    it 'provides the _id to the persisted entities' do
      entity = MyEntity.new
      Storage::Storage.store.persist(entity)
      expect(entity._id).not_to be_nil
    end
    
    it 'can load an entity from its _id' do
      entity = MyEntity.new
      Storage::Storage.store.persist(entity)
      expect(Storage::Storage.store.find(MyEntity , entity._id)).not_to be_nil
    end

    it 'can load an entity using a query' do
      entity = MyEntity.new
      entity.aField = 'blabla33'
      Storage::Storage.store.persist(entity)
      expect(Storage::Storage.store.find_one(MyEntity , {:aField => 'blabla33'})).not_to be_nil
    end

    
    it 'persist changes made to an entity' do
      entity = MyEntity.new
      entity.aField = 33
      Storage::Storage.store.persist(entity)
      id = entity._id
      entity.aField = 34
      Storage::Storage.store.persist(entity)
      expect(entity._id).to eq(id)
      
      expect(Storage::Storage.store.find(MyEntity , entity._id).aField).to eq(34)
    end
    
  end
  
  describe Storage::Entity do
    it 'has an _id attribute' do
      subject = MyEntity.new
      subject._id = 33
      expect(subject._id).to eq(33)
    end
    
    it 'register as dirty entity on creation' do
      subject = MyEntity.new
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
      class FirstEntity < Storage::Entity
        use_collection_name("CollectionName1")
      end
      class OtherEntity < Storage::Entity
        use_collection_name("CollectionName2")
      end
      e1 = FirstEntity.new.collectionName
      e2 = OtherEntity.new.collectionName
      expect(e1).to eq("CollectionName1")
      expect(e2).to eq("CollectionName2")
    end
    
  end

end
