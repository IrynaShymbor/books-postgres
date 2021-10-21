class CategoriesBook < ApplicationRecord
  belongs_to :category
  belongs_to :book
end
