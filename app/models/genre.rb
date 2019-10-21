class Genre < ApplicationRecord
    has_many :genre_tags
    has_many :stories, through: :genre_tags
end
