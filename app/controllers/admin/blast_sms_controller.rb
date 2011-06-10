class Admin::BlastSmsController < AdminBaseController
  before_filter :find_demo

  def new
  end

  def create
    params[:send_at].each {|k, v| params[:send_at][k] = v.to_i}
    time_args = [:year, :month, :day, :hour, :minute].map{|field_name| params[:send_at][field_name]}
    send_at = Time.local(*time_args)

    @demo.schedule_blast_sms(params[:message_body], send_at)
    #@demo.users.all.each {|user| SMS.delay(:run_at => send_at).send_message(user.phone_number, params[:message_body])}
    flash[:success] = "Bombs away!"
    redirect_to admin_demo_path(@demo)
  end

  protected

  def find_demo
    @demo = Demo.find(params[:demo_id])
  end
end
