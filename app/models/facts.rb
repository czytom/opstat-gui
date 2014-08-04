class Facts
  include MongoMapper::Document
  set_collection_name "opstat.parsers.facts"
  key :timestamp, Time
  timestamps!


  def self.chart_data(options = {})
    facter_data = {}
    self.find(:all,:order => "timestamp desc", :conditions => [ 'timestamp >= ? and ip_address = ? and hostname = ?',options[:start], options[:ip_address], options[:hostname]]).each do |data|
      facter_data[data[:name]] ||= data[:value]
    end
    { :facter_data => facter_data }
  end
    
  def self.get_fact(options = {})
    Facts.last( {:host_id => options[:host_id], :name => options[:name] })
  end

  def self.legend
    @legend = {}
  end
end
