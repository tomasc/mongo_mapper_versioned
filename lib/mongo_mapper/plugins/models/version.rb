module MongoMapper
  module Plugins
    module Versioned
      class Version



        # ---------------------------------------------------------------------
        include MongoMapper::Document
        include Comparable
        
        
        
        # IDENTITY MAP
        # ensures that each object gets loaded only once by keeping every loaded object in a map
        plugin MongoMapper::Plugins::IdentityMap
        
        
        
        # ---------------------------------------------------------------------
        # stores id of versioned document
        key :versioned_id, ObjectId
        
        # stores version number
        key :version_number, Integer
        
        # stores versioned attributes
        key :data, Hash



        # ---------------------------------------------------------------------
        # FIXME: this needs to be handled externally
        # ensure_index [[:version_number, 1], [:versioned_id, 1]] 
        


        # ---------------------------------------------------------------------
        # allow comparison
        def <=>(other)
          version_number <=> other.version_number
        end

      end
    end
  end
end