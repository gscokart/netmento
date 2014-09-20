
require "storage"
require "spec_config"


module Netmento

  class MyEntity < Entity
    use_collection_name "MyEntity"
    attr_stored(:aField)
  end

  class MyOtherEntity < Entity
    use_collection_name "MyOtherEntity"
    attr_stored(:anOtherField)
  end

  
  describe Storage do
    it 'conect to rspec database in test' do
      expect(Storage.store.dbName).to eq("rspec")
    end
    
    it 'provides the _id to the persisted entities' do
      entity = MyEntity.new
      Storage.store.persist(entity)
      expect(entity._id).not_to be_nil
    end
    
    it 'can load an entity from its _id' do
      entity = MyEntity.new
      Storage.store.persist(entity)
      expect(Storage.store.find(MyEntity , entity._id)).not_to be_nil
    end

    it 'can load an entity using a query' do
      entity = MyEntity.new
      entity.aField = 'blabla33'
      Storage.store.persist(entity)
      expect(Storage.store.find_one(MyEntity , {:aField => 'blabla33'})).not_to be_nil
    end

    
    it 'persist changes made to an entity' do
      entity = MyEntity.new
      entity.aField = 33
      Storage.store.persist(entity)
      id = entity._id
      entity.aField = 34
      Storage.store.persist(entity)
      expect(entity._id).to eq(id)
      
      expect(Storage.store.find(MyEntity , entity._id).aField).to eq(34)
    end
    
  end
  
  describe Entity do
    it 'has an _id attribute' do
      subject = MyEntity.new
      subject._id = 33
      expect(subject._id).to eq(33)
    end
        
    it 'provides hash of values' do
      subject = MyEntity.new
      subject.aField = 33
      expect(subject.to_hash).to include(:aField => 33)
    end

    it 'compare instances' do
      subject1 = MyEntity.new
      subject2 = MyEntity.new
      subject2.aField = 'otherVal'
      subject1bis = MyEntity.new
      expect(subject1).to eql(subject1)
      expect(subject1).not_to eql(subject2)
      expect(subject2).to eql(subject2)
      expect(subject1).to eql(subject1bis)
    end

    it 'allow subclass to define the collection name' do
      e1 = MyEntity.new
      e2 = MyOtherEntity.new
      expect(e1.collectionName).to eq("MyEntity")
      expect(e2.collectionName).to eq("MyOtherEntity")
    end
    
    it 'has fields for each entity type' do
      MyEntity.new.aField = 1
      expect { MyEntity.new.anOtherField }.to raise_error
    end
  end

end
