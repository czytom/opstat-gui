class Host
  include MongoMapper::Document
  set_collection_name "opstat.hosts"
  many :plugins
  timestamps!
end
