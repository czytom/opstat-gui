class Webobjects
  include MongoMapper::Document
  set_collection_name "opstat.parsers.webobjects"
  timestamps!

  def self.chart_data(options = {})
    charts = []
    charts = self.all_applications_charts(options)
    return charts
  end

  def self.all_applications_charts(options = {})



    prev = nil
    report_data = Hash.new

    @quant = 60

    chart_data = {}
    instances = Hash.new

    #TODO order by timestamp
    Webobjects.where( { :timestamp => {:$gt => options[:start]} , :host_id => options[:host_id], :plugin_id => options[:plugin_id]} ).each do |data|
      instances[data[:instance]] ||= true
      rounded_timestamp = data[:timestamp].to_i - ( data[:timestamp].to_i % @quant )
      report_data[:sessions] ||= Hash.new
      report_data[:transactions] ||= Hash.new
      report_data[:sessions][rounded_timestamp] ||= Hash.new
      report_data[:transactions][rounded_timestamp] ||= Hash.new

      #TODO resolve problems with breaks in data series for each instance
      report_data[:sessions][rounded_timestamp][data[:instance]] = data[:sessions] 
      report_data[:transactions][rounded_timestamp][data[:instance]] = data[:transactions]
    end

    prev = nil
    chart_data[:tps] ||= []
    report_data[:transactions].each do |timestamp, data_hash|
      if prev.nil? then
        prev = { :timestamp =>  timestamp, :data_hash => data_hash }
        next
      end
      
      time_diff = timestamp.to_i - prev[:timestamp].to_i
      temp = {}
      data_hash.each_pair do |instance, transactions|
        next if prev[:data_hash][instance].nil?
	tps = ((transactions - prev[:data_hash][instance])/time_diff.to_f).round(3)
	next if tps < 0
        temp[instance] = tps
      end
      temp["timestamp"] = timestamp.to_i * 1000
      chart_data[:tps] << temp

      prev = { :timestamp =>  timestamp, :data_hash => data_hash }
    end
 
    chart_data[:sessions] ||= []
    report_data[:sessions].each do |timestamp, data_hash|
      temp = data_hash
      temp["timestamp"] = timestamp.to_i * 1000
      chart_data[:sessions] << temp
    end




    tps = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => 'Transactions per sec',
			    :position => 'left',
			    :min_max_multiplier => 1,
			    :stack_type => 'regular',
                            :include_guides_in_min_max => 'true',
			    :grid_alpha => 0.1
			  }
			],
               :graph_data => [],
	       :category_field => 'timestamp',
	       :graphs => [],
	       :title => "Transactions per second",
	       :title_size => 20
	     }

    instances.keys.each do |graph|
      #TODO value_axis
      #TODO merge set values with default
      ##TODO sort by timestamp
      tps[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph.to_s,  :balloon_text => "[[title]]: ([[value]])", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 0.1, :graph_type => 'line' }
    end

    sessions = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => 'Number of sessions',
			    :position => 'left',
			    :min_max_multiplier => 1,
			    :stack_type => 'regular',
                            :include_guides_in_min_max => 'true',
			    :grid_alpha => 0.1
			  }
			],
               :graph_data => [],
	       :category_field => 'timestamp',
	       :graphs => [],
	       :title => "Number of sessions",
	       :title_size => 20
	     }

    instances.keys.each do |graph|
      #TODO value_axis
      #TODO merge set values with default
      ##TODO sort by timestamp
      sessions[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph, :balloon_text => "[[title]]: ([[value]])", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 0.1, :graph_type => 'line' }
    end
    sessions[:graph_data] = chart_data[:sessions]
    tps[:graph_data] = chart_data[:tps]
    [tps,sessions]
  end
    
  def self.axes_defaults
    {
      :sessions => {
        :value_axis => {:title => 'Sessions'}
      },
      :tps => {
        :value_axis => {:title => 'Transactions per second'}
      }

    }
  end

  def self.legend
    @legend = {}
  end
end
Webobjects.ensure_index( [ [:timestamp, 1], [:host_id, 1] , [:plugin_id,1] ] )