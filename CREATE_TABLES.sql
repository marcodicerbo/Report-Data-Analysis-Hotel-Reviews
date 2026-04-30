/*Questo file riporta il codice sql utilizzato per creare il database hotel_reviews e le relative tabelle hotels, reviewers, hotel_stats e reviews.*/

CREATE DATABASE hotel_reviews;
USE hotel_reviews;

CREATE TABLE hotels (
  hotel_id INT NOT NULL PRIMARY KEY,
  hotel_name VARCHAR(255) NOT NULL,
  hotel_address VARCHAR(255) NOT NULL,
  lat DECIMAL(10,7),
  lng DECIMAL(10,7)
);

CREATE TABLE reviewers (
  reviewer_id INT NOT NULL PRIMARY KEY,
  reviewer_nationality VARCHAR(100) NOT NULL,
  reviewer_review_count INT NOT NULL
);

CREATE TABLE hotel_stats (
  hotel_id INT NOT NULL PRIMARY KEY,
  average_score DECIMAL(4,2) NOT NULL,
  additional_number_of_scoring INT NOT NULL,
  total_number_of_reviews INT NOT NULL,
  FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);

CREATE TABLE reviews (
  review_id INT NOT NULL PRIMARY KEY,
  hotel_id INT NOT NULL,
  reviewer_id INT NOT NULL,
  review_date DATE NOT NULL,
  review_year INT NOT NULL,
  review_month INT NOT NULL,
  review_yearmonth VARCHAR(7) NOT NULL,
  review_length INT NOT NULL,
  days_since_review VARCHAR(50) NOT NULL,
  negative_review TEXT,
  positive_review TEXT,
  review_total_positive_word_counts INT NOT NULL,
  review_total_negative_word_counts INT NOT NULL,
  reviewer_score DECIMAL(4,2) NOT NULL,
  FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id),
  FOREIGN KEY (reviewer_id) REFERENCES reviewers(reviewer_id)
);