-- PhotoKiosk Sample Data
-- Creates realistic test data for families and people

-- Insert sample families
INSERT INTO families (last_name, display_name, photo_filename, phone, email, notes) VALUES
('Anderson', 'The Anderson Family', 'anderson_family.jpg', '555-0101', 'anderson@email.com', 'Active in community events'),
('Brown', 'Brown Family', 'brown_family.jpg', '555-0102', 'brown.family@email.com', 'New members this year'),
('Chen', 'The Chens', 'chen_family.jpg', '555-0103', 'chen.household@email.com', 'Volunteers for youth programs'),
('Davis', 'Davis Household', 'davis_family.jpg', '555-0104', 'davis@email.com', ''),
('Evans', 'The Evans Family', 'evans_family.jpg', '555-0105', 'evans.family@email.com', 'Long-time members'),
('Foster', 'Foster Family', 'foster_family.jpg', '555-0106', 'foster@email.com', 'Recently moved here'),
('Garcia', 'The Garcia Family', 'garcia_family.jpg', '555-0107', 'garcia.family@email.com', 'Bilingual household'),
('Harris', 'Harris Family', 'harris_family.jpg', '555-0108', 'harris@email.com', 'Active in sports programs'),
('Johnson', 'The Johnsons', 'johnson_family.jpg', '555-0109', 'johnson.family@email.com', 'Three generations'),
('Kim', 'Kim Family', 'kim_family.jpg', '555-0110', 'kim@email.com', 'Tech industry professionals'),
('Lopez', 'The Lopez Family', 'lopez_family.jpg', '555-0111', 'lopez.family@email.com', 'Musicians'),
('Miller', 'Miller Household', 'miller_family.jpg', '555-0112', 'miller@email.com', 'Educators'),
('Nelson', 'The Nelson Family', 'nelson_family.jpg', '555-0113', 'nelson.family@email.com', 'Outdoor enthusiasts'),
('Parker', 'Parker Family', 'parker_family.jpg', '555-0114', 'parker@email.com', 'Artists'),
('Rodriguez', 'The Rodriguez Family', 'rodriguez_family.jpg', '555-0115', 'rodriguez.family@email.com', 'Business owners'),
('Smith', 'Smith Family', 'smith_family.jpg', '555-0116', 'smith@email.com', 'Founding members'),
('Taylor', 'The Taylors', 'taylor_family.jpg', '555-0117', 'taylor.family@email.com', 'Medical professionals'),
('Williams', 'Williams Family', 'williams_family.jpg', '555-0118', 'williams@email.com', 'Large extended family'),
('Wilson', 'The Wilson Family', 'wilson_family.jpg', '555-0119', 'wilson.family@email.com', 'Recent graduates'),
('Young', 'Young Family', 'young_family.jpg', '555-0120', 'young@email.com', 'Young professionals');

-- Insert people for each family
-- Anderson Family (parents + 2 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(1, 'Michael', 'Anderson', 1, 1978, 'michael_anderson.jpg', 1),
(1, 'Sarah', 'Anderson', 1, 1980, 'sarah_anderson.jpg', 2),
(1, 'Emma', 'Anderson', 0, 2010, 'emma_anderson.jpg', 3),
(1, 'Jacob', 'Anderson', 0, 2012, 'jacob_anderson.jpg', 4);

-- Brown Family (single parent + 1 child)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(2, 'Jennifer', 'Brown', 1, 1985, 'jennifer_brown.jpg', 1),
(2, 'Tyler', 'Brown', 0, 2015, 'tyler_brown.jpg', 2);

-- Chen Family (parents + 3 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(3, 'David', 'Chen', 1, 1975, 'david_chen.jpg', 1),
(3, 'Lisa', 'Chen', 1, 1977, 'lisa_chen.jpg', 2),
(3, 'Kevin', 'Chen', 0, 2008, 'kevin_chen.jpg', 3),
(3, 'Michelle', 'Chen', 0, 2011, 'michelle_chen.jpg', 4),
(3, 'Ryan', 'Chen', 0, 2014, 'ryan_chen.jpg', 5);

-- Davis Family (couple, no kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(4, 'Robert', 'Davis', 1, 1970, 'robert_davis.jpg', 1),
(4, 'Linda', 'Davis', 1, 1972, 'linda_davis.jpg', 2);

-- Evans Family (parents + 1 teenager)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(5, 'James', 'Evans', 1, 1968, 'james_evans.jpg', 1),
(5, 'Patricia', 'Evans', 1, 1970, 'patricia_evans.jpg', 2),
(5, 'Ashley', 'Evans', 0, 2005, 'ashley_evans.jpg', 3);

-- Foster Family (parents + twin boys)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(6, 'Christopher', 'Foster', 1, 1982, 'christopher_foster.jpg', 1),
(6, 'Amanda', 'Foster', 1, 1984, 'amanda_foster.jpg', 2),
(6, 'Brandon', 'Foster', 0, 2013, 'brandon_foster.jpg', 3),
(6, 'Blake', 'Foster', 0, 2013, 'blake_foster.jpg', 4);

-- Garcia Family (large family - parents + 4 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(7, 'Carlos', 'Garcia', 1, 1973, 'carlos_garcia.jpg', 1),
(7, 'Maria', 'Garcia', 1, 1975, 'maria_garcia.jpg', 2),
(7, 'Sofia', 'Garcia', 0, 2006, 'sofia_garcia.jpg', 3),
(7, 'Diego', 'Garcia', 0, 2009, 'diego_garcia.jpg', 4),
(7, 'Isabella', 'Garcia', 0, 2012, 'isabella_garcia.jpg', 5),
(7, 'Miguel', 'Garcia', 0, 2016, 'miguel_garcia.jpg', 6);

-- Harris Family (single father + 2 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(8, 'Daniel', 'Harris', 1, 1979, 'daniel_harris.jpg', 1),
(8, 'Samantha', 'Harris', 0, 2007, 'samantha_harris.jpg', 2),
(8, 'Nathan', 'Harris', 0, 2009, 'nathan_harris.jpg', 3);

-- Johnson Family (3 generations)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(9, 'William', 'Johnson', 1, 1945, 'william_johnson.jpg', 1),
(9, 'Dorothy', 'Johnson', 1, 1948, 'dorothy_johnson.jpg', 2),
(9, 'Mark', 'Johnson', 1, 1975, 'mark_johnson.jpg', 3),
(9, 'Susan', 'Johnson', 1, 1977, 'susan_johnson.jpg', 4),
(9, 'Luke', 'Johnson', 0, 2010, 'luke_johnson.jpg', 5);

-- Kim Family (parents + 1 child)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(10, 'Andrew', 'Kim', 1, 1981, 'andrew_kim.jpg', 1),
(10, 'Grace', 'Kim', 1, 1983, 'grace_kim.jpg', 2),
(10, 'Ethan', 'Kim', 0, 2014, 'ethan_kim.jpg', 3);

-- Add remaining families with varying structures...
-- Lopez Family (musical family - parents + 3 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(11, 'Antonio', 'Lopez', 1, 1976, 'antonio_lopez.jpg', 1),
(11, 'Carmen', 'Lopez', 1, 1978, 'carmen_lopez.jpg', 2),
(11, 'Sophia', 'Lopez', 0, 2008, 'sophia_lopez.jpg', 3),
(11, 'Gabriel', 'Lopez', 0, 2011, 'gabriel_lopez.jpg', 4),
(11, 'Valentina', 'Lopez', 0, 2014, 'valentina_lopez.jpg', 5);

-- Miller Family (educators - couple + 1 child)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(12, 'Thomas', 'Miller', 1, 1974, 'thomas_miller.jpg', 1),
(12, 'Rachel', 'Miller', 1, 1976, 'rachel_miller.jpg', 2),
(12, 'Olivia', 'Miller', 0, 2009, 'olivia_miller.jpg', 3);

-- Nelson Family (outdoor enthusiasts - parents + 2 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(13, 'Brian', 'Nelson', 1, 1980, 'brian_nelson.jpg', 1),
(13, 'Kelly', 'Nelson', 1, 1982, 'kelly_nelson.jpg', 2),
(13, 'Connor', 'Nelson', 0, 2012, 'connor_nelson.jpg', 3),
(13, 'Zoe', 'Nelson', 0, 2015, 'zoe_nelson.jpg', 4);

-- Parker Family (artists - single mother + 1 child)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(14, 'Nicole', 'Parker', 1, 1987, 'nicole_parker.jpg', 1),
(14, 'Madison', 'Parker', 0, 2016, 'madison_parker.jpg', 2);

-- Rodriguez Family (business owners - parents + 2 kids)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(15, 'Eduardo', 'Rodriguez', 1, 1972, 'eduardo_rodriguez.jpg', 1),
(15, 'Ana', 'Rodriguez', 1, 1974, 'ana_rodriguez.jpg', 2),
(15, 'Carlos', 'Rodriguez', 0, 2007, 'carlos_rodriguez.jpg', 3),
(15, 'Elena', 'Rodriguez', 0, 2010, 'elena_rodriguez.jpg', 4);

-- Smith Family (founding members - older couple + adult children)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(16, 'John', 'Smith', 1, 1950, 'john_smith.jpg', 1),
(16, 'Mary', 'Smith', 1, 1952, 'mary_smith.jpg', 2),
(16, 'David', 'Smith', 0, 1980, 'david_smith.jpg', 3),
(16, 'Rebecca', 'Smith', 0, 1982, 'rebecca_smith.jpg', 4);

-- Taylor Family (medical professionals - parents + 1 child)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(17, 'Steven', 'Taylor', 1, 1977, 'steven_taylor.jpg', 1),
(17, 'Jennifer', 'Taylor', 1, 1979, 'jennifer_taylor.jpg', 2),
(17, 'Alexandra', 'Taylor', 0, 2013, 'alexandra_taylor.jpg', 3);

-- Williams Family (large extended family)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(18, 'Charles', 'Williams', 1, 1965, 'charles_williams.jpg', 1),
(18, 'Barbara', 'Williams', 1, 1967, 'barbara_williams.jpg', 2),
(18, 'Jessica', 'Williams', 0, 1995, 'jessica_williams.jpg', 3),
(18, 'Matthew', 'Williams', 0, 1997, 'matthew_williams.jpg', 4),
(18, 'Stephanie', 'Williams', 0, 2000, 'stephanie_williams.jpg', 5);

-- Wilson Family (recent graduates - young couple)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(19, 'Ryan', 'Wilson', 1, 1992, 'ryan_wilson.jpg', 1),
(19, 'Emily', 'Wilson', 1, 1994, 'emily_wilson.jpg', 2);

-- Young Family (young professionals - couple + baby)
INSERT INTO people (family_id, first_name, last_name, is_parent, birth_year, photo_filename, sort_order) VALUES
(20, 'Kevin', 'Young', 1, 1988, 'kevin_young.jpg', 1),
(20, 'Lauren', 'Young', 1, 1990, 'lauren_young.jpg', 2),
(20, 'Noah', 'Young', 0, 2020, 'noah_young.jpg', 3);

-- Add some sample photos metadata
INSERT INTO photos (filename, original_filename, file_size, width, height, thumbnail_filename, description) VALUES
('anderson_family.jpg', 'IMG_0001.jpg', 2456789, 1920, 1080, 'thumb_anderson_family.jpg', 'Anderson family portrait'),
('michael_anderson.jpg', 'IMG_0002.jpg', 1234567, 1080, 1920, 'thumb_michael_anderson.jpg', 'Michael Anderson headshot'),
('sarah_anderson.jpg', 'IMG_0003.jpg', 1345678, 1080, 1920, 'thumb_sarah_anderson.jpg', 'Sarah Anderson headshot'),
('brown_family.jpg', 'IMG_0010.jpg', 1987654, 1920, 1080, 'thumb_brown_family.jpg', 'Brown family photo'),
('chen_family.jpg', 'IMG_0020.jpg', 2765432, 1920, 1080, 'thumb_chen_family.jpg', 'Chen family group photo'),
('garcia_family.jpg', 'IMG_0070.jpg', 3456789, 1920, 1080, 'thumb_garcia_family.jpg', 'Garcia family reunion photo');

-- Link some people to photos (examples)
INSERT INTO person_photos (person_id, photo_id, is_primary) VALUES
(1, 2, 1), -- Michael Anderson primary photo
(2, 3, 1), -- Sarah Anderson primary photo
(3, 1, 0), -- Emma in family photo
(4, 1, 0), -- Jacob in family photo
(5, 4, 1), -- Jennifer Brown primary photo
(6, 4, 0), -- Tyler in family photo
(7, 5, 0), -- David Chen in family photo
(8, 5, 0), -- Lisa Chen in family photo
(25, 6, 0), -- Carlos Garcia in family photo
(26, 6, 0); -- Maria Garcia in family photo