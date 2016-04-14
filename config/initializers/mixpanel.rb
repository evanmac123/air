# The defaults are hooked up to the "Core app development" environment in
# Mixpanel, so you can test Mixpanel stuff without having to push to staging.

MIXPANEL_API_KEY = ENV['MIXPANEL_API_KEY'] || '25ad50c63c3d211b7ff1778f55c25bed '
MIXPANEL_API_SECRET = ENV['MIXPANEL_API_SECRET'] || '1d780c449c865d729da548286fe1db1c '
MIXPANEL_TOKEN = ENV['MIXPANEL_TOKEN'] || '05a30c487f3f60afa2e2a3876a4c05d6'
MP_HOMPAGE_TAG_VERSION=ENV['MP_HOMPAGE_TAG_VERSION'] || "3/17/2016"
