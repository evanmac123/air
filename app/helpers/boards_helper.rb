module BoardsHelper
  include ActionView::Helpers::TextHelper

  def truncate_name_for_switcher(name)
    truncate name, length: 15
  end
end
