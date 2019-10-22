class User < ApplicationRecord
    has_secure_password
    validates :username, presence: true, uniqueness: { case_sensitive: false }
    has_many :friendships

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
        friend_ids_hash = self.friends_hash

        friends = []

        friend_ids_hash.keys do |key|
            friend =  User.find(key)
            friends.push({username: friend.username, id: friend.id})
        end

        return friends
    end

    def is_friends_with(userID)
        puts "userID class is #{userID.class}"
        puts "#{self.id} friends with #{userID}?"
        if (!!self.friends_hash[userID])
            puts "true"
            return true
        else
            puts "false"
            return false
        end
    end
end
