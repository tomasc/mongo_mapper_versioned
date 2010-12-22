module MongoMapper
  module Plugins
    module Versioned
      class Version

        include MongoMapper::Document
        
        # stores id of versioned document
        key :versioned_id, ObjectId
        
        # stores version number
        key :version_number, Integer
        
        # stores versioned attributes
        key :data, Hash

      end
    end
  end
end