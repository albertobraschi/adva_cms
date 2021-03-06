map.section                     'sections/:section_id',
                                :controller   => 'sections',
                                :action       => "index",
                                :conditions => { :method => :get }

map.section_article             'sections/:section_id/articles/:permalink',
                                :controller   => 'sections',
                                :action       => "show",
                                :conditions => { :method => :get }

map.formatted_section_comments  'sections/:section_id/comments.:format',
                                :controller   => 'sections',
                                :action       => "comments",
                                :conditions => { :method => :get }

map.formatted_section_article_comments  'sections/:section_id/articles/:permalink.:format',
                                :controller   => 'sections',
                                :action       => "comments",
                                :conditions => { :method => :get }


map.connect 'admin',            :controller   => 'admin/sites',
                                :action       => 'index',
                                :conditions => { :method => :get }

map.resources :sites,           :controller   => 'admin/sites',
                                :path_prefix  => 'admin',
                                :name_prefix  => 'admin_'

map.resources :sections,        :controller  => 'admin/sections',
                                :path_prefix => 'admin/sites/:site_id',
                                :name_prefix => 'admin_'
                                
# the resources :collection option does not allow to put to the collection url
# so we connect another route, which seems slightly more restful
map.connect                     'admin/sites/:site_id/sections',
                                :controller   => 'admin/sections',
                                :action       => 'update_all',
                                :conditions   => { :method => :put }

map.connect 'cached_pages',     :controller  => 'admin/cached_pages',
                                :action      => 'clear',
                                :path_prefix => 'admin/sites/:site_id',
                                :name_prefix => 'admin_',
                                :conditions  => { :method => :delete }

map.resources :cached_pages,    :controller  => 'admin/cached_pages', # TODO map manually? we only use some of these
                                :path_prefix => 'admin/sites/:site_id',
                                :name_prefix => 'admin_'

map.resources :plugins,         :controller  => 'admin/plugins', # TODO map manually? we only use some of these
                                :path_prefix => 'admin/sites/:site_id',
                                :name_prefix => 'admin_'

map.resources :articles,        :path_prefix => "admin/sites/:site_id/sections/:section_id",
                                :name_prefix => "admin_",
                                :namespace   => "admin/"

map.connect                     'admin/sites/:site_id/sections/:section_id/articles',
                                :controller   => 'admin/articles',
                                :action       => 'update_all',
                                :conditions   => { :method => :put }

map.resources :categories,      :path_prefix => "admin/sites/:site_id/sections/:section_id",
                                :name_prefix => "admin_",
                                :namespace   => "admin/"

map.connect                     'admin/sites/:site_id/sections/:section_id/categories',
                                :controller   => 'admin/categories',
                                :action       => 'update_all',
                                :conditions   => { :method => :put }

map.connect                     'admin/cells.xml', :controller => 'admin/cells', :action => 'index', :format => 'xml'

map.install 'admin/install',    :controller   => 'admin/install'
map.root                        :controller   => 'admin/install' # will kick in when no site is installed, yet
