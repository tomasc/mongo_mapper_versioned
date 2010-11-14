module MongoMapper
  module Plugins
    module Versioned

      require 'mongo_mapper'


  
      module ClassMethods
        def versioned(options = {})
          key :versioned_id, ObjectId, :index => true  
          key :version, Integer, :default => 1
        
          before_create :set_versioned_id
          before_update :create_version
          after_destroy :delete_versions
        end
      end



      module InstanceMethods

        # overwrite this method for custom behavior
        # (esp. when dealing with embedded documents)
        def should_create_version?
          self.changed?
        end
        
        # use the versioned_id as default parameter
        def to_parem
          self.versioned_id.to_s
        end
        
        # return all previous versions of this document
        def versions
          Version.versions_of(self).all
        end
        
        
        
        private
        
        # delete all previous versions
        def delete_versions
          Version.collection.remove({:versioned_id => versioned_id})
        end
        
        # loads previous version from the database (= prior to any changes)
        # and dumps its copy into 'versions' collection
        # then increments own version number
        def create_version
          return unless should_create_version?
          if previous_version = self.class.find_by_id(id)
            Version.collection.insert( previous_version.clone.to_mongo )
            self.version += 1
          end
        end
        
        # sets versioned_id (if not defined before)
        # this is an id that will be shared by all versions
        def set_versioned_id
          self.versioned_id ||= BSON::ObjectId.new
        end
        
      end

    end
  end
end
