class Book < ApplicationRecord
  belongs_to :author
  has_many :categories_books, dependent: :destroy
  has_many :categories, through: :categories_books
end
