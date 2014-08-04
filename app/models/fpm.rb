class Fpm < ActiveRecord::Base
  self.pluralize_table_names = false

  def self.chart_data(options = {})
    chart_data = {}
    report_data = Hash.new


    Fpm.find(:all,:order => 'timestamp', :conditions => ['timestamp >= ? and ip_address = ? and hostname = ?',options[:start].localtime, options[:ip_address], options[:hostname]]).group_by{|u| u.pool}.each_pair do |pool, values|
      prev = nil
      values.each do |value|
        temp = {}
      
        if prev.nil? then
          prev = value 
          next
	end

        time_diff = value[:timestamp].to_i - prev[:timestamp].to_i
	p value
        accepted_connections_per_sec = ((value[:accepted_connections] - prev[:accepted_connections])/time_diff.to_f).round(3)
	#Interpolation of no data intervals
	if accepted_connections_per_sec < 0
	  prev = value
	  next
	end
       
        chart_data[pool] ||= {}
        chart_data[pool][:chart_data] ||= []
        chart_data[pool][:guides] ||= {}
        chart_data[pool][:guides][:max_active_processes] ||= value[:processes_active_max]
        chart_data[pool][:guides][:max_active_processes] = value[:processes_active_max] if value[:processes_active_max] >  chart_data[pool][:guides][:max_active_processes]

        temp = {:year => value[:timestamp].to_i * 1000}
	temp[:processes_active] = value[:processes_active]
	temp[:processes_idle] = value[:processes_idle]
	temp[:accepted_connections_per_sec] = accepted_connections_per_sec
        prev = value
        chart_data[pool][:chart_data] << temp
      end
    end
    
    { :chart_data => chart_data }
  end
  
  def self.graphs_defaults
    [
     { :value_field => "processes_active",
       :hidden => false,
       :line_color => "#FF0000",
       :line_thickness => 1,
       :fill_alphas => 0.6,
       :title => "Active Processes",
       :value_axis => "valueAxis2"},
     { :value_field => "processes_idle",
       :hidden => false,
       :line_color => "#00FF00",
       :line_thickness => 1,
       :fill_alphas => 0.6,
       :title => "Idle processes",
       :value_axis => "valueAxis2"},
     { :value_field => "accepted_connections_per_sec",
       :hidden => false,
       :line_color => "#0000FF",
       :line_thickness => 3,
       :fill_alphas => 0,
       :title => "Accepted connections per second",
       :value_axis => "valueAxis1"},
    ]
  end

  def self.axes_defaults
    {
      :accepted_connections_per_sec => {
        :value_axis => {:title => 'Accepted connections per second'}
      },
      :processes => {
        :value_axis => {:title => 'Processes'} 
      }
    }
  end
end
