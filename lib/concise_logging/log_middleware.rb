module ConciseLogging
  class LogMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = ActionDispatch::Request.new(env)
      Thread.current[:logged_ip] = request.env['HTTP_X_REAL_IP'] || request.ip
      status, headers, response = @app.call(env)

      if defined?(Rails) && headers["Content-Type"] =~ /^application\/json/ && AppInfo.first.show_json_log
        obj = JSON.parse(response.body)
        pretty_str = JSON.pretty_unparse(obj)
        Rails.logger.debug("Response: " + pretty_str)
      end
      [status, headers, response]
      ensure
      Thread.current[:logged_ip] = nil
    end

  end

end
