module MongoMapper
  module Plugins
    module Versioned

      module ClassMethods
        def versioned(options={})
          configuration = { :ignored_keys => %w(_id version_number created_at updated_at creator_id updater_id) }
          configuration.update(options) if options.is_a?(Hash)
          
          key   :version_number, Integer, :default => 0, :index => true
          many  :versions, :class => MongoMapper::Plugins::Versioned::Version, :foreign_key => :versioned_id, :dependent => :destroy, :order => :version_number.asc

          after_create  :create_version
          before_update :create_version, :if => Proc.new{ |doc| doc.should_create_version? }
          
          define_method "ignored_keys" do
            configuration[:ignored_keys]
          end
        end
      end
      
      
      
      module InstanceMethods
        
        def create_version
          self.version_number = (versions.empty? ? 1 : versions.last.version_number+1)
          self.versions << current_version
        end
        
        def revert_to(target_version_number)
          return if self.version_number == target_version_number
          if target_version = version_at(target_version_number)
            self.attributes = target_version.data
            self.version_number = target_version.version_number
          end
        end
        
        def last_version?
          return true if versions.empty?
          self.version_number == versions.last.version_number
        end
        
        def current_version
          Version.new(:data => self.attributes.slice!(*ignored_keys), :versioned_id => self.id, :version_number => self.version_number)
        end
    
        def version_at(target_version_number)
          versions.where(:version_number => target_version_number).first
        end
     
        # this method might be overwritten
        # by something more sophisticated (esp. in case of EmbeddedDocuments)
        def should_create_version?
          changes.slice!(*ignored_keys).size > 0
        end
    
      end
    
    end
  end
end