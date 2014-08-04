class Plugin 
  include MongoMapper::Document
  set_collection_name "opstat.plugins"
  timestamps!
  attr_reader :model
  attr_writer :start

  def model
    @model ||=  self.plugin.camelize.constantize
    @model
  end

  def chart_data
    self.model.chart_data({:ip_address => self.ip_address, :start => @start, :hostname => self.hostname})
  end

  def axes_properties
    self.model.axes_defaults
  end

  def graphs_properties
    self.model.graphs_defaults
  end

  def chart_properties
    self.model.graphs_defaults
  end

  alias_method :charts, :chart_data

end
