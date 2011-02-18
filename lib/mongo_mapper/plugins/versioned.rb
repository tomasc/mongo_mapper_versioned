module MongoMapper
  module Plugins
    module Versioned
      
      extend ActiveSupport::Concern



      # ----------------------------------------------------------------------
      module ClassMethods
        def versioned(options={})
          configuration = { :ignored_keys => %w(_id version_number) }
          configuration[:ignored_keys].concat(options[:ignored_keys]).uniq if options.key?(:ignored_keys)
          
          key   :version_number, Integer, :default => 1, :index => true
          many  :versions, :class => MongoMapper::Plugins::Versioned::Version, :foreign_key => :versioned_id, :dependent => :destroy, :order => :version_number.asc

          after_create  :create_version, :if => :should_create_initial_version?
          before_update :create_version, :if => :should_create_version?
          
          define_method "ignored_keys" do
            configuration[:ignored_keys]
          end
        end
      end
      
      
      
      # ----------------------------------------------------------------------
      module InstanceMethods
        
        def create_version
          self.version_number = self.versions.empty? ? 1 : self.versions.last.version_number+1
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
        
        def should_create_initial_version?
          versions.empty?
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