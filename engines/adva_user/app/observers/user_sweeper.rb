class UserSweeper < CacheReferences::Sweeper
  observe User
  
  def after_save(user)
    expire_cached_pages_by_reference(user)
  end

  alias after_destroy after_save
end