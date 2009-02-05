class RelationshipsController < BaseController
  
  before_filter :set_relationship, :only => :show
  
  authenticates_anonymous_user
  
  def index
    @relationships = current_user.relationships
  end
  
  def show
  end
  
  protected
    def set_relationship
      @relationship = current_user.relationships.find params[:relationship_id]
    # FIXME when it is time to fix
    # rescue ActiveRecord::RecordNotFound
    #   flash[:error] = "Relation you requested could not be found."
    #   write_flash_to_cookie # TODO make around filter or something
    end
end