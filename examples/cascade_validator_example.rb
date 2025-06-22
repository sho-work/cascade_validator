# frozen_string_literal: true

require 'active_model'
require_relative '../lib/validators/cascade_validator'

# Example 1: Basic usage with user registration
class User
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :email

  validates :name, presence: true, length: { minimum: 2 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

class UserCredentials
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :password, :password_confirmation

  validates :password, presence: true, length: { minimum: 8 }
  validates :password_confirmation, presence: true
  validate :passwords_match

  private

  def passwords_match
    return if password == password_confirmation

    errors.add(:password_confirmation, "doesn't match Password")
  end
end

class UserRegistration
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :user, :user_credentials, :terms_accepted

  validates :user, cascade: true
  validates :user_credentials, cascade: true
  validates :terms_accepted, acceptance: true
end

# Example usage
puts "=== Example 1: User Registration ==="
user = User.new(name: 'J', email: 'invalid-email')
credentials = UserCredentials.new(password: 'short', password_confirmation: 'different')
registration = UserRegistration.new(
  user: user,
  user_credentials: credentials,
  terms_accepted: false
)

if registration.valid?
  puts "Registration is valid!"
else
  puts "Registration errors:"
  registration.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
end

puts "\n=== Example 2: Valid Registration ==="
valid_user = User.new(name: 'John Doe', email: 'john@example.com')
valid_credentials = UserCredentials.new(password: 'password123', password_confirmation: 'password123')
valid_registration = UserRegistration.new(
  user: valid_user,
  user_credentials: valid_credentials,
  terms_accepted: true
)

if valid_registration.valid?
  puts "Registration is valid!"
else
  puts "Registration errors:"
  valid_registration.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
end

# Example 3: Working with collections
class OrderItem
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :product_name, :quantity, :price

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end

class Order
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :items, :customer_email

  validates :items, cascade: true
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

puts "\n=== Example 3: Order with Multiple Items ==="
items = [
  OrderItem.new(product_name: 'Widget', quantity: 5, price: 10.99),
  OrderItem.new(product_name: '', quantity: -1, price: 20.50),
  OrderItem.new(product_name: 'Gadget', quantity: 2, price: -5)
]

order = Order.new(items: items, customer_email: 'invalid@email')

if order.valid?
  puts "Order is valid!"
else
  puts "Order errors:"
  order.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
end

# Example 4: Using validation contexts
class Article
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :content, :author

  validates :title, presence: true
  validates :content, presence: true, length: { minimum: 100 }, on: :publish
  validates :author, presence: true, on: :publish
end

class ArticleForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :article, :category

  validates :article, cascade: { context: :publish }
  validates :category, presence: true
end

puts "\n=== Example 4: Context-based Validation ==="
draft_article = Article.new(title: 'My Article', content: 'Short content', author: nil)
form = ArticleForm.new(article: draft_article, category: 'Tech')

if form.valid?
  puts "Article form is valid!"
else
  puts "Article form errors:"
  form.errors.full_messages.each do |error|
    puts "  - #{error}"
  end
end