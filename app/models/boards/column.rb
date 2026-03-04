# frozen_string_literal: true

module Boards
  class Column < ApplicationRecord
    include Trackable
    self.table_name = "columns"

    belongs_to :board, class_name: "Boards::Board"
    has_many :cards, -> { order(:position) }, class_name: "Boards::Card", dependent: :destroy

    validates :name, presence: true
  end
end
