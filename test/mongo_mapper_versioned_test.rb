require 'test_helper'



# CLASS SETUP

class VersionedDoc
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned
  
  key :title, String
  key :body, String
  
  versioned :ignored_keys => ['body']
end


# TESTS

class VersionedTest < ActiveSupport::TestCase
  
  context "by default" do
    setup do
      @doc = VersionedDoc.new
    end
    should "be on version 0" do
      assert_equal 0, @doc.version_number
    end
    should "have 0 versions" do
      assert_equal 0, @doc.versions.count
    end
    should "be last version" do
      assert @doc.last_version?
    end
    context "after initial save" do
      setup do
        @doc.save
      end
      should "be on version 1" do
        assert_equal 1, @doc.version_number
      end
      should "have 1 version" do
        assert_equal 1, @doc.versions.count
      end
      should "store version 1" do
        assert @doc.versions.any?{|v| v.version_number == 1}
      end
      should "be last version" do
        assert @doc.last_version?
      end
    end
    context "after save with changes" do
      setup do
        @doc.title = "poof"
        @doc.save
      end
      should "be on version 1" do
        assert_equal 1, @doc.version_number
      end
      should "have 1 version" do
        assert_equal 1, @doc.versions.count
      end
      should "store version 1" do
        assert @doc.versions.any?{|v| v.version_number == 1}
      end
      should "be last version" do
        assert @doc.last_version?
      end
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
      assert_equal 1, @doc.versions.count
    end
    should "be last version" do
      assert @doc.last_version?
    end
    
    context "when saved with no changes" do
      setup do
        @version_count = @doc.versions.count
        @version_number = @doc.version_number
        @doc.save
      end
      should "still be at version 1" do
        assert_equal @version_number, @doc.version_number
      end
      should "not create new version" do
        assert_equal @version_count, @doc.versions.count
      end
      should "be last version" do
        assert @doc.last_version?
      end
    end
    
    context "after a change" do
      setup do
        @version_count = @doc.versions.count
        @version_number = @doc.version_number
        @title = @doc.title
        @doc.update_attributes(:title => "Krabaty")
      end
      should "increase number of versions" do
        assert_equal @version_count+1, @doc.versions.count
      end
      should "increase version number" do
        assert_equal @version_number+1, @doc.version_number
      end
      should "be last version" do
        assert @doc.last_version?
      end
    end
    
  end
  
  context "when reverting" do
    setup do
      @doc = VersionedDoc.create(:title => "Vaclav", :body => "Kroupa")
      @doc.update_attributes(:title => "Slavoj", :body => "Zizek")
      @doc.update_attributes(:title => "Karel", :body => "Martens")
      @doc.update_attributes(:title => "Keren", :body => "Cytter")
      @doc.update_attributes(:title => "Jon", :body => "Arnett")
    end
    
    context "to first version" do
      setup do
        @doc.revert_to(1)
      end
      should "be at version 1" do
        assert_equal 1, @doc.version_number
      end
      should "have correct attributes" do
        assert_equal "Vaclav", @doc.title
      end
      should "not revert ignored attributes" do
        assert_equal "Arnett", @doc.body
      end
      should "not create new version" do
        assert_equal 5, @doc.versions.count
      end
      should "not be last version" do
        assert !@doc.last_version?
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
      should "not revert ignored attributes" do
        assert_equal "Arnett", @doc.body
      end
      should "not create new version" do
        assert_equal 5, @doc.versions.count
      end
      should "not be last version" do
        assert !@doc.last_version?
      end
      context "after save" do
        setup do
          @doc.save
        end
        should "be at version 6" do
          assert_equal 6, @doc.version_number
        end
        should "have 6 versions" do
          assert_equal 6, @doc.versions.count
        end
        should "be last version" do
          assert @doc.last_version?
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
      should "not revert ignored attributes" do
        assert_equal "Arnett", @doc.body
      end
      should "not create new version" do
        assert_equal 5, @doc.versions.count
      end
    end
    
  end
end
