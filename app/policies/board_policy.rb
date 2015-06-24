class BoardPolicy < ApplicationPolicy


 def tile_suggestion_enabled?
	 user.is_site_admin?
 end

end
