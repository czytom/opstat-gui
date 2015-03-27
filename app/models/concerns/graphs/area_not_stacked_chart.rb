module Graphs
 module AreaNotStackedChart
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
   def chart_structure(properties)
    chart = {
               :value_axes => [
	                  { 
			    :name => "valueAxis1",
			    :title => properties[:value_axis][:title],
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
	       :title => properties[:title],
	       :title_size => 20
	     }

    self.graphs.each_pair do |graph, properties|

      #TODO value_axis
      #TODO merge set values with default
      ##TODO sort by timestamp
      chart[:graphs] << { :value_axis => 'valueAxis1', :value_field => graph, :line_color => properties[:line_color],  :balloon_text => "[[title]]: ([[value]])", :line_thickness => 1, :line_alpha => 1, :fill_alphas => 0.1, :graph_type => 'line' }
    end
    chart
   end
  end
  
 end
end
