class Admin::Sales::InvitesController < AdminBaseController
  def new
    lead_contact = LeadContact.includes(user: :demo).find(params[:lead_contact_id])

    current_user.move_to_new_demo(lead_contact.user.demo.id)

    redirect_to client_admin_share_path
  end
end
