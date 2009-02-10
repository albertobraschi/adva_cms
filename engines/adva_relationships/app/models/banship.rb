class Banship < Relationship
  
  def self.request(user, requested_user, kind = :asymmetric)
    super
  end
end