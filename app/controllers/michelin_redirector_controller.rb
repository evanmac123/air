class MichelinRedirectorController < ActionController::Metal
  MICHELIN_ENROLLMENT_URL = ENV['MICHELIN_ENROLLMENT_URL'] || 'http://fakemichelinsystemenrollment.com'
  MICHELIN_INCENTIVE_URL = ENV['MICHELIN_INCENTIVE_URL'] || 'http://fakemichelinsystemincentive.com'

  LINK_TYPE_MAPPINGS = {
    "et" => MICHELIN_ENROLLMENT_URL,
    "ie" => MICHELIN_INCENTIVE_URL
  }

  def show
    self.status = 302
    self.headers['Location'] = "#{LINK_TYPE_MAPPINGS[params[:link_type]]}?#{reserialize_params}"
    self.response_body = "Redirecting..."
  end

  protected

  def reserialize_params
    params.reject{|k,v| %w(action controller link_type).include?(k)}.to_param
  end
end
