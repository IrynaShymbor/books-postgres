categories = ['Biography', 'Adventure', 'Classics', 'Fantasy', 'Detective and Mistery', 'Horror', 'Historical Fiction', 'Romance']

if Category.count == 0
  categories.each do |category|
    Category.create(name: category)
    puts "created #{category} category"
  end
end

3.times do
  Author.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
end

puts "created authors"


(1..Category.count).each do |n|
  if n > 2
    category_ids = [n / 2, n]
  else
    category_ids = [1, 3, 7]
  end
  
  Book.create(title: Faker::Book.title, author_id: rand(1..3), category_ids: category_ids)

  puts "book #{n} created"
end
