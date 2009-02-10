class RelationshipSweeper < CacheReferences::Sweeper
  observe Relationship
  
  def after_save(relationship)
    expire_cached_pages_by_reference(relationship)
  end

  alias after_destroy after_save
end