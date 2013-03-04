#!/usr/bin/env ruby

require 'csv'
require 'digest/sha1'

# We make no effort to correlate these first names with gender because:
#
# (1) It doesn't matter for testing purposes
# (2) What's it to you, sexist?

FIRST_NAMES = %w(Annabel Asher Atticus August Butch Clementine Daisy Dashiell Delilah Dexter Dixie Duke Edie Elvis Flora Frances Frank Georgia Gus Hazel Homer Hopper Hudson Hugo Ike India Ione Iris Isla Ivy June Kai Kingston Lennon Leonora Leopold Levi Lila Lionel Lola Luca Lulu Magnus Mamie Matilda Millie Milo Minnie Moses Olive Orson Oscar Otis Pearl Piper Poppy Ray Roman Romy Roscoe Ruby Rufus Sadie Scarlett Sebastian Silas Stella Stellan Sullivan Talullah Theo Violet Agatha Alethea Alexia Ambrose Arabella Araminta Artemus Augustus Bartholomew Bertram Byron Cecelia Clara Clementine Cleora Cornelious Cyrus Deryn Emerson Emmeline Eulalia Evangelene Genevieve Granville Gwendolyn Harrison Ivan Jeremiah Jessamine Jules Langdon Lavinia Lucinda Lucrezia Lyra Maggie Maxwell Minerva Nemo Octavia Oswald Parthenia Ray Scarlett Silas Socrates Sonya Sophronia Theodosia Verne Violetta Alethea Ambrosia Averil Durand Eluned Evadne Gershom Giffard Haidee Hero Idonea Iolo Ismay Jevon Kenelm Lalage Meliora Oriel Pagan Pascoe Rayner Sanchia Sayer Tace Thurstan Wystan Zillah Abbott Archer Bailey Baird Baker Bandit Banner Baxter Bishop Booker Brenner Carbry Carter Carver Chandler Chaucer Cooper Currier Dancer Deacon Draper Drummer Falkner Farmer Fifer Fisher Fletcher Foster Gardener Granger Harper Hooper Hunter Jagger Jeter Kiefer Lander Lanier Mason Mercer Miller Miner Naylor Paige Painter Parker Pilot Piper Plummer Poet Porter Proctor Ranger Reeve Roper Sailor Sawyer Sayer Shepherd Slater Smith Tanner Taylor Thatcher Tolliver Tucker Turner Tyler Walker Weaver Webster Wheeler Whistler Afternoon Arbor Bay Beech Bell Birch Bogart Bravery Cabot Cadence Cameo Cedar Christmas Cricket Curry December Doe Dove Dream Dune Early Easter Echo Fable Field Free Frost Glade Grove Haven Holiday Isle Jet Jonquil Juniper Land Lark Maize Monday Moon Navy North November Pike Pine Prairie Quarry Quintessence Ranger Salmon Season Snow Story Tate Topaz Truth Tuesday Wren Phil Vlad Kim Kate Connie Larry)

LAST_NAMES = %w(Smith Johnson Williams Brown Jones Miller Davis Garcia Rodriguez Wilson Martinez Anderson Taylor Thomas Hernandez Moore Martin Jackson Thompson White Lopez Lee Gonzalez Harris Clark Lewis Robinson Walker Perez Hall Young Allen Sanchez Wright King Scott Green Baker Adams Nelson Hill Ramirez Campbell Mitchell Roberts Carter Phillips Evans Turner Torres Parker Collins Edwards Stewart Flores Morris Nguyen Murphy Rivera Cook Rogers Morgan Peterson Cooper Reed Bailey Bell Gomez Kelly Howard Ward Cox Diaz Richardson Wood Watson Brooks Bennett Gray James Reyes Cruz Hughes Price Myers Long Foster Sanders Ross Morales Powell Sullivan Russell Ortiz Jenkins Gutierrez Perry Butler Barnes Fisher)

LOCATION_NAMES = ["Aberdeen", "Accident", "Annapolis", "Baltimore", "Barclay", "Barnesville", "Barton", "Bel Air", "Berlin", "Berwyn Heights", "Betterton", "Bladensburg", "Boonsboro", "Bowie", "Brentwood", "Brookeville", "Brookview", "Brunswick", "Burkittsville", "Cambridge", "Capitol Heights", "Cecilton", "Centreville", "Charlestown", "Chesapeake Beach", "Chesapeake City", "Chestertown", "Cheverly", "Chevy Chase", "Chevy Chase View", "Chevy Chase Village", "Church Creek", "Church Hill", "Clear Spring", "College Park", "Colmar Manor", "Cottage City", "Crisfield", "Cumberland", "Deer Park", "Delmar", "Denton", "District Heights", "Eagle Harbor", "East New Market", "Easton", "Edmonston", "Eldorado", "Elkton", "Emmitsburg", "Fairmount Heights", "Federalsburg", "Forest Heights", "Frederick", "Friendsville", "Frostburg", "Fruitland", "Funkstown", "Gaithersburg", "Galena", "Galestown", "Garrett Park", "Glen Echo", "Glenarden", "Goldsboro", "Grantsville", "Greenbelt", "Greensboro", "Hagerstown", "Hampstead", "Hancock", "Havre de Grace", "Hebron", "Henderson", "Highland Beach", "Hillsboro", "Hurlock", "Hyattsville", "Indian Head", "Keedysville", "Kensington", "Kitzmiller", "La Plata", "Landover Hills", "Laurel", "Laytonsville", "Leonardtown", "Loch Lynn Heights", "Lonaconing", "Luke", "Manchester", "Mardela Springs", "Martin's Additions", "Marydel", "Middletown", "Midland", "Millington", "Morningside", "Mount Airy", "Mount Rainier", "Mountain Lake Park", "Myersville", "New Carrollton", "New Market", "New Windsor", "North Beach", "North Brentwood", "North Chevy Chase", "North East", "Oakland", "Ocean City", "Oxford", "Perryville", "Pittsville", "Pocomoke City", "Poolesville", "Port Deposit", "Port Tobacco", "Preston", "Princess Anne", "Queen Anne", "Queenstown", "Ridgely", "Rising Sun", "Riverdale Park", "Rock Hall", "Rockville", "Rosemont", "St. Michaels", "Salisbury", "Seat Pleasant", "Secretary", "Sharpsburg", "Sharptown", "Smithsburg", "Snow Hill", "Somerset", "Sudlersville", "Sykesville", "Takoma Park", "Taneytown", "Templeville", "Thurmont", "Trappe", "Union Bridge", "University Park", "Upper Marlboro", "Vienna", "Walkersville", "Washington Grove", "Westernport", "Westminster", "Willards", "Williamsport", "Woodsboro"]

def random_name
  [FIRST_NAMES[rand(FIRST_NAMES.length)], LAST_NAMES[rand(LAST_NAMES.length)]].join(' ')
end

def employee_hash(name, count)
  Digest::SHA1.hexdigest(name + count.to_s)[0,8]
end

def make_email(name, count)
  name.downcase.gsub(/\s/, '') + "#{count}@example.com"
end

def random_location
  LOCATION_NAMES[rand(LOCATION_NAMES.length)]
end

def random_gender
  %w(male female)[rand(2)]
end

def random_dob
  # 8000 days is about 21 years, 15000 is about another 41, so this will give
  # us dates of birth realistic for someone in the workforce
  Date.today - (rand(15000) + 8000)
end

def random_zip
  # All of our place names are in Maryland so we'll generate a lot of ZIP
  # codes that would be invalid, but see the note up in the name constants
  # above.
  result = ''
  5.times {result << rand(10).to_s}
  result
end

if __FILE__ == $0
  name_count = (ARGV[0] ? ARGV[0].to_i : 1)

  name_count.times do |i|
    name = random_name
    employee_id = employee_hash(name, i)
    email = make_email(name, i)
    location = random_location
    gender = random_gender
    dob = random_dob
    zip = random_zip

    puts CSV.generate_line([employee_id, name, email, location, gender, dob, zip])
  end
end
