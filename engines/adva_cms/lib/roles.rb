Rbac.define do
  role :anonymous,
       :grant => true

  role :user,
       :grant => :registered?,
       :parent => :anonymous,
       :message => :'adva.roles.errors.messages.not_logged_in'
  role :author,
       :require_context => Content,
       :grant => lambda{|context, user| context && !!context.try(:is_author?, user) },
       :parent => :user,
       :message => :'adva.roles.errors.messages.not_an_author'

  role :moderator,
       :require_context => Section,
       :parent => :author,
       :message => :'adva.roles.errors.messages.not_a_moderator'

  role :admin,
       :require_context => Site,
       :parent => :moderator,
       :message => :'adva.roles.errors.messages.not_an_admin'

  role :superuser,
       :parent => :admin,
       :message => :'adva.roles.errors.messages.not_a_superuser'

  permissions :'show site'          => :admin,
              :'create site'        => :superuser,
              :'update site'        => :admin,
              :'destroy site'       => :superuser,
              :'manage site'        => :admin,

              :'show section'       => :moderator,
              :'create section'     => :admin,
              :'update section'     => :admin,
              :'destroy section'    => :admin,
              :'manage section'     => :admin,

              :'show asset'         => :moderator,
              :'create asset'       => :moderator,
              :'update asset'       => :moderator,
              :'destroy asset'      => :moderator,
              :'manage asset'       => :moderator,

              :'create theme'       => :admin,
              :'update theme'       => :admin,
              :'destroy theme'      => :admin,
              :'manage theme'       => :admin,

              :'manage cached_page' => :admin,

              :'show user'          => :admin,
              :'create user'        => :admin,
              :'update user'        => :admin,
              :'destroy user'       => :admin,
              :'manage user'        => :admin,

              :'manage roles'       => :admin,

              :'show category'      => :moderator,
              :'create category'    => :moderator,
              :'update category'    => :moderator,
              :'destroy category'   => :moderator,
              :'manage category'    => :moderator,

              :'show article'       => :moderator,
              :'create article'     => :moderator,
              :'update article'     => :moderator,
              :'destroy article'    => :moderator,
              :'manage article'     => :moderator,

              :'show wikipage'      => :moderator, # i.e. show in the backend
              :'create wikipage'    => :user,
              :'update wikipage'    => :user,
              :'destroy wikipage'   => :moderator,
              :'manage wikipage'    => :moderator,
              
              :'show topic'         => :moderator,
              :'create topic'       => :user,
              :'update topic'       => :author,
              :'destroy topic'      => :moderator,
              :'moderate topic'     => :moderator,

              :'show board'         => :moderator,
              :'create board'       => :moderator,
              :'update board'       => :moderator,
              :'destroy board'      => :moderator,
              :'moderate board'     => :moderator,

              :'show comment'       => :moderator,
              :'create comment'     => :user,
              :'update comment'     => :author,
              :'destroy comment'    => :moderator,
              :'manage comment'     => :admin,

              :'show post'          => :moderator,
              :'create post'        => :user,
              :'update post'        => :author,
              :'destroy post'       => :moderator,
              :'manage post'        => :admin,

              :'show calendar_event'    => :moderator,
              :'create calendar_event'  => :moderator,
              :'update calendar_event'  => :moderator,
              :'destroy calendar_event' => :moderator,
              :'manage calendar_event'  => :moderator,

              :'show photo'         => :moderator,
              :'create photo'       => :admin,
              :'update photo'       => :admin,
              :'destroy photo'      => :admin,
              :'manage photo'       => :admin
end
