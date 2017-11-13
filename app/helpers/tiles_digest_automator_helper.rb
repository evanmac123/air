module TilesDigestAutomatorHelper
  def tiles_digest_automator_save(object)
    if object.persisted?
      "Update"
    else
      "Save"
    end
  end
end
