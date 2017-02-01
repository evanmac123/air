module SalesAcquisitionConcern
  def notify_sales(notification_type, user)
    send(notification_type, user)
  end

  def notify_sales_activated(user)
    ping_lead_activation(user)
    SalesNotifier.delay_mail(:lead_activated, user)
  end

  def notify_sales_return(user)
    ping_lead_return_via_invite_link(user)
    SalesNotifier.delay_mail(:lead_returned_via_invite_link, user)
  end

  private

    def ping_lead_activation(user)
      user.rdb[:invite_link_click_count].set(1)
      event = 'Acquisition - Activated via invite link'
      ping_parameters = { link_click_count: user.rdb[:invite_link_click_count].get }

      ping(event, ping_parameters, user)
    end

    def ping_lead_return_via_invite_link(user)
      user.rdb[:invite_link_click_count].incr
      event = 'Acquisition - Clicked invite link subsequent time'
      ping_parameters = { link_click_count: user.rdb[:invite_link_click_count].get }

      ping(event, ping_parameters, user)
    end

    def set_new_lead_for_sales(user)
      org = user.organization
      current_user.rdb[:sales][:leads].sadd(user.id)
      Organization.rdb[:sales][:leads].sadd(user.id)
      current_user.rdb[:sales][:active_orgs_in_sales].sadd(org.id)
      Organization.rdb[:sales][:active_orgs_in_sales].sadd(org.id)
      new_lead_ping(user)
    end

    def new_lead_ping(user)
      event = 'Acquisition - New organization created'
      ping_parameters = { }

      ping(event, ping_parameters, user)
    end

    def current_leads
      orgs = Organization.rdb[:sales][:active_orgs_in_sales].smembers
      Organization.joins(:users).where(id: orgs)
    end

    def my_leads
      orgs = current_user.rdb[:sales][:active_orgs_in_sales].smembers
      Organization.joins(:users).where(id: orgs)
    end
end
