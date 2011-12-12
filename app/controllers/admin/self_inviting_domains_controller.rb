class Admin::SelfInvitingDomainsController < AdminBaseController
  before_filter :find_demo_by_demo_id

  def index
    @domain = SelfInvitingDomain.new
    @existing_domains = @demo.self_inviting_domains.order("domain ASC")
  end

  def create
    new_domain = SelfInvitingDomain.new(params[:self_inviting_domain].merge(:demo_id => @demo.id))

    if new_domain.save
      @domain = SelfInvitingDomain.new
    else
      @domain = new_domain
      flash[:failure] = "Problem saving self inviting domain: #{new_domain.errors.full_messages.to_sentence}"
    end
      
    redirect_to :action => :index
  end

  def destroy
    @self_inviting_domain = SelfInvitingDomain.find(params[:id])
    @self_inviting_domain.destroy
    flash[:success] = "#{@self_inviting_domain.domain} destroyed"

    redirect_to :action => :index
  end
end
