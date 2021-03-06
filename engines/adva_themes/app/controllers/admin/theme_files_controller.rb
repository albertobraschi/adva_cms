class Admin::ThemeFilesController < Admin::BaseController
  layout "admin"

  before_filter :set_theme
  before_filter :set_file, :only => [:show, :update, :destroy]

  guards_permissions :theme, :update => [:index, :show, :new, :create, :import, :upload, :edit, :update, :destroy]

  def show
  end

  def new
    @file = Theme::Template.new :theme => @theme
  end

  def create
    @file = @theme.files.build(params[:file])
    if @file.save
      expire_pages_by_site!
      expire_template!(@file)
      flash[:notice] = t(:'adva.theme_files.flash.create.success')
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.create.failure')
      render :action => :new
    end
  end

  def upload
    @file = @theme.files.build(params[:file])
    if @file.save
      expire_pages_by_site!
      expire_template!(@file)
      flash[:notice] = t(:'adva.theme_files.flash.create.success') # FIXME import.failure
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.create.failure') # FIXME import.failure
      render :action => :import
    end
  end

  def update
    if @file.update_attributes params[:file]
      expire_pages_by_site! # FIXME could expire cached assets individually
      expire_template!(@file)
      flash[:notice] = t(:'adva.theme_files.flash.update.success')
      redirect_to admin_theme_file_path(@site, @theme.id, @file.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.update.failure')
      render :action => :show
    end
  end

  def destroy
    if @file.destroy
      expire_pages_by_site! # FIXME could expire cached assets individually
      expire_template!(@file)
      flash[:notice] = t(:'adva.theme_files.flash.destroy.success')
      redirect_to admin_theme_path(@site, @theme.id)
    else
      flash.now[:error] = t(:'adva.theme_files.flash.destroy.failure')
      render :action => :show
    end
  end

  private

    def expire_pages_by_site!
      expire_site_page_cache
    end

    def expire_template!(file)
      # expires compiled actionview templates from memory
      # see lib/theme_support/compiled_template_expiration
      FileUtils.touch(@theme.path) if file.is_a?(Theme::Template) && File.directory?(@theme.path)
    end

    def set_theme
      @theme = @site.themes.find(params[:theme_id]) or raise "can not find theme #{params[:theme_id]}"
    end

    def set_file
      @file = @theme.files.find params[:id]
      raise "can not find file #{params[:id]}" unless @file and @file.valid?
    end
end
