-- PhotoKiosk SQLite Database Schema
-- Creates tables for families and individual people with photo management

-- Main families table - one record per household/family unit
CREATE TABLE families (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    last_name TEXT NOT NULL,
    display_name TEXT,  -- Optional: "Smith Family", "The Johnsons", etc.
    photo_filename TEXT, -- Family photo if available
    phone TEXT,
    email TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_date DATETIME DEFAULT (DATETIME('now')),
    modified_date DATETIME DEFAULT (DATETIME('now'))
);

-- Individual people - multiple records per family
CREATE TABLE people (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    middle_name TEXT,
    last_name TEXT, -- Usually same as family.last_name but allows for step-families, etc.
    full_name TEXT GENERATED ALWAYS AS (
        CASE 
            WHEN middle_name IS NOT NULL AND middle_name != '' 
            THEN first_name || ' ' || middle_name || ' ' || last_name
            ELSE first_name || ' ' || last_name
        END
    ) STORED,
    is_parent BOOLEAN DEFAULT 0,
    birth_year INTEGER, -- Year only for privacy
    photo_filename TEXT,
    sort_order INTEGER DEFAULT 0, -- For custom ordering within family
    is_active BOOLEAN DEFAULT 1,
    created_date DATETIME DEFAULT (DATETIME('now')),
    modified_date DATETIME DEFAULT (DATETIME('now')),
    
    FOREIGN KEY (family_id) REFERENCES families(id)
);

-- Photo metadata table - tracks all photos and their usage
CREATE TABLE photos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    filename TEXT UNIQUE NOT NULL,
    original_filename TEXT, -- In case file gets renamed
    file_size INTEGER,
    width INTEGER,
    height INTEGER,
    thumbnail_filename TEXT, -- Generated thumbnail
    photo_date DATE,
    description TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_date DATETIME DEFAULT (DATETIME('now'))
);

-- Link table for people who appear in multiple photos
CREATE TABLE person_photos (
    person_id INTEGER,
    photo_id INTEGER,
    is_primary BOOLEAN DEFAULT 0, -- Is this the person's main photo?
    created_date DATETIME DEFAULT (DATETIME('now')),
    
    FOREIGN KEY (person_id) REFERENCES people(id),
    FOREIGN KEY (photo_id) REFERENCES photos(id),
    PRIMARY KEY (person_id, photo_id)
);

-- Indexes for performance
CREATE INDEX idx_families_last_name ON families(last_name);
CREATE INDEX idx_people_family_id ON people(family_id);
CREATE INDEX idx_people_first_name ON people(first_name);
CREATE INDEX idx_people_last_name ON people(last_name);
CREATE INDEX idx_people_full_name ON people(full_name);
CREATE INDEX idx_people_is_parent ON people(is_parent);
CREATE INDEX idx_photos_filename ON photos(filename);

-- Views for easy data extraction (matches your original spreadsheet approach)

-- View for FirstName sorting (each person individually)
CREATE VIEW v_people_by_first_name AS
SELECT 
    p.id,
    p.first_name,
    p.last_name,
    p.full_name,
    p.photo_filename,
    f.last_name as family_name,
    f.photo_filename as family_photo,
    p.is_parent,
    UPPER(SUBSTR(p.first_name, 1, 1)) as first_letter
FROM people p
JOIN families f ON p.family_id = f.id
WHERE p.is_active = 1 AND f.is_active = 1
ORDER BY p.first_name, p.last_name;

-- View for LastName sorting (family units)
CREATE VIEW v_families_by_last_name AS
SELECT 
    f.id,
    f.last_name,
    f.display_name,
    f.photo_filename,
    -- Concatenate all family member names
    GROUP_CONCAT(
        CASE WHEN p.is_parent = 1 THEN p.first_name END, 
        ' & '
    ) as parent_names,
    GROUP_CONCAT(
        CASE WHEN p.is_parent = 0 THEN p.first_name END, 
        ', '
    ) as children_names,
    COUNT(p.id) as member_count,
    UPPER(SUBSTR(f.last_name, 1, 1)) as first_letter
FROM families f
LEFT JOIN people p ON f.id = p.family_id AND p.is_active = 1
WHERE f.is_active = 1
GROUP BY f.id, f.last_name, f.display_name, f.photo_filename
ORDER BY f.last_name;

-- Triggers to update modified_date
CREATE TRIGGER tr_families_modified 
    AFTER UPDATE ON families
    FOR EACH ROW
    WHEN OLD.modified_date = NEW.modified_date
BEGIN
    UPDATE families SET modified_date = DATETIME('now') WHERE id = NEW.id;
END;

CREATE TRIGGER tr_people_modified 
    AFTER UPDATE ON people
    FOR EACH ROW
    WHEN OLD.modified_date = NEW.modified_date
BEGIN
    UPDATE people SET modified_date = DATETIME('now') WHERE id = NEW.id;
END;

-- Sample queries for your Delphi code:

-- Get all families for LastName view:
-- SELECT * FROM v_families_by_last_name;

-- Get all people for FirstName view:
-- SELECT * FROM v_people_by_first_name;

-- Get navigation letters for FirstName:
-- SELECT DISTINCT first_letter FROM v_people_by_first_name ORDER BY first_letter;

-- Get navigation letters for LastName:
-- SELECT DISTINCT first_letter FROM v_families_by_last_name ORDER BY first_letter;