class Plugin 
  include MongoMapper::Document
  set_collection_name "opstat.plugins"
  timestamps!
  key :host_id
  belongs_to :host
  attr_reader :model
  attr_writer :start

  def model
    @model ||=  self.name.camelize.constantize
    @model
  end

  def chart_data(params)
    case params[:period]
    when "last_hour"
      start = Time.now - 3600
    when "6h"
      start = Time.now - (3600 * 6)
    when "1d"
      start = Time.now - (3600 * 24)
    when "7d"
      start = Time.now - (3600 * 24 * 7)
    when "30d"
      start = Time.now - (3600 * 24 * 7 * 30)
    else
      start = Time.now - 3600
    end
    self.model.chart_data({:host_id => self.host_id, :start => start, :plugin_id => self.id})
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
