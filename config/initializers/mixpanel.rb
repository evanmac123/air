MIXPANEL_API_KEY, MIXPANEL_API_SECRET, MIXPANEL_TOKEN = case Rails.env
                 when 'development'
                   %w(25ad50c63c3d211b7ff1778f55c25bed 1d780c449c865d729da548286fe1db1c 05a30c487f3f60afa2e2a3876a4c05d6)
                 when 'staging'
                   %w(2a73773f9efffdfad8a58c9a914a7812 5ab9d3e43228149ba6bfb996e526194a 8c5f217f98e1f4cbfeb9b81c2f1aa824)
                 when 'test'
                   ['TODO hook me up', 'TODO hook me up', 'TODO hook me up']
                 when 'production'
                   %w(c0450e4b987ef8563a0eebb9c5ff17d6 e73ec95f6a7048ff9ebe4d0fe48cdf3a 0bf0dc3d09bdeb203c0678181a70d99a)
                 end
