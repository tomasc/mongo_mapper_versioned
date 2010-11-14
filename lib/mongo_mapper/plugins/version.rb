class MongoMapper::Plugins::Versioned::Version

  include MongoMapper::Document
  
  # returns all versions of document specified by versioned_id or self
  def self.versions_of(value)
    value.respond_to?(:versioned_id) ? versioned_id = value.versioned_id : versioned_id = value
    where(:versioned_id => versioned_id).order(:updated_at.asc)
  end

  def self.at(value)
    where(:version => value)
  end

end