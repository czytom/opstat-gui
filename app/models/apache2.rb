class Apache2
  include MongoMapper::Document
  set_collection_name "opstat.parsers.apache2s"
  key :timestamp, Time
  timestamps!

  def self.chart_data(options = {})
    charts = []
    charts = self.all_vhosts_charts(options)
    return charts
  end

  def self.all_vhosts_charts(options)
    charts = []
    datas = Apache2.where( {:timestamp => { :$gt => options[:start]}, :host_id => options[:host_id], :plugin_id => options[:plugin_id] }).all
    self.vhosts_requests_per_sec(datas)
    return charts
  end

  def self.vhosts_request_per_sec(datas)
    chart_data = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => 'Request sent per second for #{vhost} vhost',
			    :position => 'left',
			    :min_max_multiplier => 1,
			    :stack_type => 'none',
                            :include_guides_in_min_max => 'true',
			    :grid_alpha => 0.1
			  }
			],
               :graph_data => [],
	       :category_field => 'timestamp',
	       :graphs => [],
	       :title => "#{vhost}: request sent per second",
	       :title_size => 20
	     }

    graphs = {
      :request_sent_per_sec => { :line_color => '#0033FF' },
    }
    
    prev = nil
    datas.each do |data|
      prev = {}
      temp = {}
      data[:vhosts].each do |value|
        status = value[:status]
        unless prev.has_key?(status) then
          prev[status] = value 
          next
        end
      
        time_diff = value[:timestamp].to_i - prev[status][:timestamp].to_i
          bytes_sent_per_sec = ((value[:bytes_sent] - prev[status][:bytes_sent])/time_diff.to_f).round(3)
          requests_per_sec = ((value[:requests] - prev[status][:requests])/time_diff.to_f).round(3)
	#Interpolation of no data intervals
	if bytes_sent_per_sec < 0
	  prev[status] = value
	  next
	end
       
        chart_data[vhost] ||= {}
        chart_data[vhost][:statuses] ||= {}
        chart_data[vhost][:chart_data] ||= {}

        temp[:bytes_sent_per_sec] ||= {}
	unless temp[:bytes_sent_per_sec].has_key?(value[:timestamp])
          temp[:bytes_sent_per_sec][value[:timestamp]] = {:year => value[:timestamp].to_i * 1000}
	  chart_data[vhost][:statuses].keys.each do |s|
            temp[:bytes_sent_per_sec][value[:timestamp]][s] = 0
	  end
	end
        temp[:requests_per_sec] ||= {}
	unless temp[:requests_per_sec].has_key?(value[:timestamp])
          temp[:requests_per_sec][value[:timestamp]] = {:year => value[:timestamp].to_i * 1000}
	  chart_data[vhost][:statuses].keys.each do |s|
            temp[:requests_per_sec][value[:timestamp]][s] = 0
	  end
	end
        chart_data[vhost][:statuses][status] = true
        temp[:bytes_sent_per_sec][value[:timestamp]][status] = bytes_sent_per_sec 
        temp[:requests_per_sec][value[:timestamp]][status] = requests_per_sec 
        prev[status] = value
      end
      chart_data[vhost][:chart_data][:bytes_sent_per_sec] = temp[:bytes_sent_per_sec].values
      chart_data[vhost][:chart_data][:requests_per_sec] = temp[:requests_per_sec].values
    end

    graphs.each_pair do |graph, properties|
      chart_data[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph, :line_color => properties[:line_color],  :balloon_text => "[[title]]: ([[value]])", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 0.1, :graph_type => 'line' }
    end
    chart_data
  end

  def self.vhost_requests_chart(vhost, values)
    chart_data = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => "Domain #{vhost} stats",
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
	       :title => "Domain #{vhost} stats",
	       :title_size => 20
	     }

    graphs = {
      :requests_per_sec => { :line_color => '#FF0000' },
      :bytes_sent_per_sec => {:line_color => '#00FF00' }
    }
    
    chart_data[:graph_data] = values

    graphs.each_pair do |graph, properties|
      #TODO value_axis
      #TODO merge set values with default
      ##TODO sort by timestamp
      chart_data[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph, :line_color => properties[:line_color],  :balloon_text => "[[title]]: ([[percents]]%)", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 0.1, :graph_type => 'line' }
    end
    chart_data
  end

  def self.chart_data_deprecated(options = {})
    chart_data = {}
    report_data = Hash.new



    p options
    Apache2.find(:all,:order => 'timestamp', :conditions => ['timestamp >= ? and ip_address = ? and hostname = ?',options[:start].localtime, options[:ip_address], options[:hostname]]).group_by{|u| u.vhost}.each_pair do |vhost, values|
      prev = {}
      temp = {}
      values.each do |value|
        status = value[:status]
        unless prev.has_key?(status) then
          prev[status] = value 
          next
        end
      
        time_diff = value[:timestamp].to_i - prev[status][:timestamp].to_i
          bytes_sent_per_sec = ((value[:bytes_sent] - prev[status][:bytes_sent])/time_diff.to_f).round(3)
          requests_per_sec = ((value[:requests] - prev[status][:requests])/time_diff.to_f).round(3)
	#Interpolation of no data intervals
	if bytes_sent_per_sec < 0
	  prev[status] = value
	  next
	end
       
        chart_data[vhost] ||= {}
        chart_data[vhost][:statuses] ||= {}
        chart_data[vhost][:chart_data] ||= {}

        temp[:bytes_sent_per_sec] ||= {}
	unless temp[:bytes_sent_per_sec].has_key?(value[:timestamp])
          temp[:bytes_sent_per_sec][value[:timestamp]] = {:year => value[:timestamp].to_i * 1000}
	  chart_data[vhost][:statuses].keys.each do |s|
            temp[:bytes_sent_per_sec][value[:timestamp]][s] = 0
	  end
	end
        temp[:requests_per_sec] ||= {}
	unless temp[:requests_per_sec].has_key?(value[:timestamp])
          temp[:requests_per_sec][value[:timestamp]] = {:year => value[:timestamp].to_i * 1000}
	  chart_data[vhost][:statuses].keys.each do |s|
            temp[:requests_per_sec][value[:timestamp]][s] = 0
	  end
	end
        chart_data[vhost][:statuses][status] = true
        temp[:bytes_sent_per_sec][value[:timestamp]][status] = bytes_sent_per_sec 
        temp[:requests_per_sec][value[:timestamp]][status] = requests_per_sec 
        prev[status] = value
      end
      chart_data[vhost][:chart_data][:bytes_sent_per_sec] = temp[:bytes_sent_per_sec].values
      chart_data[vhost][:chart_data][:requests_per_sec] = temp[:requests_per_sec].values
    end
    
    { :chart_data => chart_data }
  end
  
  def self.graphs_defaults
    [
     { :value_field => "200",
       :hidden => false,
       :line_color => "#00FF00",
       :line_thickness => 3,
       :title => "Status 200"},
     { :value_field => "206",
       :hidden => false,
       :line_color => "#00FF88",
       :line_thickness => 3,
       :title => "Status 200"},
     { :value_field => "300",
       :hidden => false,
       :line_color => "#FFFF00",
       :line_thickness => 3,
       :title => "Status 301"},
     { :value_field => "301",
       :hidden => false,
       :line_color => "#FFEE00",
       :line_thickness => 3,
       :title => "Status 300"},
     { :value_field => "302",
       :hidden => false,
       :line_color => "#FFDD00",
       :line_thickness => 3,
       :title => "Status 302"},
     { :value_field => "303",
       :hidden => false,
       :line_color => "#FFAA00",
       :line_thickness => 3,
       :title => "Status 303"},
     { :value_field => "304",
       :hidden => false,
       :line_color => "#FF9900",
       :line_thickness => 3,
       :title => "Status 304"},
     { :value_field => "400",
       :hidden => false,
       :line_color => "#FF8800",
       :line_thickness => 3,
       :title => "Status 400"},
     { :value_field => "403",
       :hidden => false,
       :line_color => "#FF6600",
       :line_thickness => 3,
       :title => "Status 403"},
     { :value_field => "404",
       :hidden => false,
       :line_color => "#FF4400",
       :line_thickness => 3,
       :title => "Status 404"},
     { :value_field => "405",
       :hidden => false,
       :line_color => "#EE0000",
       :line_thickness => 3,
       :title => "Status 405"},
     { :value_field => "406",
       :hidden => false,
       :line_color => "#CC0000",
       :line_thickness => 3,
       :title => "Status 406"},
     { :value_field => "407",
       :hidden => false,
       :line_color => "#BB0000",
       :line_thickness => 3,
       :title => "Status 407"},
     { :value_field => "408",
       :hidden => false,
       :line_color => "#AA0000",
       :line_thickness => 3,
       :title => "Status 408"},
     { :value_field => "500",
       :hidden => false,
       :line_color => "#FF0000",
       :line_thickness => 3,
       :title => "Status 500"}
    ]
  end

  def self.axes_defaults
    {
      :requests_per_sec => {
        :value_axis => {:title => 'Requests per second'}
      },
      :bytes_sent_per_sec => {
        :value_axis => {:title => 'Bytes sent per second'} 
      }
    }
  end
end
Apache2.ensure_index( [ [:timestamp, 1], [:host_id, 1] , [:plugin_id,1] ] )
