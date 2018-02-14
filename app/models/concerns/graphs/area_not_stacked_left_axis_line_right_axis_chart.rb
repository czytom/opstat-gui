=begin
module Graphs
 module AreaNotStackedLeftAxisLineRightAxisChart
  def self.included(base)
    base.extend(ClassMethods)
  end

    chart_data = {
               :graph_data => [],
               :graphs => self.graphs,
               :title => "#{pool} FPM pool statistic",
               :category_field => 'timestamp',
               :title_size => 20,
               :guides => {}
             }

  module ClassMethods
   def chart_structure(properties)
    properties['category_field'] ||= 'timestamp'
    chart = {
               :value_axes => properties[:axes]
               :graph_data => [],
	       :category_field => properties['category_field'],
	       :graphs => [],
	       :title => properties[:title],
	       :title_size => 20
	     }

    self.graphs.each_pair do |graph, properties|

      #TODO value_axis
      #TODO merge set values with default
      ##TODO sort by timestamp
      chart_defaults = { :balloon_text => "[[title]]: ([[value]])", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 0.1, :title => graph }
      chart_base = { :value_axis => 'valueAxis1', :value_field => graph, :graph_type => 'line' }
      chart[:graphs] << chart_defaults.merge(properties).merge(chart_base)
    end
    chart
   end
  end
  
 end
end
=end
