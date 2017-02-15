module SearchHelper
 def index_elastic_search
   Campaign.reindex
   Tile.reindex
 end
end

include SearchHelper
