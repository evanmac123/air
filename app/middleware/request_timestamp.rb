class RequestTimestamp
  def initialize(app)
    @app = app
  end

  def call(env)
    env['rack.timestamp'] = Time.now.to_i
    @app.call(env)
  end
end
