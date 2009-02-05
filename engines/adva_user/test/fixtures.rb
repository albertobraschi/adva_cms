site = Site.find_by_name('site with sections')
moderator = User.find_by_first_name('a moderator')
user      = User.find_by_first_name('a user')

relationship = Relationship.request(user, moderator)