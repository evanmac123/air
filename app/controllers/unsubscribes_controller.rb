class UnsubscribesController < ApplicationController

  skip_before_filter :authorize

  def new
    @user = User.find(params[:user_id])
    @token = params[:token]
    @user.ping_page 'unsubscribe'
    render :layout => 'external'
  end

  def show
    render :layout => 'external'
  end

  def create
    @user = User.find(params[:unsubscribe][:user_id])
    @reason = params[:unsubscribe][:reason] || ''
    if EmailLink.validate_token(@user, params[:unsubscribe][:token])
      answer = tell_sendgrid_to_unsub(@user)
      @user.ping 'unsubscribed'
      if answer.include? 'success'
        Unsubscribe.create(user: @user, reason: @reason)
        render :show, :layout => 'external'
      else
        raise "unable to unsubscribe user. Received: '#{answer}'"
      end
    end
  end

  protected

  def fetch_url(in_url)
    url = URI.parse(in_url)

    r = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        http.get url.request_uri, 'User-Agent' => 'Hengage'
    end

    if r.is_a? Net::HTTPSuccess
      r.body
    else
      nil
    end
  end

  def tell_sendgrid_to_unsub(user)
    url = Unsubscribe.url(user)
    fetch_url(url)
  end
end
