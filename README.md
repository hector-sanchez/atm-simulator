# 🏧 SecureBank ATM System

A modern, full-stack ATM banking application built with Ruby on Rails, featuring a realistic ATM interface, card authentication, transaction processing, and comprehensive account management.

![Rails](https://img.shields.io/badge/Ruby%20on%20Rails-8.0.2-red?logo=rubyonrails)
![Ruby](https://img.shields.io/badge/Ruby-3.4.4-red?logo=ruby)
![License](https://img.shields.io/badge/License-MIT-blue)

## ✨ Features

### 🔐 Authentication & Security
- **Card-based Authentication**: PIN verification system with security lockout
- **Session Management**: Secure ATM sessions with automatic timeout
- **Multi-card Support**: Users can have multiple debit cards per account

### 💳 Transaction Management
- **Cash Withdrawals**: Quick amount buttons ($20, $40, $60, $80, $100, $200) and custom amounts
- **Deposits**: Preset amounts ($50, $100, $200, $300, $500, $1000) and custom amounts
- **Real-time Balance Updates**: Instant account balance updates after transactions
- **Transaction History**: Comprehensive transaction logging with details

### 🏧 ATM Interface
- **Realistic ATM UI**: Modern, responsive design mimicking real ATM interfaces
- **ATM Location Services**: Integrated ATM locator with branch information
- **Modal-based Transactions**: Smooth, interactive transaction dialogs
- **Mobile Responsive**: Works seamlessly on desktop, tablet, and mobile devices

### 📊 Account Management
- **Account Overview**: Balance checking, account information display
- **Transaction History**: Paginated transaction listings with filtering
- **Multiple Account Types**: Support for checking, savings, and other account types
- **Card Management**: Multiple cards per customer with individual status tracking

## 🛠️ Technology Stack

- **Backend**: Ruby on Rails 8.0.2
- **Frontend**: Stimulus.js, Turbo, ERB templates
- **Database**: SQLite (development), PostgreSQL-ready
- **Styling**: Custom CSS with modern ATM-inspired design
- **Testing**: RSpec, FactoryBot
- **Authentication**: Custom card/PIN authentication system

## 🚀 Quick Start

### Prerequisites

- Ruby 3.4.4 or higher
- Rails 8.0.2
- Node.js (for asset compilation)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/bank-atm-transaction-api.git
   cd bank-atm-transaction-api
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install  # or yarn install
   ```

3. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Visit the application**
   Open your browser to `http://localhost:3000`

## 🎮 Demo Credentials

After running `rails db:seed`, you can use these test credentials:

| Card Number | PIN | Account Type | Balance |
|-------------|-----|--------------|---------|
| 1234 5678 9012 3456 | 1234 | Checking | $2,500.00 |
| 2345 6789 0123 4567 | 2345 | Savings | $5,000.00 |
| 3456 7890 1234 5678 | 3456 | Checking | $1,200.00 |

> **Note**: The application automatically seeds realistic test data including customers, accounts, cards, ATM locations, and transaction history.

## 📋 API Documentation

### Authentication Endpoints

```ruby
POST /sessions          # Card authentication
DELETE /logout          # End ATM session
```

### Transaction Endpoints

```ruby
GET /transactions       # View transaction history
POST /transactions      # Process new transaction
```

### ATM Management

```ruby
GET /atm               # ATM dashboard
GET /atm/locate        # ATM location services
```

## 🏗️ Architecture

### Models

- **Customer**: Bank customer information and account relationships
- **Account**: Bank accounts with balance tracking and transaction history
- **Card**: Debit cards with PIN authentication and status management
- **Transaction**: Financial transactions with ATM location tracking
- **ATM Machine**: ATM location and operational status
- **Branch**: Bank branch information and ATM associations

### Key Components

- **Authentication Service**: Handles card verification and PIN validation
- **Transaction Processor**: Manages debit/credit operations with balance validation
- **ATM Locator**: Geographic ATM finding and selection logic
- **Presenters**: Clean data presentation layer for views
- **Stimulus Controllers**: JavaScript interactivity for modal management

## 🧪 Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test suites
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
bundle exec rspec spec/services/

# Run with coverage
bundle exec rspec --format documentation
```

### Test Coverage

- **Models**: Comprehensive validation and relationship testing
- **Controllers**: Authentication, authorization, and response testing
- **Services**: Business logic and transaction processing
- **Integration**: End-to-end ATM workflows

## 🎨 Screenshots

### ATM Dashboard
*Modern ATM interface with card authentication and menu options*

### Transaction Modal
*Interactive modal with quick amount selection and custom input*

### Transaction History
*Comprehensive transaction listing with location details and pagination*

## 🛣️ Roadmap

- [ ] **Mobile App**: React Native companion app
- [ ] **Real-time Notifications**: SMS/Email transaction alerts
- [ ] **Advanced Security**: Biometric authentication options
- [ ] **Multi-language Support**: Internationalization (i18n)
- [ ] **Admin Dashboard**: ATM management and monitoring tools
- [ ] **Error Reporting**: Better on-screen error rendering
- [ ] **Modal Confirmations**: Right now the confirmations show on browser's dialog; we need to change that

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Ruby and Rails best practices
- Write comprehensive tests for new features
- Update documentation for API changes
- Ensure responsive design compatibility
- Maintain security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - *Initial work* - [YourGitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Inspired by modern banking interfaces and ATM user experiences
- Built with Rails best practices and modern web technologies
- Special thanks to the Ruby on Rails community for excellent documentation

## 📞 Support

If you have any questions or issues, please:

1. Check the [Issues](https://github.com/yourusername/bank-atm-transaction-api/issues) page
2. Create a new issue with detailed information
3. Contact the maintainers

---

**⚠️ Disclaimer**: This is a demonstration application for educational purposes. Do not use in production environments without proper security auditing and compliance review.
