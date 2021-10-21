# Books Postgresql

**Table of contents**

- [Set up](#set-up)
- [Routes](#routes)
- [Models](#models)
  - [DB tables](#db-tables)
  - [DB associations](#db-associations)
  - [Author model](#author-model)
  - [Book model](#book-model)
  - [Author-Book relationship](#author-book-relationship)
  - [Category model and Category-Book relationship](#category-model-and-category-book-relationship)
- [Seeds file](#seeds-file)

## Set up

1. change into the folder where you want your new project to be, e.g. 

```cd code/rails```

2. create a new rails app using postgresql as the database:

```rails new books -d postgresql```

3. Change into the new project directory and open it in VS Code

```
cd books

code .
```

4. Create database

```
rails db:create

=>
Created database 'books_development'
Created database 'books_test'
```

5. Start rails server

```rails s```

6. Open [localhost:3000](http://localhost:3000), you should see "Yay you're on Rails" page.

###### [Back to top](#books-postgresql)

---

## Routes

Rails can generate restful routes with ```resources```:

```rb
# config/routes.rb

Rails.application.routes.draw do
  resources :books
end
```

If we run ```rails routes -c books```, we'll get 

```
   Prefix Verb   URI Pattern               Controller#Action
    books GET    /books(.:format)          books#index
          POST   /books(.:format)          books#create
 new_book GET    /books/new(.:format)      books#new
edit_book GET    /books/:id/edit(.:format) books#edit
     book GET    /books/:id(.:format)      books#show
          PATCH  /books/:id(.:format)      books#update
          PUT    /books/:id(.:format)      books#update
          DELETE /books/:id(.:format)      books#destroy
```

We don't even have to have the books controller to run this command.

Note that we can use resources only for some actions, e.g.:

```rb
resources :books, only: [:index, :show]
```
 will result in 

 ```
 Prefix Verb URI Pattern          Controller#Action
  books GET  /books(.:format)     books#index
   book GET  /books/:id(.:format) books#show
```

And ```resources :books, except: [:index, :show]``` will result in 

```
   Prefix Verb   URI Pattern               Controller#Action
    books POST   /books(.:format)          books#create
 new_book GET    /books/new(.:format)      books#new
edit_book GET    /books/:id/edit(.:format) books#edit
     book PATCH  /books/:id(.:format)      books#update
          PUT    /books/:id(.:format)      books#update
          DELETE /books/:id(.:format)      books#destroy
```          

###### [Back to top](#books-postgresql)

---

## Models

We are going to create several models: Book, Author, and later we'll have a Category model. We'll need to let Rails know what kind of relationships these models have.

The idea is that an author will have many books, a book will belong to an author. Category and Book will have a many-to-many relationship, with a join table that will handle the references. This way, any book will be able to have many categories, and any category will be able to have many books.

-*-*-*-*-*-*-*-*

### DB tables

For the reference, this is what the tables are going to be like (ideally, I'd need to provide ERDs but maybe next time):

books:
- title: string, not null (null: false)
- author: author_id (fk), not null (null: false)
- category: category_id (fk)

authors:
- first_name: string
- last_name: string, not null (null: false)

categories:
- name: string, not null (null: false)

The *fk* refers to the *foreign key*: it helps us to link the two tables. The primary key (by default it's the ID) is used as the foreign key by default, and Rails takes care of grabbing the primary key and using it as the foreign key, so we don't need to do anything extra to specify it. 

Two tables will have a relationship, where one side will "belong" to the other. So one side of the relationship is the "owner". In one-to-one and one-to-many associations, this means that the second side, which belongs to the "owner", will keep the "owner's" ID as the way to access data on the "owner's" side.

In our case, an author will have many books, and a book will belong to the author, hence we add the aithor's ID as the foreign key to the books table.

###### [Back to top](#books-postgresql)

-*-*-*-*-*-*-*-*

### DB associations

Book: 
- belongs to author 
- has many categories (through books_categories)

Author:
- has many books

Categoriy:
- have many books (through books_categories)

Books_Categories:
- belongs to book
- belongs to category

###### [Back to top](#books-postgresql)

-*-*-*-*-*-*-*-*

### Author model

```rails g model Author first_name:string last_name:string```

Note that if you forget to provide the datatype, it will default to a string.

When we run the above command, a new migration file gets generated in ```db/migrate/```. Open the file and edit it to add the "not null" constrain:

```rb
#  the create_authors migration file

class CreateAuthors < ActiveRecord::Migration[6.0]
  def change
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name, null: false

      t.timestamps
    end
  end
end
```

We can't add the "not null" constrain when we generate a model in the command line.

We are now ready to run the migration.

```rails db:migrate```

Note that schema file was created: ```db/schema.rb```. It is the file that holds all the info about the project's database.

We can check that the model was created properly. Open Rails console and create an author:

```rb
rails c

Author.create(first_name: 'name', last_name: 'shname')
```

You should see an SQL transaction that runs and successfully inserts a new entry into authors table.

To exit the console, type ```exit``` or ```quit``` or press Ctrl-D.

###### [Back to top](#books-postgresql)

-*-*-*-*-*-*-*-*

### Book model

Create book model with references to author.

```rails g model Book title:string author:references```

Open the migration file - note the ```null: false, foreign_key: true``` have been added by rails because we mentioned that these are references.

```rails db:migrate```

We can check that the model was created properly. Open Rails console and create an author:

```rb
rails c

Book.create(title: 'book', author_id: 1)
```

You should see an SQL transaction that runs and successfully inserts a new entry into books table.

###### [Back to top](#books-postgresql)

-*-*-*-*-*-*-*-*

### Author-Book relationship

Note that rails has added the relationship to the Book model:

```rb
# app/models/book.rb

class Book < ApplicationRecord
  belongs_to :author
end
```

But the Author model is empty. The one-to many Author-Book relationship has not been set up properly yet.

We need to mention the association in the Author model:

```rb
# app/models/author.rb

class Author < ApplicationRecord
  has_many :books
end
```

Note that we use singular "author" in ```belongs_to :author```, but we need to pluralize "books" in ```has_many :books``` 

Test that the author-book relationship is working:

```rb
rails c

Author.first.books.create(title: 'Eat ,pray,love')
```

A new book should be created, and it should reference ```author_id``` of ```1```.

We can create a new author and a book at the same time:

```rb
Author.create(first_name: 'Elizabeth', last_name: 'Gilbert').books.create(title: 'Eat, pray,love')
```

-*-*-*-*-*-*-*-*

One more thing we need to do is make sure no "orphaned" entries are left when we delete something.

What happens if we remove Name Shname from our database? There is a book in the database which keeps Name Shname's ID as the foreign key. If this author doesn't exist, what happens to the book? Rails doesn't like this kind of a situation, and if we try to ```delete``` or ```destroy``` an author, we'll get an error:

```ActiveRecord::InvalidForeignKey (PG::ForeignKeyViolation: ERROR:  update or delete on table "authors" violates foreign key constraint "fk_rails_53d51ce16a" on table "books")```

We need to make sure that if an author gets removed from the database, any dependents (or children) get removed, too. Add ```dependent: :destroy``` to author model.

```rb
# app/models/author.rb

class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end
```

Note: ```destroy``` method will need to be used in authors controller: ```delete``` will still return an error.

###### [Back to top](#books-postgresql)
 
---

## Category model and Category-Book relationship

Generate a new model for categories table:

```rails g model Category name:string```

Edit the newly created migration file to add the "not null" constrain on the name:

```rb
#  the create_categories migration file

class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
```

Note how Rails handles plurals: Category - Categories.

-*-*-*-*-*-*-*-*

As mentioned previously, a book can have many categories, and a category can have many books.

We want to set many-to-many relationship between the books table and the categories table. We need a join table for that. This additional table will act as a 3rd party, and it will have entries linking categories IDs to books IDs. 

Let's generate the model. We can call it CategoriesBook or BooksCategory: by convention we combine both models names and pluralize the first one. 

Normally it doesn't matter whether we capitalize the model name when we run the generate command. But in this case we need to either capitalize both Categories and Book, or insert an underscore between them: categories_book, when we run the following command:

```rails g model CategoriesBook category:references book:references```

You will notice that a new migration file was generated, and it includes foreign key references on both lines. Run migrations:

```rails db:migrate```

Two new model files were created, and two new tables were added in the schema file.

-*-*-*-*-*-*-*-*

The categories_book.rb file already has ```belongs_to``` for both tables:

```rb
# app/models/categories_book.rb

class CategoriesBook < ApplicationRecord
  belongs_to :category
  belongs_to :book
end
```

Add ```has_many``` associations to ```app/models/book.rb``` and ```app/models/category.rb```:

```rb
# app/models/book.rb

class Book < ApplicationRecord
  belongs_to :author
  has_many :categories_books
  has_many :categories, through: :categories_books
end
```

```rb
# app/models/category.rb

class Category < ApplicationRecord
  has_many :categories_books
  has_many :books, through: :categories_books
end
```

Note the pluralisation in "has_many" lines.

-*-*-*-*-*-*-*-*

One last step, deal with the orphaned entries. It is enough to add ```dependent: :destroy``` only to the ```categories_books``` lines:

```rb
# app/models/book.rb

class Book < ApplicationRecord
  belongs_to :author
  has_many :categories_books, dependent: :destroy
  has_many :categories, through: :categories_books
end
```

```rb
# app/models/category.rb

class Category < ApplicationRecord
  has_many :categories_books, dependent: :destroy
  has_many :books, through: :categories_books
end
```

###### [Back to top](#books-postgresql)

---

## Seeds file

Seeds file is used to quickly "seed", or populate, the database.

I will use [faker gem](https://github.com/faker-ruby/faker).

```
bundle add faker
```

Add code in the seeds file to create entries in existing tables. Note that in Rails, we don't need to require the gem.

```rb
# db/seeds.rb

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

```

Now let's populate the database from start.

```
rails db:setup
```

The above command creates a database and seeds it with ```rails db:seed```.

Open console and test relations, e.g.

```
Book.last.categories

Category.fourth.books

Author.second.books.last.categories
```

###### [Back to top](#books-postgresql)
