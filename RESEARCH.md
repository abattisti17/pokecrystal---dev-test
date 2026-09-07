# Research: Myth Origins

Findings that shaped design decisions. Kept because several of them changed
what got built, and re-deriving them is expensive.

---

## Mew under the truck

**There was never anything there.** The truck is a static decoration with no
interactive properties and no hidden data. What made it irresistible was the
setup: a lone truck near the S.S. Anne, in an area unreachable in normal play,
and the only asset of its kind in the game.

Reaching it needed Surf, but the ship departs forever before Surf is normally
obtainable — so players had to trade in a Pokémon that knew it, or deliberately
lose a battle aboard to be sent back without triggering departure. The ledge was
semi-forbidden knowledge.

**Most versions of the rumor said to use Strength.** Outcomes varied — some said
Mew appeared, others a Team Rocket hideout. This is why the build uses Strength
rather than the bible's four-item gate.

**Mew was designed to be a rumor.** Tajiri conceived it as a character that
exists but doesn't appear, inspired by rumors of hidden secrets in Xevious and
Space Invaders — the speculation itself was the point, and it was meant to be
known only to staff. Morimoto inserted it after debugging freed ~300 bytes,
against an explicit no-changes order, overwriting the first empty index slot he
found. That's why Mew sits oddly early in the internal index, and why its sprite
is small and barely coloured.

Game Freak kept the truck in FireRed/LeafGreen and hid a Lava Cookie there.

**Implication for us:** the myth working as designed, four years late. Our
Strength trigger is the authentic one.

## MissingNo.

**Not a myth — a real bug, with an elegant cause.** Species are one byte, so
151 Pokémon leave 105 empty values. "MissingNo." is short for Missing Number:
what the game emits when it doesn't know what you should be encountering.

The trigger is a chain of small failures. The Old Man's tutorial temporarily
overwrites your name, spawns a Weedle, then restores the battle code — but
Cinnabar's east coast never specifies which Pokémon spawn there, so your stored
name gets read as encounter data.

It corrupts saves because it is not a Pokémon with odd properties — it is the
*absence* of one, and every system touching it reads or writes out of bounds.
The Hall of Fame damage comes from its Pokédex flag being written out of range.

Nintendo documented it in Nintendo Power, May 1999, warning that any contact
could erase a save.

**The empty index slots correspond to the Pokémon cut from the planned 190.**
MissingNo. is literally where the deleted Pokémon used to be — closer to the
project's premise than most fan theories.

**Implication for us:** it cannot go in an "empty slot." Hard-code it, costing a
real species slot, and *simulate* the corruption rather than causing it.

## Gorochu

**Real, confirmed, barely documented.** In a 2018 interview, Pikachu designer
Atsuko Nishida said Pikachu was meant to have a third evolution after Raichu
named Gorochu; Ken Sugimori said it was cut for game balance. Nishida described
bared fangs and a pair of horns, and said it looked like a god of thunder.
Notably it was *not* cut for insufficient cuteness.

The name escalates: "chu" is a mouse squeak, "pika" an electric shock, "rai"
thunder, "goro" the rumble of thunder — Japanese comics caption a thunderclap
"gorogoro."

**Only the back sprite ever surfaced.** The front view is an invention.

## The Pokégods

The 1999 rumor wave: fake Pokémon with Pokédex numbers above 150, supposedly
obtainable via elaborate secret methods — specific party orders, beating the
Elite Four repeatedly, often involving a GameShark or MissingNo.

**About half turned out to be real** under fan names, leaked from early Gen 2
media: Pikablu (Marill), Bruno (Snubbull), Lunareon and Solareon (Espeon and
Umbreon), Houou (Ho-Oh), Denryu (Ampharos).

**Pure invention:** Mewthree, Nidogod, Charcolt, Rainer, Sapusaur, Pikaflare,
Flarechu, Pikabud, Flareth, Doomsday, Mr. Psychic, Dimonix. The pattern: kids
assumed every fully-evolved Pokémon had a secret fourth stage. Charcolt, Rainer
and Sapusaur complete the starter trio; Dimonix is Onix's; Flareth is behind the
playground line "I'll give you Flareth if you go away." A fake **Mist Stone**
was said to evolve anything.

**Jokes that escaped:** Yoshi as Dragonite's evolution (Expert Gamer, April
Fools 1999) and Luigi as Lickitung's, from Nintendo's own site.

**Venustoise** came from the anime rather than the rumor mill — episode 20,
"The Ghost of Maiden's Peak," where a Gastly fuses a Venusaur and Blastoise as
an illusion. The first Pokémon fusion in any medium, and never real in-universe
either.

**Implication for us:** the "cheap" tier (Rainer, Charcolt, Sapusaur, Flareth,
Pikaflare, Pikabud, Dimonix) were recolours of existing sprites in period fan
art — so recolouring is *authentic*, not a shortcut. Mewthree, Nidogod,
Doomsday and Mr. Psychic need original silhouettes.

## The Porygon episode

EP038, "Dennō Senshi Porygon," Dec 16 1997, banned worldwide. The Poké Ball
transfer system malfunctions; Pokémon sent through never arrive. The inventor
realises intruders entered the network with a stolen prototype Porygon and
blockaded it to steal Pokémon in transit, and sends the protagonists inside. A
technician, believing it a virus, deploys an antivirus that attacks everyone
indiscriminately.

**In Gen 2 the PC storage system's inventor is Bill**, so the inventor role is
already occupied by a canon character.

A four-second red/blue strobe hospitalised 685 children. This is the origin of
the project's absolute no-flashing rule.

## Pokémon Prism, for scale

The most ambitious Gen 2 hack ever made: three new types, abilities, a region
larger than Johto, up to 20 badges, eight years of development by a team whose
lead had already shipped Pokémon Brown in 2004.

**Its Pokédex is 253 Pokémon** — exactly the one-byte cap. It got Gen 3 and 4
species in by *replacing*, not adding.

Nintendo issued a cease and desist days before release. The main argument for
distributing patches rather than ROMs.
