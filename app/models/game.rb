class Game < ApplicationRecord
  has_one :chatroom

  belongs_to :white, class_name: "User"
  belongs_to :black, class_name: "User"
end