# Let's do some black voodoo magic and have a :tag option for finders
ActiveRecord::Base.class_eval do
  class << self
    VALID_FIND_OPTIONS << :tags
  end
end

WillPaginate::Finder::ClassMethods.class_eval do
  alias :wp_count_without_tags :wp_count unless method_defined? :wp_count_without_tags
  def wp_count(options, *args)
    wp_count_without_tags(options.except(:tags), *args)
  end
end

Paperclip::Attachment.interpolations.merge! \
  :photo_file_url  => proc { |data, style| data.instance.url(style)  },
  :photo_file_path => proc { |data, style| data.instance.path(style) }

class Photo < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/public"
  
  acts_as_role_context :parent => Section
  acts_as_taggable
  
  belongs_to_author
  belongs_to :section
  belongs_to :site
  has_many_comments :polymorphic => true
  has_many :sets, :source => 'category', :through => :category_assignments # I wonder why this works :/re
  has_many :category_assignments, :as => :content
  
  # Some Content black magic
  class_inheritable_reader    :default_find_options
  write_inheritable_attribute :default_find_options, { :order => 'published_at' }
  
  has_attached_file :data, :styles => { :large => "600x600>", # :medium => "300x300>", 
                                        :thumb => "120x120>", :tiny => "50x50#" },
                           :url    => ":photo_file_url",
                           :path   => ":photo_file_path"

  before_validation :set_site
  before_save :ensure_unique_filename
  
  validates_presence_of :site_id, :title
  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 30.megabytes

  delegate :comment_filter, :to => :site
  delegate :accept_comments?, :to => :section

  class << self
    def base_url
      '/photos'
    end

    def base_dir(site)
      Site.multi_sites_enabled ?
        "#{root_dir}/sites/#{site.perma_host}/photos" :
        "#{root_dir}/photos"
    end

    def find_every(options)
      options = default_find_options.merge(options)
      if tags = options.delete(:tags)
        options = find_options_for_find_tagged_with(tags, options.update(:match_all => true))
      end
      super options
    end
  end
  
  def draft?
    published_at.nil?
  end
  
  def published?
    !published_at.nil? and published_at <= Time.zone.now
  end

  def pending?
    !published?
  end

  def state
    pending? ? :pending : :published
  end

  def base_url(style = :original, fallback = false)
    style = :original unless style == :original or File.exists?(path(style))
    [self.class.base_url, filename(style)].to_path
  end

  def path(style = :original)
    [self.class.base_dir(site), filename(style)].to_path
  end

  def filename(style = :original)
    style == :original ? data_file_name : [basename, style, extname].to_path('.')
  end

  def basename
    data_file_name.gsub(/\.#{extname}$/, "")
  end

  def extname
    File.extname(data_file_name).gsub(/^\.+/, '')
  end
  
  protected
    
    def set_site
      self.site ||= section.site
    end

    def ensure_unique_filename
      if new_record? || changes['data_file_name']
        basename, extname = self.basename, self.extname
        i = extname =~ /^\d+\./ ? $1 : 1
        while File.exists?(path)
          self.data_file_name = [basename, i, extname].to_path('.')
          i += 1
        end
      end
    end
end