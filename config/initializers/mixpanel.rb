MIXPANEL_TOKEN = case Rails.env
                 when 'development'
                   '05a30c487f3f60afa2e2a3876a4c05d6'
                 when 'staging'
                   '8c5f217f98e1f4cbfeb9b81c2f1aa824'
                 when 'test'
                   'TODO hook me up'
                 when 'production'
                   '0bf0dc3d09bdeb203c0678181a70d99a'
                 end
