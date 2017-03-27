# The defaults are hooked up to the "Core app development" environment in
# Mixpanel, so you can test Mixpanel stuff without having to push to staging.

MIXPANEL_API_KEY = ENV['MIXPANEL_API_KEY'] || '25ad50c63c3d211b7ff1778f55c25bed '
MIXPANEL_API_SECRET = ENV['MIXPANEL_API_SECRET'] || '1d780c449c865d729da548286fe1db1c '
MIXPANEL_TOKEN = ENV['MIXPANEL_TOKEN'] || '05a30c487f3f60afa2e2a3876a4c05d6'
MP_HOMPAGE_TAG_VERSION=ENV['MP_HOMPAGE_TAG_VERSION'] || "8/1/2016"
MIXPANEL_FUNNEL_REPORTS={"Tile Creation" => ENV['MIXPANEL_TILE_CREATION_FUNNEL_ID'] || 2169726}
AIRBO_ORG_ID=ENV['AIRBO_ORG_ID']
MIXPANEL_EXCLUDED_ORGS=ENV['MIXPANEL_EXCLUDED_ORGS'] || []

$mixpanel_client = Mixpanel::Client.new( api_key: ENV['MIXPANEL_API_KEY'],  api_secret: ENV['MIXPANEL_API_SECRET'])
