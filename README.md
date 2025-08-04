# Bank ATM Transaction API

This README would normally document whatever steps are necessary to get the
application up and running.

## Models

### Customer

The Customer model represents bank customers with the following attributes:

- **name** (required, max 250 characters): Customer's full name
- **address** (required, max 250 characters): Customer's street address
- **city** (required): Customer's city
- **state** (required, exactly 2 characters): Customer's state abbreviation (e.g., "CA", "NY")
- **zipcode** (required, US postal code format): Customer's ZIP code (e.g., "12345" or "12345-6789")

#### Validations

- Name and address must be present and no longer than 250 characters
- City must be present
- State must be exactly 2 characters
- Zipcode must match US postal code format (5 digits or ZIP+4 format)

#### Example Usage

```ruby
# Valid customer
customer = Customer.new(
  name: "John Doe",
  address: "123 Main St",
  city: "Anytown",
  state: "CA",
  zipcode: "12345"
)

# Using FactoryBot in tests
customer = FactoryBot.create(:customer)
```

## Testing

This application uses RSpec for testing with FactoryBot for generating test data.

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/customer_spec.rb

# Run tests with documentation format
bundle exec rspec --format documentation
```

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...
