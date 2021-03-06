require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class CalendarRoutesTest < ActionController::TestCase
  tests EventsController

  with_common :calendar_with_events

  paths = %W( /calendars/1/events
              /calendars/1/events/2009
              /calendars/1/events/2009/02
              /calendars/1/events/2009/02/02
              /calendars/1/event/1
              /calendars/1/event/2007
              /calendars/1/categories/jazz )

  paths.each do |path|
    test "regenerates the original path from the recognized params for #{path}" do
      without_routing_filters do
        params = ActionController::Routing::Routes.recognize_path(path, :method => :get)
        assert_equal path, @controller.url_for(params.merge(:only_path => true))
      end
    end
  end

  describe "routing" do
    calendar_id = Calendar.find_by_permalink('calendar-with-events').id.to_s
    category_id = Category.find_by_permalink('jazz').id.to_s

    with_options :path_prefix => '/calendar-with-events/',
        :section_id => calendar_id, :controller => 'events', :action => 'index' do |r|
      r.it_maps :get, ""
      r.it_maps :get, "events/2008", :year => "2008"
      r.it_maps :get, "events/2008/11", :year => "2008", :month => "11"
      r.it_maps :get, "events/2008/11/27", :year => "2008", :month => "11", :day => "27"
      r.it_maps :get, "categories/jazz", :category_id => category_id
    end

    with_options :path_prefix => '/calendar-with-events/',
        :section_id => calendar_id, :controller => 'events', :action => 'show' do |r|
      r.it_maps :get, "event/1", :id => "1"
      r.it_maps :get, "event/2008", :id => "2008"
      r.it_maps :get, "event/a-jazz-concert", :id => 'a-jazz-concert'
    end
  end
end
