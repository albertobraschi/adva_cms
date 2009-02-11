class RelationshipSweeper < CacheReferences::Sweeper
  observe Relationship
  
  def before_save(relationship)
    expire_cached_pages_by_reference(relationship)
  end

  alias before_destroy before_save
end