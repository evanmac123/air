module ExternalHelper
  def get_navbar_link_class(path)
    return "active" if request.path == path
  end

  def get_navbar_link(path)
    request.path == path ? "#" : path
  end
end
