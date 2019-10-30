class User < ApplicationRecord
    has_secure_password
    validates :username, presence: true, uniqueness: { case_sensitive: false }
    has_many :friendships
    has_many :invitations
    has_many :notifications
    has_many :follows, foreign_key: "following_id"

    def friends_hash 
        all_ships = Friendship.where('USER1 = ? or USER2 = ?',self.id,self.id)
        
        friend_ids_hash = {}

        all_ships.each do |ship|
            if(ship.user1 == self.id)
                friend_ids_hash[ship.user2] = true
            else 
                friend_ids_hash[ship.user1] = true
            end
        end

        return friend_ids_hash
    end

    def friends 

        friends = []

        self.friends_hash.keys.each do |key|
            friend =  User.find(key)
            friends.push({username: friend.username, id: friend.id})
        end

        return friends
    end

    def is_friends_with(userID)
        userID = userID.to_i
        if (!!self.friends_hash[userID])
            return true
        else
            return false
        end
    end

    def is_following_user(userID)
        userID = userID.to_i
        follow = Follow.find_by(user_id: self.id, following_type: "User", following_id: userID
        return (follow != nil)
    end
end
