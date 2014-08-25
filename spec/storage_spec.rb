
require "storage"
require "config"

module Netmento

  module Config
    def self.dbName; "rspec" end
  end

  describe Storage::Storage do
  
    it 'conect to rspec database in test' do
      expect(subject.dbName).to eq("rspec")
    end
    
    it 'Save new users' do
      newUser = {:userId => 'userId', :password => 'xxx'}
      subject.createUser(newUser)
    end
  end
  
  describe Storage::Entity do
    it 'has an _id attribute' do
      subject._id = 33
      expect(subject._id).to eq(33)
    end
  end

end
