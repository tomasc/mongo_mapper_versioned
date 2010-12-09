require 'test_helper'



# CLASS SETUP

class VersionedDoc
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned
  
  key :title, String
  
  versioned
end


# TESTS

class VersionedTest < ActiveSupport::TestCase
  
  context "by default" do
    setup do
      @doc = VersionedDoc.new
    end
    should "be on version 1" do
      assert_equal 1, @doc.version_number
    end
    should "have 0 versions" do
      assert_equal 0, @doc.version_count
    end
  end
  
  context "when created" do
    setup do
      @doc = VersionedDoc.create(:title => "Famfula")
    end
    should "be on version 1" do
      assert_equal 1, @doc.version_number
    end
    should "have 1 (initial) version" do
      assert_equal 1, @doc.version_count
    end
    
    context "when saved with no changes" do
      setup do
        @version_count = @doc.version_count
        @version_number = @doc.version_number
        @doc.save
      end
      should "still be at version 1" do
        assert_equal @version_number, @doc.version_number
      end
      should "not create new version" do
        assert_equal @version_count, @doc.version_count
      end
    end
    
    context "after a change" do
      setup do
        @version_count = @doc.version_count
        @version_number = @doc.version_number
        @title = @doc.title
        @doc.update_attributes(:title => "Krabaty")
      end
      should "increase number of versions" do
        assert_equal @version_count+1, @doc.version_count
      end
      should "increase version number" do
        assert_equal @version_number+1, @doc.version_number
      end
    end
    
  end
  
  context "when reverting" do
    setup do
      @doc = VersionedDoc.create(:title => "Famfula")
      @doc.update_attributes(:title => "Slavoj")
      @doc.update_attributes(:title => "Karel")
      @doc.update_attributes(:title => "Keren")
      @doc.update_attributes(:title => "Jon")
    end
    
    context "to first version" do
      setup do
        @doc.revert_to(1)
      end
      should "be at version 1" do
        assert_equal 1, @doc.version_number
      end
      should "have correct attributes" do
        assert_equal "Famfula", @doc.title
      end
      should "not create new version" do
        assert_equal 5, @doc.version_count
      end
    end
    
    context "to version 2" do
      setup do
        @doc.revert_to(2)
      end
      should "be at version 2" do
        assert_equal 2, @doc.version_number
      end
      should "have correct attributes" do
        assert_equal "Slavoj", @doc.title
      end
      should "not create new version" do
        assert_equal 5, @doc.version_count
      end
      context "after save" do
        setup do
          @doc.save
        end
        should "be at version 6" do
          assert_equal 6, @doc.version_number
        end
        should "have 6 versions" do
          assert_equal 6, @doc.version_count
        end
      end
      
    end
    
    context "to version 5" do
      setup do
        @doc.revert_to(5)
      end
      should "be at version 5" do
        assert_equal 5, @doc.version_number
      end
      should "have correct attributes" do
        assert_equal "Jon", @doc.title
      end
      should "not create new version" do
        assert_equal 5, @doc.version_count
      end
    end
    
  end
end
