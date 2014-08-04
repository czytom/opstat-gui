config = YAML.load_file(Rails.root.join('config', 'mongo.yml'))
MongoMapper.setup(config, Rails.env, { :logger => (Rails.env.development? ? Rails.logger : nil) })

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end
