

module Netmento
  
  class User < Entity
    use_collection_name 'users'
  
    attr_stored(:userId)
    attr_stored(:password)
    attr_stored(:name)
    attr_stored(:email)
    attr_stored(:trust)
    
    def initialize()
      #TODO: Add support for 1-n relationship (even if we should avoid it, we still need it in some case)
      @trust = []
    end
    
  end
  
end