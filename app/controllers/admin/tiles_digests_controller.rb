class Admin::TilesDigestsController < AdminBaseController
  def index
    @tiles_digests = TilesDigest.joins(:demo).group(demo: :name).count.sort_by { |name, val| val }.reverse
  end
end
