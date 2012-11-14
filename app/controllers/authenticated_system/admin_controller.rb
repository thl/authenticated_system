module AuthenticatedSystem
  class AdminController < AclController
    def initialize
      super
      @guest_perms = []
    end
    
    def index
    end
  end
end
