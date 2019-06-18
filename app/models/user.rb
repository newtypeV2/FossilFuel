class User < ApplicationRecord
    has_many :active_relationships,  class_name:  "Match",
                                   foreign_key: "swiper_id",
                                   dependent:   :destroy
    has_many :passive_relationships, class_name:  "Match",
                                   foreign_key: "swiped_id",
                                   dependent:   :destroy
    has_many :swiped, through: :active_relationships
    has_many :swipers, through: :passive_relationships
    has_many :hobbie_users
    has_many :hobbies, through: :hobbie_users
    has_one_attached :avatar

    has_secure_password

    # has_many :matches, :foreign_key => "swiper_id"
    # has_many :matches, :foreign_key => "swiped_id"
    # has_many :swiped, through: :matches
    # has_many :swiper, through: :matches

    def swiper_name_collect(array)
        array.collect do |match|
            match.swiper
        end
    end

    def swiped_name_collect(array)
        array.collect do |match|
            match.swiped
        end
    end

    def match_select(array,condition)
        array.select do |match|
            match.gave_chance == condition
        end
    end

    def match_accepted
        match_select(self.active_relationships,true)
    end

    def match_rejected
        match_select(self.active_relationships,false)
    end

    def match_said_yes
        match_select(self.passive_relationships,true)
    end

    def match_said_no
        match_select(self.passive_relationships,false)
    end

    def accepted
        self.swiped_name_collect(self.match_accepted)
    end

    def rejected
        self.swiped_name_collect(self.match_rejected)
    end

    def said_yes
        self.swiper_name_collect(self.match_said_yes)
    end

    def said_no
        self.swiper_name_collect(self.match_said_no)
    end


    def matches
        self.accepted.select do |user|
            self.said_yes.include?(user)
        end
    end

    def available_pool
        return User.all-[self]-self.swiped
    end

    def interested
        return self.said_yes - self.matches
    end

end
