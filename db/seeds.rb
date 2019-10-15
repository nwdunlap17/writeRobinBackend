# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(username: 'Alice', password: 'test')
User.create(username: 'Bob', password: 'test')
User.create(username: 'Claire', password: 'test')
User.create(username: 'David', password: 'test')
User.create(username: 'Eve', password: 'test')

s1 = Story.create(title: 'Once upon a time...', user_id: 1)
s2 = Story.create(title: 'A noisy day', user_id: 2)

Submission.create(content: 'Ipsum Lorem Doltem', user_id:3, story_id: 1, position: 1, canon: true)
Submission.create(content: 'Montimo Opero Fulcrum', user_id:4, story_id: 2, position: 1, canon: true)
Submission.create(content: 'Dismis Acarum Sulcrem', user_id:5, story_id: 2, position: 2, canon: true)