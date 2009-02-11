map.resources              :friendships,
                           :path_prefix => "profiles/:user_id",
                           :name_prefix => "profile_",
                           :controller => 'friendships'

map.resources              :banships,
                           :path_prefix => "profiles/:user_id",
                           :name_prefix => "profile_",
                           :controller => 'banships'