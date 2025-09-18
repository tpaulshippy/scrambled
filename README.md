# Scrambled

A real-time multiplayer word scramble game built with Rails 8, featuring live updates via Hotwire and Action Cable.

## Overview

Scramble is a fast-paced word game where players compete to unscramble words and score points. The first player to reach the target score wins!

## Tech Stack

- **Rails 8.0.2** - Web framework
- **Ruby 3.2.1** - Programming language
- **SQLite** - Database
- **Hotwire (Turbo + Stimulus)** - Frontend reactivity
- **Action Cable** - WebSocket connections for real-time updates
- **Tailwind CSS** - Styling
- **Solid Queue** - Background job processing
- **RSpec** - Testing framework

## Prerequisites

- Ruby 3.2.1 or higher
- SQLite3

## Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd scramble
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Install JavaScript dependencies**
   ```bash
   bin/rails assets:precompile
   ```

## Running the Application

### Development Server
```bash
bin/dev
```
This starts the Rails server with Tailwind CSS compilation in watch mode.

The application will be available at `http://localhost:3000`

### Production
```bash
RAILS_ENV=production bin/rails server
```

## Testing

### Run the full test suite
```bash
bundle exec rspec
```

### Run specific test files
```bash
bundle exec rspec spec/models/game_spec.rb
bundle exec rspec spec/controllers/games_controller_spec.rb
```

### Code Quality
```bash
bin/rubocop
bin/brakeman
```

## How to Play

1. **Start a Game**
   - Visit the homepage and click "New Game"
   - Share the 4-digit game code with other players

2. **Join a Game**
   - Enter a game code on the homepage
   - Choose a unique nickname
   - Click "Ready" when you're prepared to play

3. **Play**
   - Once all players are ready, a countdown will begin
   - Unscramble the displayed word as quickly as possible
   - Type your answer and submit
   - First correct answer wins the round and earns a point

4. **Win**
   - First player to reach the target score wins the game

## Deployment

The application is Docker-ready and can be deployed using Kamal:

```bash
bin/kamal setup
bin/kamal deploy
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is available as open source under the terms of the [MIT License](LICENSE).