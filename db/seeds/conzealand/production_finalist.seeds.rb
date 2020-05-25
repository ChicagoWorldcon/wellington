# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

category = Category.joins(:election).find_by!(name: "Best Novel", elections: { i18n_key: "hugo"})
category.finalists.create!(description: "The City in the Middle of the Night, by Charlie Jane Anders (Tor; Titan)")
category.finalists.create!(description: "Gideon the Ninth, by Tamsyn Muir (Tor.com Publishing)")
category.finalists.create!(description: "The Light Brigade, by Kameron Hurley (Saga; Angry Robot UK)")
category.finalists.create!(description: "A Memory Called Empire, by Arkady Martine (Tor; Tor UK)")
category.finalists.create!(description: "Middlegame, by Seanan McGuire (Tor.com Publishing)")
category.finalists.create!(description: "The Ten Thousand Doors of January, by Alix E. Harrow (Redhook; Orbit UK)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by!(name: "Best Novella", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "“Anxiety Is the Dizziness of Freedom”, by Ted Chiang (Exhalation (Borzoi/Alfred A. Knopf; Picador))")
category.finalists.create!(description: "The Deep, by Rivers Solomon, with Daveed Diggs, William Hutson & Jonathan Snipes (Saga Press/Gallery)")
category.finalists.create!(description: "The Haunting of Tram Car 015, by P. Djèlí Clark (Tor.com Publishing)")
category.finalists.create!(description: "In an Absent Dream, by Seanan McGuire (Tor.com Publishing)")
category.finalists.create!(description: "This Is How You Lose the Time War, by Amal El-Mohtar and Max Gladstone (Saga Press; Jo Fletcher Books)")
category.finalists.create!(description: "To Be Taught, If Fortunate, by Becky Chambers (Harper Voyager; Hodder & Stoughton)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by!(name: "Best Novelette", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "“The Archronology of Love”, by Caroline M. Yoachim (Lightspeed, April 2019)")
category.finalists.create!(description: "“Away With the Wolves”, by Sarah Gailey (Uncanny Magazine: Disabled People Destroy Fantasy Special Issue, September/October 2019)")
category.finalists.create!(description: "“The Blur in the Corner of Your Eye”, by Sarah Pinsker (Uncanny Magazine, July-August 2019)")
category.finalists.create!(description: "Emergency Skin, by N.K. Jemisin (Forward Collection (Amazon))")
category.finalists.create!(description: "“For He Can Creep”, by Siobhan Carroll (Tor.com, 10 July 2019)")
category.finalists.create!(description: "“Omphalos”, by Ted Chiang (Exhalation (Borzoi/Alfred A. Knopf; Picador))")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by!(name: "Best Short Story", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "“And Now His Lordship Is Laughing”, by Shiv Ramdas (Strange Horizons, 9 September 2019)")
category.finalists.create!(description: "“As the Last I May Know”, by S.L. Huang (Tor.com, 23 October 2019)")
category.finalists.create!(description: "“Blood Is Another Word for Hunger”, by Rivers Solomon (Tor.com, 24 July 2019)")
category.finalists.create!(description: "“A Catalog of Storms”, by Fran Wilde (Uncanny Magazine, January/February 2019)")
category.finalists.create!(description: "“Do Not Look Back, My Lion”, by Alix E. Harrow (Beneath Ceaseless Skies, January 2019)")
category.finalists.create!(description: "“Ten Excerpts from an Annotated Bibliography on the Cannibal Women of Ratnabar Island”, by Nibedita Sen (Nightmare Magazine, May 2019)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Series", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "The Expanse, by James S. A. Corey (Orbit US; Orbit UK)")
category.finalists.create!(description: "InCryptid, by Seanan McGuire (DAW)")
category.finalists.create!(description: "Luna, by Ian McDonald (Tor; Gollancz)")
category.finalists.create!(description: "Planetfall series, by Emma Newman (Ace; Gollancz)")
category.finalists.create!(description: "Winternight Trilogy, by Katherine Arden (Del Rey; Del Rey UK)")
category.finalists.create!(description: "The Wormwood Trilogy, by Tade Thompson (Orbit US; Orbit UK)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Related Work", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Becoming Superman: My Journey from Poverty to Hollywood, by J. Michael Straczynski (Harper Voyager US)")
category.finalists.create!(description: "Joanna Russ, by Gwyneth Jones (University of Illinois Press (Modern Masters of Science Fiction))")
category.finalists.create!(description: "The Lady from the Black Lagoon: Hollywood Monsters and the Lost Legacy of Milicent Patrick, by Mallory O’Meara (Hanover Square)")
category.finalists.create!(description: "The Pleasant Profession of Robert A. Heinlein, by Farah Mendlesohn (Unbound)")
category.finalists.create!(description: "“2019 John W. Campbell Award Acceptance Speech”, by Jeannette Ng")
category.finalists.create!(description: "Worlds of Ursula K. Le Guin, produced and directed by Arwen Curry")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Graphic Story or Comic", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Die, Volume 1: Fantasy Heartbreaker, by Kieron Gillen and Stephanie Hans, letters by Clayton Cowles (Image)")
category.finalists.create!(description: "LaGuardia, written by Nnedi Okorafor, art by Tana Ford, colours by James Devlin (Berger Books; Dark Horse)")
category.finalists.create!(description: "Monstress, Volume 4: The Chosen, written by Marjorie Liu, art by Sana Takeda (Image)")
category.finalists.create!(description: "Mooncakes, by Wendy Xu and Suzanne Walker, letters by Joamette Gil (Oni Press; Lion Forge)")
category.finalists.create!(description: "Paper Girls, Volume 6, written by Brian K. Vaughan, drawn by Cliff Chiang, colours by Matt Wilson, letters by Jared K. Fletcher (Image)")
category.finalists.create!(description: "The Wicked + The Divine, Volume 9: “Okay”, by Kieron Gillen and Jamie McKelvie, colours by Matt Wilson, letters by Clayton Cowles (Image)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Dramatic Presentation, Long Form", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Avengers: Endgame, screenplay by Christopher Markus and Stephen McFeely, directed by Anthony Russo and Joe Russo (Marvel Studios)")
category.finalists.create!(description: "Captain Marvel, screenplay by Anna Boden, Ryan Fleck and Geneva Robertson-Dworet, directed by Anna Boden and Ryan Fleck (Walt Disney Pictures/Marvel Studios/Animal Logic (Australia))")
category.finalists.create!(description: "Good Omens, written by Neil Gaiman, directed by Douglas Mackinnon (Amazon Studios/BBC Studios/Narrativia/The Blank Corporation)")
category.finalists.create!(description: "Russian Doll (Season One), created by Natasha Lyonne, Leslye Headland and Amy Poehler, directed by Leslye Headland, Jamie Babbit and Natasha Lyonne (3 Arts Entertainment/Jax Media/Netflix/Paper Kite Productions/Universal Television)")
category.finalists.create!(description: "Star Wars: The Rise of Skywalker, screenplay by Chris Terrio and J.J. Abrams, directed by J.J. Abrams (Walt Disney Pictures/Lucasfilm/Bad Robot)")
category.finalists.create!(description: "Us, written and directed by Jordan Peele (Monkeypaw Productions/Universal Pictures)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Dramatic Presentation, Short Form", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "The Good Place: “The Answer”, written by Daniel Schofield, directed by Valeria Migliassi Collins (Fremulon/3 Arts Entertainment/Universal Television)")
category.finalists.create!(description: "The Expanse: “Cibola Burn”, written by Daniel Abraham & Ty Franck and Naren Shankar, directed by Breck Eisner (Amazon Prime Video)")
category.finalists.create!(description: "Watchmen: “A God Walks into Abar”, written by Jeff Jensen and Damon Lindelof, directed by Nicole Kassell (HBO)")
category.finalists.create!(description: "The Mandalorian: “Redemption”, written by Jon Favreau, directed by Taika Waititi (Disney+)")
category.finalists.create!(description: "Doctor Who: “Resolution”, written by Chris Chibnall, directed by Wayne Yip (BBC)")
category.finalists.create!(description: "Watchmen: “This Extraordinary Being”, written by Damon Lindelof and Cord Jefferson, directed by Stephen Williams (HBO)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Editor, Short Form", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Neil Clarke")
category.finalists.create!(description: "Ellen Datlow")
category.finalists.create!(description: "C.C. Finlay")
category.finalists.create!(description: "Jonathan Strahan")
category.finalists.create!(description: "Lynne M. Thomas and Michael Damian Thomas")
category.finalists.create!(description: "Sheila Williams")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Editor, Long Form", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Sheila E. Gilbert")
category.finalists.create!(description: "Brit Hvide")
category.finalists.create!(description: "Diana M. Pho")
category.finalists.create!(description: "Devi Pillai")
category.finalists.create!(description: "Miriam Weinberg")
category.finalists.create!(description: "Navah Wolfe")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Professional Artist", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Tommy Arnold")
category.finalists.create!(description: "Rovina Cai")
category.finalists.create!(description: "Galen Dara")
category.finalists.create!(description: "John Picacio")
category.finalists.create!(description: "Yuko Shimizu")
category.finalists.create!(description: "Alyssa Winans")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Semiprozine", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Beneath Ceaseless Skies, editor Scott H. Andrews")
category.finalists.create!(description: "Escape Pod, editors Mur Lafferty and S.B. Divya, assistant editor Benjamin C. Kinney, audio producers Adam Pracht and Summer Brooks, hosts Tina Connolly and Alasdair Stuart")
category.finalists.create!(description: "Fireside Magazine, editor Julia Rios, managing editor Elsa Sjunneson, copyeditor Chelle Parker, social coordinator Meg Frank, publisher & art director Pablo Defendini, founding editor Brian White")
category.finalists.create!(description: "FIYAH Magazine of Black Speculative Fiction, executive editor Troy L. Wiggins, editors Eboni Dunbar, Brent Lambert, L.D. Lewis, Danny Lore, Brandon O’Brien and Kaleb Russell")
category.finalists.create!(description: "Strange Horizons, Vanessa Rose Phin, Catherine Krahe, AJ Odasso, Dan Hartland, Joyce Chng, Dante Luiz and the Strange Horizons staff")
category.finalists.create!(description: "Uncanny Magazine, editors-in-chief Lynne M. Thomas and Michael Damian Thomas, nonfiction/managing editor Michi Trota, managing editor Chimedum Ohaegbu, podcast producers Erika Ensign and Steven Schapansky")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Fanzine", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "The Book Smugglers, editors Ana Grilo and Thea James")
category.finalists.create!(description: "Galactic Journey, founder Gideon Marcus, editor Janice Marcus, senior writers Rosemary Benton, Lorelei Marcus and Victoria Silverwolf")
category.finalists.create!(description: "Journey Planet, editors James Bacon, Christopher J Garcia, Alissa McKersie, Ann Gry, Chuck Serface, John Coxon and Steven H Silver")
category.finalists.create!(description: "nerds of a feather, flock together, editors Adri Joy, Joe Sherry, Vance Kotrla, and The G")
category.finalists.create!(description: "Quick Sip Reviews, editor Charles Payseur")
category.finalists.create!(description: "The Rec Center, editors Elizabeth Minkel and Gavia Baker-Whitelaw")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Fancast", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Be The Serpent, presented by Alexandra Rowland, Freya Marske and Jennifer Mace")
category.finalists.create!(description: "Claire Rousseau’s YouTube channel, produced & presented by Claire Rousseau")
category.finalists.create!(description: "The Coode Street Podcast, presented by Jonathan Strahan and Gary K. Wolfe")
category.finalists.create!(description: "Galactic Suburbia, presented by Alisa Krasnostein, Alexandra Pierce and Tansy Rayner Roberts, producer Andrew Finch")
category.finalists.create!(description: "Our Opinions Are Correct, presented by Annalee Newitz and Charlie Jane Anders")
category.finalists.create!(description: "The Skiffy and Fanty Show, presented by Jen Zink and Shaun Duke")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Fan Writer", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Cora Buhlert")
category.finalists.create!(description: "James Davis Nicoll")
category.finalists.create!(description: "Alasdair Stuart")
category.finalists.create!(description: "Bogi Takács")
category.finalists.create!(description: "Paul Weimer")
category.finalists.create!(description: "Adam Whitehead")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Fan Artist", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Iain Clark")
category.finalists.create!(description: "Sara Felix")
category.finalists.create!(description: "Grace P. Fong")
category.finalists.create!(description: "Meg Frank")
category.finalists.create!(description: "Ariela Housman")
category.finalists.create!(description: "Elise Matthesen")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Astounding Award for the best new science fiction writer, sponsored by Dell Magazines (not a Hugo)", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Sam Hawke (2nd year of eligibility)")
category.finalists.create!(description: "R.F. Kuang (2nd year of eligibility)")
category.finalists.create!(description: "Jenn Lyons (1st year of eligibility)")
category.finalists.create!(description: "Nibedita Sen (2nd year of eligibility)")
category.finalists.create!(description: "Tasha Suri (2nd year of eligibility)")
category.finalists.create!(description: "Emily Tesh (1st year of eligibility)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Lodestar Award for Best Young Adult Book (not a Hugo)", elections: { i18n_key: "hugo" })
category.finalists.create!(description: "Catfishing on CatNet, by Naomi Kritzer (Tor Teen)")
category.finalists.create!(description: "Deeplight, by Frances Hardinge (Macmillan)")
category.finalists.create!(description: "Dragon Pearl, by Yoon Ha Lee (Disney/Hyperion)")
category.finalists.create!(description: "Minor Mage, by T. Kingfisher (Argyll)")
category.finalists.create!(description: "Riverland, by Fran Wilde (Amulet)")
category.finalists.create!(description: "The Wicked King, by Holly Black (Little, Brown; Hot Key)")
category.finalists.create!(description: "No award")

# Retro Hugos 1945
category = Category.joins(:election).find_by(name: "Best Novel", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "The Golden Fleece (Hercules, My Shipmate), by Robert Graves (Cassell)")
category.finalists.create!(description: "Land of Terror, by Edgar Rice Burroughs (Edgar Rice Burroughs, Inc.)")
category.finalists.create!(description: "“Shadow Over Mars” (The Nemesis from Terra), by Leigh Brackett (Startling Stories, Fall 1944)")
category.finalists.create!(description: "Sirius: A Fantasy of Love and Discord, by Olaf Stapledon (Secker & Warburg)")
category.finalists.create!(description: "The Wind on the Moon, by Eric Linklater (Macmillan)")
category.finalists.create!(description: "“The Winged Man”, by A.E. van Vogt and E. Mayne Hull (Astounding Science Fiction, May-June 1944)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Novella", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "“The Changeling”, by A.E. van Vogt (Astounding Science Fiction, April 1944)")
category.finalists.create!(description: "“A God Named Kroo”, by Henry Kuttner (Thrilling Wonder Stories, Winter 1944)")
category.finalists.create!(description: "“Intruders from the Stars”, by Ross Rocklynne (Amazing Stories, January 1944)")
category.finalists.create!(description: "“The Jewel of Bas”, by Leigh Brackett (Planet Stories, Spring 1944)")
category.finalists.create!(description: "“Killdozer!”, by Theodore Sturgeon (Astounding Science Fiction, November 1944)")
category.finalists.create!(description: "“Trog”, by Murray Leinster (Astounding Science Fiction, June 1944)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Novelette", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "“Arena”, by Fredric Brown (Astounding Science Fiction, June 1944)")
category.finalists.create!(description: "“The Big and the Little” (“The Merchant Princes”), by Isaac Asimov (Astounding Science Fiction, August 1944)")
category.finalists.create!(description: "“The Children’s Hour”, by Lawrence O’Donnell (C.L. Moore and Henry Kuttner) (Astounding Science Fiction, March 1944)")
category.finalists.create!(description: "“City”, by Clifford D. Simak (Astounding Science Fiction, May 1944)")
category.finalists.create!(description: "“No Woman Born”, by C.L. Moore (Astounding Science Fiction, December 1944)")
category.finalists.create!(description: "“When the Bough Breaks”, by Lewis Padgett (C.L. Moore and Henry Kuttner) (Astounding Science Fiction, November 1944)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Short Story", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "“And the Gods Laughed”, by Fredric Brown (Planet Stories, Spring 1944)")
category.finalists.create!(description: "“Desertion”, by Clifford D. Simak (Astounding Science Fiction, November 1944)")
category.finalists.create!(description: "“Far Centaurus”, by A. E. van Vogt (Astounding Science Fiction, January 1944)")
category.finalists.create!(description: "“Huddling Place”, by Clifford D. Simak (Astounding Science Fiction, July 1944)")
category.finalists.create!(description: "“I, Rocket”, by Ray Bradbury (Amazing Stories, May 1944)")
category.finalists.create!(description: "“The Wedge” (“The Traders”), by Isaac Asimov (Astounding Science Fiction, October 1944)")
category.finalists.create!(description: "No award")

category = Category.joins(:election).find_by(name: "Best Series", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "Captain Future, by Brett Sterling (Edmond Hamilton)")
category.finalists.create!(description: "The Cthulhu Mythos, by H. P. Lovecraft, August Derleth, and others")
category.finalists.create!(description: "Doc Savage, by Kenneth Robeson/Lester Dent")
category.finalists.create!(description: "Jules de Grandin, by Seabury Quinn")
category.finalists.create!(description: "Pellucidar, by Edgar Rice Burroughs")
category.finalists.create!(description: "The Shadow, by Maxwell Grant (Walter B. Gibson)")
category.finalists.create!(description: "No award")

category = Category.joins(:election).find_by(name: "Best Related Work", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "Fancyclopedia, by Jack Speer (Forrest J. Ackerman)")
category.finalists.create!(description: "’42 To ’44: A Contemporary Memoir Upon Human Behavior During the Crisis of the World Revolution, by H.G. Wells (Secker & Warburg)")
category.finalists.create!(description: "Mr. Tompkins Explores the Atom, by George Gamow (Cambridge University Press)")
category.finalists.create!(description: "Rockets: The Future of Travel Beyond the Stratosphere, by Willy Ley (Viking Press)")
category.finalists.create!(description: "“The Science-Fiction Field”, by Leigh Brackett (Writer’s Digest, July 1944)")
category.finalists.create!(description: "“The Works of H.P. Lovecraft: Suggestions for a Critical Appraisal”, by Fritz Leiber (The Acolyte, Fall 1944)")
category.finalists.create!(description: "No award")

category = Category.joins(:election).find_by(name: "Best Graphic Story or Comic", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "Buck Rogers: “Hollow Planetoid”, by Dick Calkins (National Newspaper Service)")
category.finalists.create!(description: "Donald Duck: “The Mad Chemist”, by Carl Barks (Dell Comics)")
category.finalists.create!(description: "Flash Gordon: “Battle for Tropica”, by Don Moore and Alex Raymond (King Features Syndicate)")
category.finalists.create!(description: "Flash Gordon: “Triumph in Tropica”, by Don Moore and Alex Raymond (King Features Syndicate)")
category.finalists.create!(description: "The Spirit: “For the Love of Clara Defoe”, by Manly Wade Wellman, Lou Fine and Don Komisarow (Register and Tribune Syndicate)")
category.finalists.create!(description: "Superman: “The Mysterious Mr. Mxyztplk”, by Jerry Siegel and Joe Shuster (Detective Comics, Inc.)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Dramatic Presentation, Short Form", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "The Canterville Ghost, screenplay by Edwin Harvey Blum from a story by Oscar Wilde, directed by Jules Dassin (Metro-Goldwyn-Mayer (MGM))")
category.finalists.create!(description: "The Curse of the Cat People, written by DeWitt Bodeen, directed by Gunther V. Fritsch and Robert Wise (RKO Radio Pictures)")
category.finalists.create!(description: "Donovan’s Brain, adapted by Robert L. Richards from a story by Curt Siodmak, producer, director and editor William Spier (CBS Radio Network)")
category.finalists.create!(description: "House of Frankenstein, screenplay by Edward T. Lowe, Jr. from a story by Curt Siodmak, directed by Erle C. Kenton (Universal Pictures)")
category.finalists.create!(description: "The Invisible Man’s Revenge, written by Bertram Millhauser, directed by Ford Beebe (Universal Pictures)")
category.finalists.create!(description: "It Happened Tomorrow, screenplay and adaptation by Dudley Nichols and René Clair, directed by René Clair (Arnold Pressburger Films)")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Editor, Short Form", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "John W. Campbell, Jr.")
category.finalists.create!(description: "Oscar J. Friend")
category.finalists.create!(description: "Mary Gnaedinger")
category.finalists.create!(description: "Dorothy McIlwraith")
category.finalists.create!(description: "Raymond A. Palmer")
category.finalists.create!(description: "W. Scott Peacock")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Professional Artist", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "Earle K. Bergey")
category.finalists.create!(description: "Margaret Brundage")
category.finalists.create!(description: "Boris Dolgov")
category.finalists.create!(description: "Matt Fox")
category.finalists.create!(description: "Paul Orban")
category.finalists.create!(description: "William Timmins")
category.finalists.create!(description: "No award")


category = Category.joins(:election).find_by(name: "Best Fanzine", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "The Acolyte, edited by Francis T. Laney and Samuel D. Russell")
category.finalists.create!(description: "Diablerie, edited by Bill Watson")
category.finalists.create!(description: "Futurian War Digest, edited by J. Michael Rosenblum")
category.finalists.create!(description: "Shangri L’Affaires, edited by Charles Burbee")
category.finalists.create!(description: "Voice of the Imagi-Nation, edited by Forrest J. Ackerman and Myrtle R. Douglas")
category.finalists.create!(description: "Le Zombie, edited by Bob Tucker and E.E. Evans")
category.finalists.create!(description: "No award")

category = Category.joins(:election).find_by(name: "Best Fan Writer", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(description: "Fritz Leiber")
category.finalists.create!(description: "Morojo/Myrtle R. Douglas")
category.finalists.create!(description: "J. Michael Rosenblum")
category.finalists.create!(description: "Jack Speer")
category.finalists.create!(description: "Bob Tucker")
category.finalists.create!(description: "Harry Warner, Jr.")
category.finalists.create!(description: "No award")
