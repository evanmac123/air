class SalesDashboardService
  attr_reader :sales_team

  def initialize
    @sales_team = User.with_role(:sales, :any).uniq
  end

  def org_activation_percent(user = nil)
    if sales_orgs(user).count.nonzero?
      (activated_sales_orgs_count / sales_orgs(user).count) * 100
    else
      sales_orgs(user).count
    end
  end

  def sales_orgs(user = nil)
    Organization.with_role(:sales, user)
  end

  def first_activated_user_from_org(org)
    users = User.arel_table
    org.users.non_site_admin.where(users[:accepted_invitation_at].not_eq(nil)).order(:created_at).limit(1).first
  end

  def org_activated?(org)
    first_activated_user_from_org(org).present?
  end

  def org_activated_at(org)
    if user = first_activated_user_from_org(org)
      user.accepted_invitation_at.strftime("%b %e, %Y")
    end
  end

  def number_of_visits_from_org(org)
    org.users.non_site_admin.map { |user|
      user.rdb[:invite_link_click_count].get.to_i
    }.inject(:+)
  end

  def total_visits_from_sales
    @_total_visits_from_sales ||= sales_orgs.map { |org|
      number_of_visits_from_org(org)
    }.inject(:+)
  end

  def manager_of_org(org)
    sales_team.with_role(:sales, org).pluck(:name).join(",")
  end

  private

    def activated_sales_orgs_count(user = nil)
      activated_sales_orgs(user).count.to_f
    end

    def activated_sales_orgs(user = nil)
      users = User.arel_table
      sales_orgs(user).joins(:users).where(users: { is_site_admin: false}).where(users[:accepted_invitation_at].not_eq(nil)).uniq
    end

    def unactivated_sales_orgs(user = nil)
      organization = Organization.arel_table
      sales_orgs(user).where(organization[:id].not_eq(activated_sales_orgs.pluck(:id)))
    end
end
