"""Name pools for the fictional record book (tools/records/generate_records.py).

Every record holder gets a unique first + last name from these pools. Surnames
of well-known real kickers (pro and college) are never used: REAL_KICKER_SURNAMES
is removed from the pool, and tests/test_records_data.py checks it.
"""

FIRST = """
Aaron Abel Adrian Alden Alec Alonzo Ambrose Amos Anders Andre Angelo Ansel Archer Arlo Arthur Asher
August Austin Avery Barrett Basil Beau Benny Bernard Blaine Bo Boone Brady Brant Brennan Brock Bruno
Bryce Buck Burke Byron Caleb Calvin Camden Carl Carlos Carter Casey Cecil Cedric Chad Chance Chandler
Chester Clark Clay Clifton Cody Colby Cole Colin Conrad Corey Cornell Craig Curtis Dale Dallas Damon
Dane Darius Darnell Darren Dean Delmar Dennis Desmond Dewey Dexter Dillon Dominic Donnie Dorian Doyle
Drew Duane Dudley Dwayne Earl Easton Edgar Edmund Eli Elias Elliot Elmer Emery Emmett Enzo Ernie Ethan
Everett Ezra Felix Fletcher Floyd Forrest Foster Francis Frankie Garrett Gavin Gene Gideon Gilbert
Glenn Gordon Grady Grant Griffin Gus Hal Hank Harlan Harold Harvey Hayden Heath Hector Holden Homer
Horace Hudson Hugh Hunter Ian Ira Isaac Ivan Jace Jalen Jamal Jarvis Jasper Jed Jensen Jerome Jesse
Joel Jonah Jordan Judd Jules Julian Kane Keaton Keegan Keith Kellan Kendall Kent Kieran Knox Lamar
Lance Landon Lane Lars Lawson Lee Leland Leon Leroy Levi Lincoln Linus Lionel Lloyd Logan Lonnie Lorenzo
Lowell Lucas Luther Lyle Mack Malcolm Marcus Marshall Marty Mason Mateo Maurice Max Merle Micah Miles
Milo Mitchell Monte Morgan Murphy Nash Nate Neal Nelson Nico Noel Nolan Norris Oakley Omar Orville Oscar
Otis Owen Palmer Parker Percy Pierce Porter Preston Quentin Quincy Rafael Ralph Ramon Randall Raymond
Reed Reggie Reid Remy Rex Rhett Rocco Rodney Roland Roman Ronan Roscoe Ross Rowan Royce Rudy Rufus Russ
Ryder Sal Sawyer Seth Shane Shelby Sidney Silas Simon Skip Sonny Spencer Stanley Sterling Stuart Sully
Tate Teddy Terrell Thad Theo Thurman Tobias Toby Trent Trevor Troy Tucker Ty Vance Vaughn Vernon Victor
Virgil Wade Walker Wallace Warren Waylon Wendell Wesley Weston Whit Wilbur Willis Wyatt Xavier Zane Zeke
""".split()

LAST = """
Abernathy Ackley Adair Aldridge Alford Allard Ambler Ansley Arbogast Archambault Ardoin Ashworth Atwater
Aubuchon Ayers Babcock Bader Baird Ballard Bancroft Barnhart Bassett Battle Baumgartner Beasley Beckham
Belcher Bellamy Benoit Bergeron Berryhill Bettencourt Bickford Birch Bishop Blackwood Blevins Bliss
Bloomfield Bolden Bonner Boudreaux Bowden Boyer Bracken Bradshaw Bragg Brandt Brannon Breaux Brewster
Briggs Brinkley Brock Broussard Buckner Bullard Burkett Burleson Burnside Cabrera Calloway Camacho
Cantrell Carmody Carrington Castellano Cavanaugh Chamberlain Chandler Chastain Childress Clancy Clayborne
Cobb Coker Colvin Compton Conley Corbett Cordova Cosgrove Costello Cottrell Crabtree Crandall Crenshaw
Crockett Crowder Culpepper Cunningham Dabney Dalton Darby Davenport Deakins Delacroix Denney Desrosiers
Dewitt Dillard Doak Donnelly Dorsey Doucet Draper Driscoll Dubois Duggan Dunaway Dupree Durham Eastwood
Easley Eckhart Edmonds Ellington Ellison Emerson Engle Escobar Estes Etheridge Fairchild Falcone Farnsworth
Faulkner Fenwick Ferrell Finch Fitzgerald Flanagan Fleming Fontaine Forsythe Fortier Fowler Frazier
Fullerton Gaines Galloway Garland Garrison Gentry Giddings Gilchrist Glover Goforth Goodwin Gorman Grantham
Greer Griggs Grimes Guerin Gunderson Gutierrez Hadley Hagan Halverson Hammond Hardaway Hargrove Harrington
Haskins Hatcher Haverty Hawkins Haywood Hemphill Hendrix Herrington Hickman Hightower Hilliard Hinson
Holcomb Holloway Hooper Horton Houser Hubbard Huckaby Hutchins Ingram Irving Isbell Jameson Jarrell
Jennings Jernigan Kearney Keener Kellerman Kendrick Kessler Kilgore Kimball Kincaid Kirkland Knowles
Lacroix Lafferty Lamberth Landry Langford Lankford Larkin Latham Leblanc Ledford Lindqvist Lockhart
Loftin Lovett Lundgren Lyman Macklin Maddox Mahoney Malloy Manning Marchand Marlowe Mathis Maxwell
McAllister McBride McCarver McCord McGowan McKinnon McNair Meadows Merriweather Middleton Milburn
Montague Montgomery Moran Morrow Mosley Mullins Nance Neville Newcomb Norwood Nunley Oakes Oliver Orr
Osborne Overton Pace Padgett Palmer Pardee Parrish Paxton Pemberton Pendleton Perrin Pettigrew Pickett
Pollard Poole Prather Prescott Pruitt Pulaski Quarles Quinlan Radford Ragland Ramsey Ratliff Redding
Rhodes Riggins Ritter Roach Rockwell Roman Rousseau Rowland Rutledge Salazar Sandoval Satterfield
Sawyer Schaefer Scruggs Sellers Shackelford Sheffield Shelton Sherrill Shipley Shumate Sikes Singleton
Slater Sloan Smalley Spalding Sparks Spires Stallworth Stanton Steadman Stinson Stokes Strickland Sumner
Sutton Swanson Talbot Tanner Tate Teague Thibodeaux Thornton Tillman Tolliver Townsend Trammell Travers
Tremblay Truitt Tubbs Turnbull Underwood Upshaw Valdez Vance Vaughan Venable Voss Waddell Wakefield
Waldron Ware Warrick Weatherby Westbrook Whitaker Whitfield Wilder Wilkerson Winfield Winslow Womack
Woodard Wooten Workman Yancey Yarbrough Yates Yeager Youngblood Zeller Zimmerman
""".split()

# Surnames of well-known real placekickers (pro and college). Never used.
REAL_KICKER_SURNAMES = set("""
Aguayo Akers Allegre Ammendola Andersen Anderson Aubrey Badgley Bahr Bailey Barth Bass Belli Bennett
Benirschke Biasucci Bironas Blanda Blankenship Boswell Brien Brown Bryant Bullock Butker Butler Cappelletti
Carlson Carney Catanzaro Christie Crosby Cundiff Daluiso Dawson Del Greco Dempsey Dicker Edinger Elam
Elliott Erxleben Fairbairn Feely Ficken Folk Forbath Franklin Fry Gano Gay Gonzalez Gostkowski Gould
Graham Gramatica Groza Hajrullahu Hanson Hartley Hauschka Henery Hopkins Husted Jacke Jaeger Janikowski
Joseph Kaeding Kasay Kelly Kimrin Koo Lambo Leahy Little Lohmiller Longwell Lowery Lutz Maher Mare
McLaughlin McManus McPherson Medlock Mehlhaff Moody Moseley Murray Myers Nedney Norwood Novak Nugent
Parkey Patterson Peterson Pineiro Prater Rackers Rayner Reveiz Rosas Ryland Sanders Santos Santoso
Scobee Seibert Septien Slye Stenerud Stover Stoyanovich Sturgis Succop Tucker Tynes Vanderjagt
Vinatieri Vizcaino Walsh Wilkins Wright Yepremian York Zuerlein
""".split())

LAST = [n for n in LAST if n not in REAL_KICKER_SURNAMES]
FIRST = list(dict.fromkeys(FIRST))
LAST = list(dict.fromkeys(LAST))
