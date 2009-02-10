site = Site.find_by_name('site with sections')
moderator   = User.find_by_first_name('a moderator')
user        = User.find_by_first_name('a user')
banned_user = User.create! :first_name => 'the banned user',
                           :email => 'the-banned-user@example.com',
                           :password => 'a password',
                           :verified_at => Time.now
                           
Friendship.request(user, moderator)
Banship.request(user, banned_user)