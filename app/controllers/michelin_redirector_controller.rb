class MichelinRedirectorController < ActionController::Metal
  MICHELIN_URL = ENV['MICHELIN_URL'] || 'http://fakemichelinsystem.com'

  def show
    self.status = 302
    self.headers['Location'] = "#{MICHELIN_URL}?#{reserialize_params}"
    self.response_body = "Redirecting..."
  end

  protected

  def reserialize_params
    params.reject{|k,v| k == 'action' || k == 'controller'}.to_param
  end
end
