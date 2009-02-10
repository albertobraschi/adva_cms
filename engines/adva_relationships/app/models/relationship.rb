class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :relation, :class_name => 'User', :foreign_key => :relation_id
  
  ACCEPTED  = 'accepted'
  REQUESTED = 'requested'
  PENDING   = 'pending'
  DECLINED  = 'declined'
  
  named_scope :accepted,  :conditions => ['state = ?', ACCEPTED]
  named_scope :pending,   :conditions => ['state = ?', PENDING]
  named_scope :requested, :conditions => ['state = ?', REQUESTED]
  
  def self.request(user, requested_user, kind = :symmetric)
    return false if (user == requested_user) || exists?(user, requested_user)
    case kind
      when :symmetric   then symmetric_request(user, requested_user)
      when :asymmetric  then asymmetric_request(user, requested_user)
      else false
    end
  end
  
  def self.exists?(user, related_user)
    !! find_by_user_id_and_relation_id(user, related_user)
  end
  
  def self.instance(user, relation)
    find_by_user_id_and_relation_id(user, relation)
  end
  
  def request_accept
    return false unless pending? && self.class.exists?(relation, user)
    
    transaction do
      self.class.instance(relation, user).update_attribute(:state, ACCEPTED)
      self.update_attribute(:state, ACCEPTED)
    end
  end
  
  def request_decline
    return false unless pending? && self.class.exists?(relation, user)
    
    !!transaction do
      self.class.instance(relation, user).destroy
      self.destroy
    end
  end
  
  def remove
    transaction do
      self.class.instance(relation, user).destroy if symmetric?
      self.destroy
    end
  end
  
  def symmetric?
    self.class.exists?(user, relation) && self.class.exists?(relation, user)
  end
  
  def asymmetric?
    self.class.exists?(user, relation) ^  self.class.exists?(relation, user)
  end
  
  def pending?
    state == PENDING || state == REQUESTED
  end
  
  def accepted?
    state == ACCEPTED
  end
  
  protected
    def self.symmetric_request(user, requested_user)
      transaction do
        create(:user => user, :relation => requested_user, :state => REQUESTED)
        create(:user => requested_user, :relation => user, :state => PENDING)
      end
    end
  
    def self.asymmetric_request(user, requested_user)
      create(:user => user, :relation => requested_user, :state => ACCEPTED)
    end
end