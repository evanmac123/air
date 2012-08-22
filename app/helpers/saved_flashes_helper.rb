module SavedFlashesHelper
  def delete_saved_flashes
    cookies.delete(SavedFlashes::SUCCESS_KEY)
    cookies.delete(SavedFlashes::FAILURE_KEY)
  end
end
