-- USERS TABLE
CREATE TABLE users (
  id CHAR(36) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  subscription_tier VARCHAR(20) DEFAULT 'monthly',
  subscription_status VARCHAR(20) DEFAULT 'inactive',
  subscription_id TEXT UNIQUE,
  current_period_end TIMESTAMP NULL,
  charity_percentage INT DEFAULT 10,
  selected_charity_id CHAR(36),
  is_admin TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- CHARITIES
CREATE TABLE charities (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url TEXT,
  website TEXT,
  contact_email VARCHAR(255),
  is_featured TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- GOLF SCORES
CREATE TABLE golf_scores (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  score INT NOT NULL CHECK (score BETWEEN 1 AND 45),
  played_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_user_date (user_id, played_date),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- DRAWS
CREATE TABLE draws (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INT NOT NULL,
  draw_type VARCHAR(20) NOT NULL,
  status VARCHAR(20) DEFAULT 'draft',
  winning_numbers JSON,
  jackpot_amount DECIMAL(10,2) DEFAULT 0,
  total_pool_amount DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  published_at TIMESTAMP NULL,
  UNIQUE KEY unique_draw (month, year)
);

-- DRAW PARTICIPANTS
CREATE TABLE draw_participants (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  draw_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  user_numbers JSON NOT NULL,
  match_type VARCHAR(20) NOT NULL,
  matched_count INT DEFAULT 0,
  won TINYINT(1) DEFAULT 0,
  prize_amount DECIMAL(10,2),
  payout_status VARCHAR(20) DEFAULT 'pending',
  proof_url TEXT,
  proof_approved TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_participation (draw_id, user_id),
  FOREIGN KEY (draw_id) REFERENCES draws(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- WINNER VERIFICATIONS
CREATE TABLE winner_verifications (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  draw_participant_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  proof_url TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  admin_notes TEXT,
  reviewed_by CHAR(36),
  reviewed_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (draw_participant_id) REFERENCES draw_participants(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- PAYMENTS
CREATE TABLE payments (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  stripe_payment_intent_id TEXT UNIQUE,
  stripe_subscription_id TEXT,
  amount DECIMAL(10,2) NOT NULL,
  charity_amount DECIMAL(10,2) DEFAULT 0,
  prize_pool_amount DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(20) DEFAULT 'succeeded',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- CHARITY CONTRIBUTIONS
CREATE TABLE charity_contributions (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  charity_id CHAR(36) NOT NULL,
  payment_id CHAR(36),
  amount DECIMAL(10,2) NOT NULL,
  month INT NOT NULL,
  year INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_contribution (user_id, charity_id, month, year),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (charity_id) REFERENCES charities(id) ON DELETE CASCADE
);