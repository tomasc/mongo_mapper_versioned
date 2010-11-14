require 'test_helper'



# CLASS SETUP

class VersionedDoc
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned
  
  key :title, String
  
  versioned
end


# TESTS

class HmmTest < ActiveSupport::TestCase
  
  context "by default" do
    setup do
      @doc = VersionedDoc.new
    end
  
    should "be on version 1" do
      assert_equal @doc.version, 1
    end
  
    should "have 0 versions" do
      assert_equal @doc.versions.count, 0
    end
  end
  
  context "when created" do
    setup do
      @doc = VersionedDoc.create(:title => "Famfula")
    end
    
    should "be on version 1" do
      assert_equal @doc.version, 1
    end
  
    should "have 0 versions" do
      assert_equal @doc.versions.count, 0
    end
    
    context "when saved with no changes" do
      setup do
        @version_count = @doc.versions.count
        @version_number = @doc.version
      end
      
      should "still be at version 1" do
        @doc.save
        assert_equal @version_number, @doc.version
      end
      
      should "not create new version" do
        @doc.save
        assert_equal @version_count, @doc.versions.count
      end
    end
    
  end
  
end
