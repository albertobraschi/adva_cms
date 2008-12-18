require File.dirname(__FILE__) + '/../spec_helper'

describe CalendarEvent do
  include Matchers::ClassExtensions

  before :each do
    @calendar = Calendar.create!(:title => 'Concerts')
    @event = @calendar.events.new(:title => 'The Dodos', :startdate => '2008-11-24 21:30',
      :user_id => 1)
  end

  describe 'class extensions:' do
    it "acts as a taggable" do
      Content.should act_as_taggable
    end
    it 'should sanitize the body_html attribute' do
      CalendarEvent.should filter_attributes(:sanitize => :body_html)
    end

    it 'should not sanitize the body and cached_tag_list attributes' do
      CalendarEvent.should filter_attributes(:except => [:body, :cached_tag_list])
    end

    it 'should set a permalink' do
      @event.permalink.should be_nil
      @event.save!
      @event.permalink.should ==('the-dodos')
    end
  end

  describe 'callbacks' do
    it 'should set published_at to the current time before create' do
      CalendarEvent.before_create.should include(:set_published)
      @event.published_at.should be_nil
      @event.save!
      @event.published_at.should_not be_nil
    end
    it 'should not overwrite published_at' do
      @event.published_at = tomorrow = (Time.zone.now + 1.day)
      @event.save!
      @event.published_at.should ==(tomorrow)
    end
    # tested in detail below
    it 'updates recurring events before saving' do
      CalendarEvent.before_save.should include(:update_recurring_events)
    end
  end
  
  describe 'validations' do
    before :each do
      @event.should be_valid
      @event.save!.should be_true
      @event.reload
    end

    it "must have a title" do
      @event.title = nil
      @event.should_not be_valid
      @event.errors.on("title").should be
      @event.errors.count.should be(1)
    end

    it "must have start datetime" do
      @event.startdate = nil
      @event.should_not be_valid
      @event.errors.on("startdate").should be
      @event.errors.count.should be(1)
    end
    it "must have a start date earlier than the end date" do
      @event.enddate = @event.startdate - 1.day
      @event.should_not be_valid
      @event.errors.on("enddate").should be
      @event.errors.count.should be(1)
    end
  end
  
  describe "relations" do
    it "should have many categories" do
      @event.should have_many(:categories)
    end
    it "should have a location" do
      @event.should belong_to(:location)
    end
    it "should have user bookmarks"
  end
  
  describe "named scopes" do
    before do
      @calendar.events.delete_all
      @cat1 = @calendar.categories.create!(:title => 'cat1')
      @cat2 = @calendar.categories.create!(:title => 'cat2')
      @cat3 = @calendar.categories.create!(:title => 'cat3')
      @elapsed_event = @calendar.events.create!(:title => 'Gameboy Music Club', 
          :startdate => Time.now - 1.day, :user_id => 1, :categories => [@cat1, @cat2]).reload
      @elapsed_event2 = @calendar.events.create!(:title => 'Mobile Clubbing', 
          :startdate => Time.now - 5.hours,  :enddate => Time.now - 3.hour, :user_id => 1, :categories => [@cat1, @cat2]).reload
      @upcoming_event = @calendar.events.create!(:title => 'Jellybeat', 
          :startdate => Time.now + 4.hours, :user_id => 1, :categories => [@cat2, @cat3]).reload
      @running_event = @calendar.events.create!(:title => 'Vienna Jazz Floor 08', 
          :startdate => Time.now - 1.month, :enddate => Time.now + 9.days, :user_id => 1, :categories => [@cat1, @cat3]).reload
      @real_old_event = @calendar.events.create!(:title => 'Vienna Jazz Floor 07', 
          :startdate => Time.now - 1.year, :enddate => Time.now - 11.months, :user_id => 1, :draft => true, :categories => [@cat2]).reload
#      @calendar.reload
    end
    it "should have a elapsed scope" do
      @calendar.events.elapsed.should ==[@elapsed_event2, @elapsed_event, @real_old_event]
    end
    it "should have a recently added scope" do
      @calendar.events.recently_added.should ==[@upcoming_event, @running_event]
    end
    it "should have a published scope" do
      @calendar.events.published.should ==[@elapsed_event, @elapsed_event2, @upcoming_event, @running_event]
    end
    it "should have a by_categories scope" do
      @calendar.events.by_categories(@cat1.id).should ==[@elapsed_event, @elapsed_event2, @running_event]
      @calendar.events.by_categories(@cat2.id).should ==[@elapsed_event, @elapsed_event2, @upcoming_event, @real_old_event]
      @calendar.events.by_categories(@cat3.id).should ==[@upcoming_event, @running_event]
      @calendar.events.by_categories(@cat1.id, @cat2.id).should ==[@elapsed_event, @elapsed_event2, @upcoming_event, @running_event, @real_old_event]
    end
    describe ":upcoming" do
      it "from today on" do
        @calendar.events.upcoming.should ==[@running_event, @upcoming_event]
      end
      it "from tomorrow on" do
        @calendar.events.upcoming(Date.today + 1.day).should ==[@running_event]
      end
      it "for last year" do
        @calendar.events.upcoming(Date.today - 1.year).should ==[@real_old_event]
      end
    end
  end
  
  describe "named scope :search" do
    before :each do
      default_attributes = {:user_id => 1, :location_id => 1, :startdate => Time.now}
      @event_jazz = @calendar.events.create(default_attributes.merge(:title => 'A Jazz concert', :body => 'A band with Sax,Trumpet,Base,Drums'))
      @event_rock = @calendar.events.create(default_attributes.merge(:title => 'Rocking all night', :body => 'A band with Guitar, Base & Drums'))
    end
    it "should have a search scope by title" do
      @calendar.events.search('Jazz', :title).should ==[@event_jazz]
    end
    it "should have a search scope by body" do
      @calendar.events.search('Base', :body).should ==[@event_jazz, @event_rock]
      @calendar.events.search('Guitar', :body).should ==[@event_rock]
    end
  end
  describe "recurring events" do
    it "should have a parent event" do
      @event.should have_many(:recurring_events)
      child_event = @calendar.events.create!(@event.attributes.reject{|k,v| k==:recurrence})
      child_event.should belong_to(:parent_event)
    end
    it "should support daily events"
    it "should support weekly events"
    it "should support monthly events"
    it "should support yearly events"
    it "should support weekdays"
  end
end