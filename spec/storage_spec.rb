
require "storage"
require "config"

module Netmento

  module Config
    def self.dbName; "rspec" end
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
    
    it 'provides map of values' do
      class MyEntity < Storage::Entity
        attr_stored(:aField)
      end
      subject = MyEntity.new
      subject.aField = 33
      expect(subject.to_hash).to include(:aField => 33)
    end
  end

end
