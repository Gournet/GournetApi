class Follower < ApplicationRecord
  belongs_to :user
  belongs_to :chef

  def self.follow(user,chef)
    foll = find_or_initialize_by(user_id: user,chef_id: chef)
    foll.save
  end

  def self.unfollow(user,chef)
    foll = where(user_id: user).where(chef_id: chef).first
    if foll
      foll.destroy
    end
    foll
  end
end
