module PluginsHelper
  def link_to_plugin_status(plugin, options )
    case options[:link_description]
      when :host_name then link_description = plugin.host.hostname
      when :plugin_type then link_description = plugin.type
      else link_description = plugin.type
    end
    if plugin['is_alive_time'] != nil && plugin['is_alive_time'] > Time.now
      link_to link_description, plugin_path(plugin['_id']), style: 'color: blue;padding: 1px;margin: 0 0 5px'
    else
      link_to link_description, plugin_path(plugin['_id']), style: 'color: red;padding: 1px;margin: 0 0 5px'
    end
  end
end
