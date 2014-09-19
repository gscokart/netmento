

require "spec_config"
require "user"


module Netmento
  
  describe User do
    it 'load existing users' do
      user1 = User.new
      user1.userId = 'theExistingUser'
      user1.password = 'password'
      Storage.store.persist(user1)
            
      expect(User.login('theExistingUser' , 'password')).to eql(user1)
    end
  end

end