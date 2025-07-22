# ✈️ SkyRoute – Flight Booking App

**SkyRoute** is a flight booking web application that helps users search for flights, view availability by class and date, calculate dynamic fares, and make one-way or round-trip bookings.

## 📚 Table of Contents

- [📋 Description](#📋-description)
- [✨ Features](#✨-features)
- [🛠️ Technologies Used](#🛠️-technologies-used)
- [🗒️ Requirements](#🗒️-requirements)
- [📥 Installation](#📥-installation)
- [🧹 RuboCop Linting](#🧹-rubocop-linting)
- [🧪 RSpec Testing](#🧪-rspec-testing)
- [🚀 Usage](#🚀-usage)
- [🤝 Contribution](#🤝-contribution)
- [📧 Contact](#📧-contact)

## 📋 Description

**SkyRoute** is a lightweight, web-based flight booking application built with Ruby on Rails.
It allows users to easily search and book flights by entering a source, destination, date, class type, and number of passengers. The system shows only flights with enough available seats, calculates dynamic fares based on demand and time, and offers round-trip discounts. 
All flight-related data including available flights, cities, class types, and bookings is stored in a **PostgreSQL** database.


Users can:

- Search for one-way or round-trip flights by source, destination, and departure date.
- Select the number of passengers and preferred class (Economy, Second Class, or First Class).
- View real-time availability and dynamically calculated fares.
- Confirm bookings, which automatically update seat counts and pricing.

## ✨ Features

- 🔍 Search Flights by Source and Destination
- 📅 Filter by Departure Date
- 💺 Show Only Flights with Available Seats
- 👨‍👩‍👧 Search Based on Number of Passengers
- 🧳 Choose Class Type: Economy / Second Class / First Class
- 💰 Fare Calculation based on class and passenger count
- 📊 Dynamic Pricing Strategy: Based on seat availability and Based on how many days are left until the flight
- 🔁 Round Trip Support with automatic 5% discount
- 🗃️ Updates Seat Count after booking

## 🛠️ Technologies Used

- 💎 Ruby: Programming language used for the core logic
- 🚂 Rails:Full-stack web framework used to build the application’s structure and handle routing, controllers, and views
- 🌐 Web Interface: Built with Rails views (ERB/HTML) for user interaction via browser
- 🗃️ PostgreSQL: Relational database used for storing flights, bookings, cities, and seat information
- 🧪 RSpec: For writing and running test cases
- 🧹 RuboCop: For linting and maintaining clean Ruby code

## 🗒️ Requirements

- 💎 Ruby (version 3.2.0)
- 🚂 Rails (version 8.0.2)
- 📦 Bundler
- 🐘 PostgreSQL (as database)
- 🌐 Web browser (to view the app via localhost)
- 🧪 RSpec – For running test cases
- 🧹 RuboCop – For code linting and formatting

## 📥 Installation

1. 📦 Clone the repository:
   ```bash
     git clone git@github.com:AnushaUppuu/sky-route.git
     cd skyroute
   ```
2. 💎 Install Ruby & Rails (if not already installed)

- Install Ruby (recommended: 3.2.0)
  ```bash
  brew install rbenv
  rbenv init
  ```
  ```bash
  rbenv install 3.2.0
  ```
- Install Rails:
  ```bash
  gem install rails -v 8.0.2
  ```

3. 📁 Install all required gems:
   ```bash
   bundle install
   ```
4.🐘 Set up PostgreSQL Database
- Make sure PostgreSQL is installed and running on your system.
- Create the database:
  ```bash
   rails db:create
  ```
- Run migrations to set up schema:
  ```bash
   rails db:migrate
  ```
- Seed the database with initial flight/city/seat data:
  ```bash
   rails db:seed
  ```
- You can configure your database credentials in config/database.yml if required.

5. 🚀 Start the Rails server:
   ```bash
    rails server
   ```
6. 🌐 Open in your browser: http://localhost:3000

## 🧹 RuboCop Linting

RuboCop ensures your code stays clean, readable, and consistent with Ruby best practices.

- **🧼 How to Use RuboCop**
- Install RuboCop (if not already):
  ```bash
  bundle add rubocop --group=development
  ```
- Check code quality:
  ```bash
  bundle exec rubocop
  ```
- Auto-correct style issues:
  ```bash
  bundle exec rubocop -A
  ```

## 🧪 RSpec Testing

RSpec is used to test the application's features, logic, and data accuracy.

- **✅ How to Run Tests**
- Install RSpec (if not already):
  ```bash
  bundle add rspec
  bundle exec rspec --init
  ```
- Run all tests:
  ```bash
  bundle exec rspec
  ```
- Add your test cases in the spec/ directory.

## 🚀 Usage

1. Go to http://localhost:3000
2. Input:

- ✈️ Source & Destination
- 📅 Departure Date
- 👤 Number of Passengers
- 💺 Class Type (Economy / Second / First)

3. App displays:

- Matching flights
- Departure & arrival time
- Total fare based on your inputs

4. Confirm booking – and the PostgreSQL database will be updated.
5. (Optional) Select Round Trip to get 5% off on the return ticket.

## 🤝 Contribution:

- If you'd like to contribute, follow these steps:
- Clone repository:
  ```bash
  git clone git@github.com:AnushaUppuu/sky-route.git
  ```
- Create a new branch for your feature.
  ```bash
  git checkout -b branch-name
  ```
- Push your branch to GitHub:
  ```bash
  git push origin branch-name
  ```
- Open a Pull Request to _main_ branch.

## 📧 Contact

📩 For questions or support, reach out at:  
📬 uppuanusha3@gmail.com

### Thank You 😃
