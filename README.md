# CascadeValidator

CascadeValidator is an ActiveModel validator that allows you to validate associated models and cascade their validation errors to the parent model. It supports both single associations and collections, making it perfect for form objects that aggregate multiple models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cascade_validator'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cascade_validator

## Usage

### Basic Usage

```ruby
class User
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :email

  validates :name, presence: true
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

  attr_accessor :user, :user_credentials

  validates :user, cascade: true
  validates :user_credentials, cascade: true
end

# Usage
user = User.new(name: '', email: 'invalid-email')
credentials = UserCredentials.new(password: 'short', password_confirmation: 'different')
registration = UserRegistration.new(user: user, user_credentials: credentials)

registration.valid? # => false
registration.errors[:user]
# => ["Name can't be blank and Email is invalid"]
registration.errors[:user_credentials]
# => ["Password is too short (minimum is 8 characters) and Password confirmation doesn't match Password"]
```

### Working with Collections

CascadeValidator automatically handles collections of objects:

```ruby
class OrderItem
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :product_name, :quantity

  validates :product_name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
end

class Order
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :items

  validates :items, cascade: true
end

# Usage
items = [
  OrderItem.new(product_name: 'Widget', quantity: 5),
  OrderItem.new(product_name: '', quantity: -1)
]
order = Order.new(items: items)

order.valid? # => false
order.errors[:items]
# => ["Product name can't be blank and Quantity must be greater than 0"]
```

### Using Validation Contexts

You can specify a validation context to use when validating the associated models:

```ruby
class Article
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :content

  validates :title, presence: true
  validates :content, presence: true, length: { minimum: 100 }, on: :publish
end

class ArticleForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :article

  validates :article, cascade: { context: :publish }
end

# Usage
article = Article.new(title: 'My Article', content: 'Short content')
form = ArticleForm.new(article: article)

form.valid? # => false
form.errors[:article]
# => ["Content is too short (minimum is 100 characters)"]
```

### Features

- **Automatic nil handling**: If the associated object is nil, validation is skipped
- **Collection support**: Automatically detects and validates collections (arrays, etc.)
- **Struct support**: Properly handles Struct objects (treats them as single objects, not collections)
- **Context support**: Pass validation contexts to associated models
- **Clear error messages**: Aggregates all error messages from associated models

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/cascade_validator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).