module SecurityConcern
  def force_ssl
    # TODO: ummmm why not just config.force_ssl = true??
    return true unless prod_or_testing_ssl_outside_of_prod
    redirect_required = false
    unless request.subdomain.present?
      redirect_required = true
    end
    unless request.ssl?
      redirect_required = true
    end

    if redirect_required
      redirect_hostname = hostname_with_subdomain
      redirection_parameters = {
        :protocol   => 'https',
        :host       => redirect_hostname,
        :action     => action_name,
        :controller => controller_name
      }.reverse_merge(params)

      redirect_to redirection_parameters
      return false
    end
  end

  def prod_or_testing_ssl_outside_of_prod
    Rails.env.production? || $test_force_ssl
  end

  # Used since our *.hengage.com SSL cert does not cover plain hengage.com.
  def hostname_with_subdomain
    request.subdomain.present? ? request.host : "www." + request.host
  end

  def disable_framing
    response.headers['X-Frame-Options'] = frame_option
  end

  def frame_option
    @allow_same_origin_framing ? 'SAMEORIGIN' : 'DENY'
  end

  def disable_mime_sniffing
    response.headers['X-Content-Type-Options'] = 'nosniff'
  end

  def allow_same_origin_framing
    @allow_same_origin_framing = true
  end
end
