module MongoMapper
  module Plugins
    module Versioned
      class Version

        include MongoMapper::Document
        include Comparable
        
        # stores id of versioned document
        key :versioned_id, ObjectId
        
        # stores version number
        key :version_number, Integer
        
        # stores versioned attributes
        key :data, Hash
        
        # allow comparison
        def <=>(other)
          version_number <=> other.version_number
        end

      end
    end
  end
end