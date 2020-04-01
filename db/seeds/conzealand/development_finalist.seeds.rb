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
category.finalists.create!(
  description: "The Calculating Stars, by Mary Robinette Kowal (Tor)"
)
category.finalists.create!(
  description: "Record of a Spaceborn Few, by Becky Chambers (Hodder & Stoughton / Harper Voyager)"
)
category.finalists.create!(
  description: "Revenant Gun, by Yoon Ha Lee (Solaris)"
)
category.finalists.create!(
  description: "Space Opera, by Catherynne M. Valente (Saga)"
)
category.finalists.create!(
  description: "Spinning Silver, by Naomi Novik (Del Rey / Macmillan)"
)
category.finalists.create!(
  description: "Trail of Lightning, by Rebecca Roanhorse (Saga)"
)

category = Category.joins(:election).find_by!(name: "Best Novella", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Artificial Condition, by Martha Wells (Tor.com Publishing)"
)
category.finalists.create!(
  description: "Beneath the Sugar Sky, by Seanan McGuire (Tor.com Publishing)"
)
category.finalists.create!(
  description: "Binti: The Night Masquerade, by Nnedi Okorafor (Tor.com Publishing)"
)
category.finalists.create!(
  description: "The Black God’s Drums, by P. Djèlí Clark (Tor.com Publishing)"
)
category.finalists.create!(
  description: "Gods, Monsters, and the Lucky Peach, by Kelly Robson (Tor.com Publishing)"
)
category.finalists.create!(
  description: "The Tea Master and the Detective, by Aliette de Bodard (Subterranean Press / JABberwocky Literary Agency)"
)

category = Category.joins(:election).find_by!(name: "Best Novelette", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "If at First You Don’t Succeed, Try, Try Again, by Zen Cho (B&N Sci-Fi and Fantasy Blog, 29 November 2018)"
)
category.finalists.create!(
  description: "The Last Banquet of Temporal Confections, by Tina Connolly (Tor.com, 11 July 2018)"
)
category.finalists.create!(
  description: "Nine Last Days on Planet Earth, by Daryl Gregory (Tor.com, 19 September 2018)"
)
category.finalists.create!(
  description: "The Only Harmless Great Thing, by Brooke Bolander (Tor.com Publishing)"
)
category.finalists.create!(
  description: "The Thing About Ghost Stories, by Naomi Kritzer (Uncanny Magazine 25, November- December 2018)"
)
category.finalists.create!(
  description: "When We Were Starless, by Simone Heller (Clarkesworld 145, October 2018)"
)

category = Category.joins(:election).find_by!(name: "Best Short Story", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "The Court Magician, by Sarah Pinsker (Lightspeed, January 2018)"
)
category.finalists.create!(
  description: "The Rose MacGregor Drinking and Admiration Society, by T. Kingfisher (Uncanny Magazine 25, November-December 2018)"
)
category.finalists.create!(
  description: "The Secret Lives of the Nine Negro Teeth of George Washington, by P. Djèlí Clark (Fireside Magazine, February 2018)"
)
category.finalists.create!(
  description: "STET, by Sarah Gailey (Fireside Magazine, October 2018)"
)
category.finalists.create!(
  description: "The Tale of the Three Beautiful Raptor Sisters, and the Prince Who Was Made of Meat, by Brooke Bolander (Uncanny Magazine 23, July-August 2018)"
)
category.finalists.create!(
  description: "A Witch’s Guide to Escape: A Practical Compendium of Portal Fantasies, by Alix E. Harrow (Apex Magazine, February 2018)"
)

category = Category.joins(:election).find_by(name: "Best Series", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "The Centenal Cycle, by Malka Older (Tor.com Publishing)"
)
category.finalists.create!(
  description: "The Laundry Files, by Charles Stross (most recently Tor.com Publishing/Orbit)"
)
category.finalists.create!(
  description: "Machineries of Empire, by Yoon Ha Lee (Solaris)"
)
category.finalists.create!(
  description: "The October Daye Series, by Seanan McGuire (most recently DAW)"
)
category.finalists.create!(
  description: "The Universe of Xuya, by Aliette de Bodard (most recently Subterranean Press)"
)
category.finalists.create!(
  description: "Wayfarers, by Becky Chambers (Hodder & Stoughton / Harper Voyager)"
)

category = Category.joins(:election).find_by(name: "Best Related Work", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Archive of Our Own, a project of the Organization for Transformative Works"
)
category.finalists.create!(
  description: "Astounding: John W. Campbell, Isaac Asimov, Robert A. Heinlein, L. Ron Hubbard, and the Golden Age of Science Fiction, by Alec Nevala-Lee (Dey Street Books)"
)
category.finalists.create!(
  description: "The Hobbit Duology (documentary in three parts), written and edited by Lindsay Ellis and Angelina Meehan (YouTube)"
)
category.finalists.create!(
  description: "An Informal History of the Hugos: A Personal Look Back at the Hugo Awards, 1953- 2000, by Jo Walton (Tor)"
)
category.finalists.create!(
  description: "www.mexicanxinitiative.com: The Mexicanx Initiative Experience at Worldcon 76 (Julia Rios, Libia Brenda, Pablo Defendini, John Picacio)"
)
category.finalists.create!(
  description: "Ursula K. Le Guin: Conversations on Writing, by Ursula K. Le Guin with David Naimon (Tin House Books)"
)

category = Category.joins(:election).find_by(name: "Best Graphic Story or Comic", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Abbott, written by Saladin Ahmed, art by Sami Kivelä, colours by Jason Wordie, letters by Jim Campbell (BOOM! Studios)"
)
category.finalists.create!(
  description: "Black Panther: Long Live the King, written by Nnedi Okorafor and Aaron Covington, art by André Lima Araújo, Mario Del Pennino and Tana Ford (Marvel)"
)
category.finalists.create!(
  description: "Monstress, Volume 3: Haven, written by Marjorie Liu, art by Sana Takeda (Image Comics)"
)
category.finalists.create!(
  description: "On a Sunbeam, by Tillie Walden (First Second)"
)
category.finalists.create!(
  description: "Paper Girls, Volume 4, written by Brian K. Vaughan, art by Cliff Chiang, colours by Matt Wilson, letters by Jared K. Fletcher (Image Comics)"
)
category.finalists.create!(
  description: "Saga, Volume 9, written by Brian K. Vaughan, art by Fiona Staples (Image Comics)"
)

category = Category.joins(:election).find_by(name: "Best Dramatic Presentation, Long Form", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Annihilation, directed and written for the screen by Alex Garland, based on the novel by Jeff VanderMeer (Paramount Pictures / Skydance)"
)
category.finalists.create!(
  description: "Avengers: Infinity War, screenplay by Christopher Markus and Stephen McFeely, directed by Anthony Russo and Joe Russo (Marvel Studios)"
)
category.finalists.create!(
  description: "Black Panther, written by Ryan Coogler and Joe Robert Cole, directed by Ryan Coogler (Marvel Studios)"
)
category.finalists.create!(
  description: "A Quiet Place, screenplay by Scott Beck, John Krasinski and Bryan Woods, directed by John Krasinski (Platinum Dunes / Sunday Night)"
)
category.finalists.create!(
  description: "Sorry to Bother You, written and directed by Boots Riley (Annapurna Pictures)"
)
category.finalists.create!(
  description: "Spider-Man: Into the Spider-Verse, screenplay by Phil Lord and Rodney Rothman, directed by Bob Persichetti, Peter Ramsey and Rodney Rothman (Sony)"
)

category = Category.joins(:election).find_by(name: "Best Dramatic Presentation, Short Form", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "The Expanse: Abaddon’s Gate, written by Daniel Abraham, Ty Franck and Naren Shankar, directed by Simon Cellan Jones (Penguin in a Parka / Alcon Entertainment)"
)
category.finalists.create!(
  description: "Doctor Who: Demons of the Punjab, written by Vinay Patel, directed by Jamie Childs (BBC)"
)
category.finalists.create!(
  description: "Dirty Computer, written by Janelle Monáe, directed by Andrew Donoho and Chuck Lightning (Wondaland Arts Society / Bad Boy Records / Atlantic Records)"
)
category.finalists.create!(
  description: "The Good Place: Janet(s), written by Josh Siegal & Dylan Morgan, directed by Morgan Sackett (NBC)"
)
category.finalists.create!(
  description: "The Good Place: Jeremy Bearimy, written by Megan Amram, directed by Trent O’Donnell (NBC)"
)
category.finalists.create!(
  description: "Doctor Who: Rosa, written by Malorie Blackman and Chris Chibnall, directed by Mark Tonderai (BBC)"
)

category = Category.joins(:election).find_by(name: "Best Editor, Short Form", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Neil Clarke"
)
category.finalists.create!(
  description: "Gardner Dozois"
)
category.finalists.create!(
  description: "Lee Harris"
)
category.finalists.create!(
  description: "Julia Rios"
)
category.finalists.create!(
  description: "Lynne M. Thomas and Michael Damian Thomas"
)
category.finalists.create!(
  description: "E. Catherine Tobler"
)

category = Category.joins(:election).find_by(name: "Best Editor, Long Form", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Sheila E. Gilbert"
)
category.finalists.create!(
  description: "Anne Lesley Groell"
)
category.finalists.create!(
  description: "Beth Meacham"
)
category.finalists.create!(
  description: "Diana Pho"
)
category.finalists.create!(
  description: "Gillian Redfearn"
)
category.finalists.create!(
  description: "Navah Wolfe"
)

category = Category.joins(:election).find_by(name: "Best Professional Artist", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Galen Dara"
)
category.finalists.create!(
  description: "Jaime Jones"
)
category.finalists.create!(
  description: "Victo Ngai"
)
category.finalists.create!(
  description: "John Picacio"
)
category.finalists.create!(
  description: "Yuko Shimizu"
)
category.finalists.create!(
  description: "Charles Vess"
)

category = Category.joins(:election).find_by(name: "Best Semiprozine", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Beneath Ceaseless Skies, editor-in-chief and publisher Scott H. Andrews"
)
category.finalists.create!(
  description: "Fireside Magazine, edited by Julia Rios, managing editor Elsa Sjunneson-Henry, copyeditor Chelle Parker; social coordinator Meg Frank, special features editor Tanya DePass, founding editor Brian White, publisher and art director Pablo Defendini"
)
category.finalists.create!(
  description: "FIYAH Magazine of Black Speculative Fiction, executive editors Troy L. Wiggins and DaVaun Sanders, editors L.D. Lewis, Brandon O’Brien, Kaleb Russell, Danny Lore, and Brent Lambert"
)
category.finalists.create!(
  description: "Shimmer, publisher Beth Wodzinski, senior editor E. Catherine Tobler"
)
category.finalists.create!(
  description: "Strange Horizons, edited by Jane Crowley, Kate Dollarhyde, Vanessa Rose Phin, Vajra Chandrasekera, Romie Stott, Maureen Kincaid Speller, and the Strange Horizons Staff"
)
category.finalists.create!(
  description: "Uncanny Magazine, publishers/editors-in-chief Lynne M. Thomas and Michael Damian Thomas, managing editor Michi Trota, podcast producers Erika Ensign and Steven Schapansky, Disabled People Destroy Science Fiction Special Issue editors-in-chief Elsa Sjunneson-Henry and Dominik Parisien"
)

category = Category.joins(:election).find_by(name: "Best Fanzine", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Galactic Journey, founder Gideon Marcus, editor Janice Marcus"
)
category.finalists.create!(
  description: "Journey Planet, edited by Team Journey Planet"
)
category.finalists.create!(
  description: "Lady Business, editors Ira, Jodie, KJ, Renay & Susan"
)
category.finalists.create!(
  description: "nerds of a feather, flock together, editors Joe Sherry, Vance Kotrla and The G"
)
category.finalists.create!(
  description: "Quick Sip Reviews, editor Charles Payseur"
)
category.finalists.create!(
  description: "Rocket Stack Rank, editors Greg Hullender and Eric Wong"
)

category = Category.joins(:election).find_by(name: "Best Fancast", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Be the Serpent, presented by Alexandra Rowland, Freya Marske and Jennifer Mace"
)
category.finalists.create!(
  description: "The Coode Street Podcast, presented by Jonathan Strahan and Gary K. Wolfe"
)
category.finalists.create!(
  description: "Fangirl Happy Hour, hosted by Ana Grilo and Renay Williams"
)
category.finalists.create!(
  description: "Galactic Suburbia, hosted by Alisa Krasnostein, Alexandra Pierce, and Tansy Rayner Roberts, produced by Andrew Finch"
)
category.finalists.create!(
  description: "Our Opinions Are Correct, hosted by Annalee Newitz and Charlie Jane Anders"
)
category.finalists.create!(
  description: "The Skiffy and Fanty Show, produced by Jen Zink and Shaun Duke, hosted by the Skiffy and Fanty Crew"
)

category = Category.joins(:election).find_by(name: "Best Fan Writer", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Foz Meadows"
)
category.finalists.create!(
  description: "James Davis Nicoll"
)
category.finalists.create!(
  description: "Charles Payseur"
)
category.finalists.create!(
  description: "Elsa Sjunneson-Henry"
)
category.finalists.create!(
  description: "Alasdair Stuart"
)
category.finalists.create!(
  description: "Bogi Takács"
)

category = Category.joins(:election).find_by(name: "Best Fan Artist", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Sara Felix"
)
category.finalists.create!(
  description: "Grace P. Fong"
)
category.finalists.create!(
  description: "Meg Frank"
)
category.finalists.create!(
  description: "Ariela Housman"
)
category.finalists.create!(
  description: "Likhain (Mia Sereno)"
)
category.finalists.create!(
  description: "Spring Schoenhuth"
)

category = Category.joins(:election).find_by(name: "Astounding Award for the best new science fiction writer, sponsored by Dell Magazines (not a Hugo)", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "Katherine Arden (2nd year of eligibility)"
)
category.finalists.create!(
  description: "S.A. Chakraborty (2nd year of eligibility)"
)
category.finalists.create!(
  description: "R.F. Kuang (1st year of eligibility)"
)
category.finalists.create!(
  description: "Jeannette Ng (2nd year of eligibility)"
)
category.finalists.create!(
  description: "Vina Jie-Min Prasad (2nd year of eligibility)"
)
category.finalists.create!(
  description: "Rivers Solomon (2nd year of eligibility)"
)

category = Category.joins(:election).find_by(name: "Lodestar Award for Best Young Adult Book (not a Hugo)", elections: { i18n_key: "hugo" })
category.finalists.create!(
  description: "The Belles, by Dhonielle Clayton (Freeform / Gollancz)"
)
category.finalists.create!(
  description: "Children of Blood and Bone, by Tomi Adeyemi (Henry Holt / Macmillan Children’s Books)"
)
category.finalists.create!(
  description: "The Cruel Prince, by Holly Black (Little, Brown / Hot Key Books)"
)
category.finalists.create!(
  description: "Dread Nation, by Justina Ireland (Balzer + Bray)"
)
category.finalists.create!(
  description: "The Invasion, by Peadar O’Guilin (David Fickling Books / Scholastic)"
)
category.finalists.create!(
  description: "Tess of the Road, by Rachel Hartman (Random House / Penguin Teen)"
)

category = Category.joins(:election).find_by(name: "Retro Best Novel", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Conjure Wife, by Fritz Leiber, Jr. (Unknown Worlds, April 1943)"
)
category.finalists.create!(
  description: "Earth’s Last Citadel, by C.L. Moore and Henry Kuttner (Argosy, April 1943)"
)
category.finalists.create!(
  description: "Gather, Darkness! by Fritz Leiber, Jr. (Astounding Science-Fiction, May-July 1943)"
)
category.finalists.create!(
  description: "Das Glasperlenspiel [The Glass Bead Game], by Hermann Hesse (Fretz & Wasmuth)"
)
category.finalists.create!(
  description: "Perelandra, by C.S. Lewis (John Lane, The Bodley Head)"
)
category.finalists.create!(
  description: "The Weapon Makers, by A.E. van Vogt (Astounding Science-Fiction, February-April 1943)"
)

category = Category.joins(:election).find_by(name: "Retro Best Novella", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Attitude, by Hal Clement (Astounding Science-Fiction, September 1943)"
)
category.finalists.create!(
  description: "Clash by Night, by Lawrence O’Donnell (Henry Kuttner & C.L. Moore) (Astounding Science-Fiction, March 1943)"
)
category.finalists.create!(
  description: "The Dream-Quest of Unknown Kadath, by H.P. Lovecraft, (Beyond the Wall of Sleep, Arkham House)"
)
category.finalists.create!(
  description: "The Little Prince, by Antoine de Saint-Exupéry (Reynal & Hitchcock)"
)
category.finalists.create!(
  description: "The Magic Bed-Knob; or, How to Become a Witch in Ten Easy Lessons, by Mary Norton (Hyperion Press)"
)
category.finalists.create!(
  description: "We Print the Truth, by Anthony Boucher (Astounding Science-Fiction, December 1943)"
)

category = Category.joins(:election).find_by(name: "Retro Best Novelette", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Citadel of Lost Ships, by Leigh Brackett (Planet Stories, March 1943)"
)
category.finalists.create!(
  description: "The Halfling, by Leigh Brackett (Astonishing Stories, February 1943)"
)
category.finalists.create!(
  description: "Mimsy Were the Borogoves, by Lewis Padgett (C.L. Moore & Henry Kuttner) (Astounding Science-Fiction, February 1943)"
)
category.finalists.create!(
  description: "The Proud Robot, by Lewis Padgett (Henry Kuttner) (Astounding Science-Fiction, February 1943)"
)
category.finalists.create!(
  description: "Symbiotica, by Eric Frank Russell (Astounding Science-Fiction, October 1943)"
)
category.finalists.create!(
  description: "Thieves’ House, by Fritz Leiber, Jr (Unknown Worlds, February 1943)"
)

category = Category.joins(:election).find_by(name: "Retro Best Short Story", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Death Sentence, by Isaac Asimov (Astounding Science Fiction, November 1943)"
)
category.finalists.create!(
  description: "Doorway into Time, by C.L. Moore (Famous Fantastic Mysteries, September 1943)"
)
category.finalists.create!(
  description: "Exile, by Edmond Hamilton (Super Science Stories, May 1943)"
)
category.finalists.create!(
  description: "King of the Gray Spaces (R is for Rocket), by Ray Bradbury (Famous Fantastic Mysteries, December 1943)"
)
category.finalists.create!(
  description: "Q.U.R., by H.H. Holmes (Anthony Boucher) (Astounding Science-Fiction, March 1943)"
)
category.finalists.create!(
  description: "Yours Truly – Jack the Ripper, by Robert Bloch (Weird Tales, July 1943)"
)

category = Category.joins(:election).find_by(name: "Retro Best Graphic Story or Comic", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Buck Rogers: Martians Invade Jupiter, by Philip Nowlan and Dick Calkins (National Newspaper Service)"
)
category.finalists.create!(
  description: "Flash Gordon: Fiery Desert of Mongo, by Alex Raymond (King Features Syndicate)"
)
category.finalists.create!(
  description: "Garth, by Steve Dowling (Daily Mirror)"
)
category.finalists.create!(
  description: "Plastic Man #1: The Game of Death, by Jack Cole (Vital Publications)"
)
category.finalists.create!(
  description: "Le Secret de la Licorne [The Secret of the Unicorn], by Hergé (Le Soir)"
)
category.finalists.create!(
  description: "Wonder Woman #5: Battle for Womanhood, written by William Moulton Marsden, art by Harry G. Peter (DC Comics)"
)

category = Category.joins(:election).find_by(name: "Retro Best Dramatic Presentation, Long Form", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Batman, written by Victor McLeod, Leslie Swabacker and Harry L. Fraser, directed by Lambert Hillyer (Columbia Pictures)"
)
category.finalists.create!(
  description: "Cabin in the Sky, written by Joseph Schrank, directed by Vincente Minnelli and Busby Berkeley (uncredited) (MGM)"
)
category.finalists.create!(
  description: "A Guy Named Joe, written by Frederick Hazlitt Brennan and Dalton Trumbo, directed by Victor Fleming (MGM)"
)
category.finalists.create!(
  description: "Heaven Can Wait, written by Samson Raphaelson, directed by Ernst Lubitsch (20th Century Fox)"
)
category.finalists.create!(
  description: "Münchhausen, written by Erich Kästner and Rudolph Erich Raspe, directed by Josef von Báky (UFA)"
)
category.finalists.create!(
  description: "Phantom of the Opera, written by Eric Taylor, Samuel Hoffenstein and Hans Jacoby, directed by Arthur Lubin (Universal Pictures)"
)

category = Category.joins(:election).find_by(name: "Retro Best Dramatic Presentation, Short Form", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "The Ape Man, written by Barney A. Sarecky, directed by William Beaudine (Banner Productions)"
)
category.finalists.create!(
  description: "Frankenstein Meets the Wolfman, written by Curt Siodmak, directed by Roy William Neill (Universal Pictures)"
)
category.finalists.create!(
  description: "Der Fuehrer’s Face, story by Joe Grant and Dick Huemer, directed by Jack Kinney (Disney)"
)
category.finalists.create!(
  description: "I Walked With a Zombie, written by Curt Siodmak and Ardel Wray, directed by Jacques Tourneur (RKO Radio Pictures)"
)
category.finalists.create!(
  description: "The Seventh Victim, written by Charles O’Neal and DeWitt Bodeen, directed by Mark Robson (RKO Radio Pictures)"
)
category.finalists.create!(
  description: "Super-Rabbit, written by Tedd Pierce, directed by Charles M. Jones (Warner Bros)"
)

category = Category.joins(:election).find_by(name: "Retro Best Editor, Short Form", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "John W. Campbell"
)
category.finalists.create!(
  description: "Oscar J. Friend"
)
category.finalists.create!(
  description: "Mary Gnaedinger"
)
category.finalists.create!(
  description: "Dorothy McIlwraith"
)
category.finalists.create!(
  description: "Raymond A. Palmer"
)
category.finalists.create!(
  description: "Donald A. Wollheim"
)

category = Category.joins(:election).find_by(name: "Retro Best Professional Artist", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Hannes Bok"
)
category.finalists.create!(
  description: "Margaret Brundage"
)
category.finalists.create!(
  description: "Virgil Finlay"
)
category.finalists.create!(
  description: "Antoine de Saint-Exupéry"
)
category.finalists.create!(
  description: "J. Allen St. John"
)
category.finalists.create!(
  description: "William Timmins"
)

category = Category.joins(:election).find_by(name: "Retro Best Fanzine", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Guteto, edited by Morojo (Myrtle R. Douglas)"
)
category.finalists.create!(
  description: "Futurian War Digest, editor J. Michael Rosenblum"
)
category.finalists.create!(
  description: "The Phantagraph, editor Donald A. Wollheim"
)
category.finalists.create!(
  description: "Voice of the Imagi-Nation, editors Jack Erman (Forrest J Ackerman) & Morojo (Myrtle Douglas)"
)
category.finalists.create!(
  description: "YHOS, editor Art Widner"
)
category.finalists.create!(
  description: "Le Zombie, editor Wilson Bob Tucker"
)

category = Category.joins(:election).find_by(name: "Retro Best Fan Writer", elections: { i18n_key: "retro_hugo" })
category.finalists.create!(
  description: "Forrest J. Ackerman"
)
category.finalists.create!(
  description: "Morojo (Myrtle Douglas)"
)
category.finalists.create!(
  description: "Jack Speer"
)
category.finalists.create!(
  description: "Wilson Bob Tucker"
)
category.finalists.create!(
  description: "Art Widner"
)
category.finalists.create!(
  description: "Donald A. Wollheim"
)
