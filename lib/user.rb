

module Netmento

  module Storage
  
    class User < Entity
      use_collection_name 'users'
    
      attr_stored(:userId)
      attr_stored(:password)
      attr_stored(:name)
      attr_stored(:email)
      attr_stored(:trust)
      
      def initialize()
        @trust = []
      end
      
    end
  
  end

end