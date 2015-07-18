class BoardSettingsController < ApplicationController
	def show
		if request.xhr?
			user = UserInHeaderPresenter.new(current_user, @public_tile_page, params, request)
			render partial: 'shared/board_settings/user_settings_body', locals: {user: user}, layout: false
			return
		end
	end
end
