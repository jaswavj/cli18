-- Lookup table for flight numbers (autocomplete)
CREATE TABLE IF NOT EXISTS ticket_flightno (
    id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    value VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_flightno_value (value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lookup table for airline names (autocomplete)
CREATE TABLE IF NOT EXISTS ticket_airline (
    id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    value VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_airline_value (value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Pre-populate with common values (optional)
INSERT IGNORE INTO ticket_airline (value) VALUES
    ('Air India'), ('IndiGo'), ('SpiceJet'), ('Vistara'), ('GoAir'),
    ('AirAsia India'), ('Blue Dart Aviation'), ('Emirates'), ('Qatar Airways'),
    ('Air Arabia'), ('flydubai'), ('Oman Air'), ('SriLankan Airlines');
