class Client
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps
  store_in collection: "opstat.clients"
  has_many :hosts
  attr_reader :model
  attr_writer :start

  def get_plugin(id)
    plugin = nil
    # TODO switch to some built in search
    self.hosts.each do |host|
      host.plugins.each do |p|
        plugin = p if p['_id'].to_s == id 
      end
    end
    plugin
  end

  def model
    @model ||=  self.plugin.camelize.constantize
    @model
  end

  def chart_data
    self.model.chart_data({:start => @start, :client_id => self.host.client.id})
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

