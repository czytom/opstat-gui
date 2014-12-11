class Plugin 
  include MongoMapper::Document
  set_collection_name "opstat.plugins"
  timestamps!
  key :host_id
  belongs_to :host
  attr_reader :model, :date_range, :date_range_start, :date_range_end
  attr_writer :start

  def model
    @model ||=  self.type.camelize.constantize
    @model
  end

  def self.chart_data_of_type(params)
    @date_range_start =  Time.now - 3600
    @date_range_end =  Time.now
    if params.has_key?('plugin')
      date_range = params['plugin']
      if date_range.has_key?('date_range_start')
        @date_range_start = Time.parse(date_range['date_range_start']) 
      end
      if date_range.has_key?('date_range_end')
        @date_range_end = Time.parse(date_range['date_range_end']) 
      end
    end
    @model = params[:plugin_type]
    plugin = params[:plugin_type].camelize.constantize
    plugin.all_sensors_applications_charts({:start => @date_range_start, :end => @date_range_end})
  end

  def chart_data(params)
    @date_range_start =  Time.now - 3600
    @date_range_end =  Time.now
    if params.has_key?('plugin')
      date_range = params['plugin']
      if date_range.has_key?('date_range_start')
        @date_range_start = Time.parse(date_range['date_range_start']) 
      end
      if date_range.has_key?('date_range_end')
        @date_range_end = Time.parse(date_range['date_range_end']) 
      end
    end
    self.model.chart_data({:host_id => self.host_id, :start => @date_range_start, :end => @date_range_end, :plugin_id => self.id})
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
