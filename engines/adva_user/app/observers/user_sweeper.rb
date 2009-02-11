class UserSweeper < CacheReferences::Sweeper
  observe User
  
  def before_save(user)
    # FIXME i think this can be done better when there are real profiles that are site specific
    sites = user.sites
    
    return nil if sites.empty?
    clear_site_profile_cache(sites)
  end

  alias before_destroy before_save
  
  protected
  
    def clear_site_profile_cache(sites)
      profile_index = CachedPage.find_all_by_site_id_and_url(sites, '/profiles')
      expire_cached_pages(site, profile_index)
    end

    def cached_log_message_for(record, pages)
      msg = ["Expired profile pages referenced by #{record.class} ##{record.id}", "Expiring #{pages.size} page(s)"]
      pages.inject(msg) { |msg, page| msg << " - #{page.url}" }.join("\n")
    end
end