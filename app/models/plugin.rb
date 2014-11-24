class Plugin 
  include MongoMapper::Document
  set_collection_name "opstat.plugins"
  timestamps!
  key :host_id
  belongs_to :host
  attr_reader :model
  attr_writer :start

  def model
    @model ||=  self.type.camelize.constantize
    @model
  end

  def self.chart_data_of_type(params)
    @model = params[:plugin_type]
    case params[:period]
    when "last_hour"
      start = Time.now - 3600
    when "6h"
      start = Time.now - (3600 * 6)
    when "1d"
      start = Time.now - (3600 * 24)
    when "7d"
      start = Time.now - (3600 * 24 * 8)
    when "30d"
      start = Time.now - (3600 * 24 * 7 * 30)
    else
      start = Time.now - 3600
    end
    plugin = params[:plugin_type].camelize.constantize
    plugin.all_sensors_applications_charts({:start => start})
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
