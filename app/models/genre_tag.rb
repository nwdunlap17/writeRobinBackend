class GenreTag < ApplicationRecord
    belongs_to :story
    belongs_to :genre
end
