class Client
  include MongoMapper::Document
  set_collection_name "opstat.clients"
  many :hosts
  timestamps!
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

class Host
  include MongoMapper::EmbeddedDocument
  many :plugins
  timestamps!
  embedded_in :client
end

class Plugin
  include MongoMapper::EmbeddedDocument
  timestamps!
  embedded_in :host
  attr_reader :model

  def client_data
    plugin.host.client
  end

  def model
    @model ||=  self.name.camelize.constantize
    @model
  end

  def chart_data(options)
    self.model.chart_data(options)
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
