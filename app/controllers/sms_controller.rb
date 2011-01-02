class SmsController < ActionController::Metal
  def create
    HoptoadNotifier.notify(
      :error_class   => "Received SMS",
      :error_message => "Received SMS",
      :parameters    => params
    )
  end
end
