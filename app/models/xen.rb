class Xen
  include MongoMapper::Document
  set_collection_name "opstat.parsers.xens"
  key :timestamp, Time
  timestamps!


  def self.chart_data(options = {})
    charts = []

    charts << self.memory_chart(options)
  end
  
  def self.vbd_chart(options)
    memory = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => 'Memory in KB',
			    :position => 'left',
			    :stack_type => 'regular',
			    :grid_alpha => 0.07,
			    :min_max_multiplier => 1,
                            :include_guides_in_min_max => 'true'
			  }
			],
	       :category_field => 'timestamp',
               :graph_data => [],
	       :graphs => [],
	       :title => "XEN memory usage",
	       :title_size => 20
	     }
    graphs = []
    Xen.where( 'timestamp >= :timestamp and ip_address = :ip_address and hostname = :hostname', {timestamp: options[:start].localtime, ip_address: options[:ip_address], hostname: options[:hostname]}).group('UNIX_TIMESTAMP(timestamp) div 60, machine').order(:timestamp).select('FROM_UNIXTIME((UNIX_TIMESTAMP(timestamp) div 60) *60,\'%Y-%m-%d %H:%i:%S\') as period_start, machine,max(memory) as memory').group_by{|u| u.period_start}.each_pair do |period_start, machines|
     tmp = { :year => period_start.to_datetime.to_i * 1000 }
     #TODO sort
     machines.each do |machine|
       tmp[machine.machine] = machine.memory
       graphs << machine.machine  unless graphs.include?(machine.machine)
     end
     memory[:graph_data] << tmp
   end
    graphs.each do |graph|
      #TODO value_axis
      memory[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph, :balloon_text => "[[title]]: [[value]] KB", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 1, :graph_type => 'line' }
    end
    memory
  end
  def self.memory_chart(options)
    memory = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => 'Memory in KB',
			    :position => 'left',
			    :stack_type => 'regular',
			    :grid_alpha => 0.07,
			    :min_max_multiplier => 1,
                            :include_guides_in_min_max => 'true'
			  }
			],
	       :category_field => 'timestamp',
               :graph_data => [],
	       :graphs => [],
	       :title => "XEN memory usage",
	       :title_size => 20
	     }
    graphs = []
    Xen.where( {:timestamp => { :$gt => options[:start]}, :host_id => options[:host_id], :plugin_id => options[:plugin_id] }).each do |data|
     tmp = { timestamp: data['timestamp'] }
     #TODO sort
     next if data['domains'].nil?
     data['domains'].each do |domain|
       tmp[domain['name']] = domain['memory']
       graphs << domain['name']  unless graphs.include?(domain['name'])
     end
     memory[:graph_data] << tmp
   end
    graphs.each do |graph|
      #TODO value_axis
      memory[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph, :balloon_text => "[[title]]: [[value]] KB", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 1, :graph_type => 'line' }
    end
    memory
  end

  def self.graphs_defaults
   []
  end

  def self.axes_defaults
    []
  end
end
