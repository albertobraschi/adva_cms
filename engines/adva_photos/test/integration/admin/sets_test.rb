require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper' ))

class SetsTest < ActionController::IntegrationTest
  def setup
    super
    @site = use_site! 'site with sections'
    @album = Album.find_by_permalink('an-album')
    @photo = @album.photos.find_by_title('a photo without set')
    @set = @album.sets.first
  end
  
  test 'an admin visits the sets page' do
    login_as_admin
    visit_album_backend
    click_link 'Sets'
    display_sets
  end
  
  test 'an admin creates a new set' do
    login_as_admin
    visit_album_backend
    click_link 'Sets'
    click_link 'Create a new set'
    display_set_new_form
    fill_in_and_submit_new_set_form
  end
  
  test 'an admin edits the set' do
    login_as_admin
    visit_album_backend
    click_link 'Sets'
    click_link_edit_set
    display_set_edit_form
    fill_in_and_submit_edit_set_form
  end
  
  test 'an admin destroy the set' do
    login_as_admin
    visit_album_backend
    click_link 'Sets'
    click_link_delete_set
  end
  
  test 'an admin assigns a photo to the set' do
    login_as_admin
    visit_photo_edit_form
    assign_photo_to_set_and_submit_form
  end
  
  test 'an admin unassigns a photo from the set' do
    @photo.sets << @set; @photo.reload
    
    login_as_admin
    visit_photo_edit_form
    unassign_photo_from_set_and_submit_form
  end
  
  def visit_album_backend
    get admin_photos_path(@site, @album)
  end
  
  def visit_photo_edit_form
    get edit_admin_photo_path(@site, @album, @photo)
    assert_template 'admin/photos/edit'
  end
  
  def click_link_edit_set
    click_link "category_#{@set.id}_edit"
  end
  
  def click_link_delete_set
    sets_count = @album.sets.size
    
    click_link "category_#{@set.id}_delete"
    
    @album.reload
    assert @album.sets.size == sets_count - 2 # - 2 because given set has a subset
  end
  
  def display_sets
    assert_template 'admin/sets/index'
  end
  
  def display_set_new_form
    assert_template 'admin/sets/new'
  end
  
  def display_set_edit_form
    assert_template 'admin/sets/edit'
  end
  
  def fill_in_and_submit_new_set_form
    sets_count = @album.sets.size
    
    fill_in       :title, :with => 'Winter'
    click_button  'Save'
    
    @album.reload
    assert @album.sets.size == sets_count + 1
  end
  
  def fill_in_and_submit_edit_set_form
    fill_in       :title, :with => 'Winter Edit'
    click_button  'Save'
    
    @album.reload
    assert @album.sets.first.title == 'Winter Edit'
  end
  
  def assign_photo_to_set_and_submit_form
    check         @set.title
    click_button  'Update'
    
    @photo.reload
    assert @photo.sets == [@set]
  end
  
  def unassign_photo_from_set_and_submit_form
    uncheck         @set.title
    click_button    'Update'
    
    @photo.reload
    assert @photo.sets.empty?
  end
end