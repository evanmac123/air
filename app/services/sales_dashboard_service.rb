class SalesDashboardService
  attr_reader :user

  def initialize(user = nil)
    @user = user
  end

  def lead_activation_rate_by_user
    if users_in_sales_by_sales_person.count > 0
      activated_users_in_sales_by_sales_person.count.to_f / users_in_sales_by_sales_person.count
    else
      0
    end
  end

  def lead_activation_rate
    if users_in_sales.count > 0
      activated_users_in_sales.count.to_f / users_in_sales.count
    else
      0
    end
  end

  def org_ids_in_sales_by_user
    user.rdb[:sales][:active_orgs_in_sales].smembers
  end

  def org_ids_in_sales
    Organization.rdb[:sales][:active_orgs_in_sales].smembers
  end

  def users_in_sales
    @users_in_sales ||= User.joins(:organization).where(is_site_admin: false).where(organization: { id: org_ids_in_sales } )
  end

  def users_in_sales_by_sales_person
    @users_in_sales_by_sales_person ||= User.joins(:organization).where(is_site_admin: false).where(organization: { id: org_ids_in_sales_by_user } )
  end

  def activated_users_in_sales
    users_in_sales.where(user_arel_table[:accepted_invitation_at].not_eq(nil))
  end

  def activated_users_in_sales_by_sales_person
    users_in_sales_by_sales_person.where(user_arel_table[:accepted_invitation_at].not_eq(nil))
  end

  def user_arel_table
    User.arel_table
  end
end
