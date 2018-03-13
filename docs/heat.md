
I think I do a unique method of heat distribution. It was the only way that made absolute sense to me, albeit not realistic at all (even the units don't match at all).

Although gases are distributed throughout an entire area, temperature is NOT.

Every tile has the following properties that are relevant to heat distribution:
- Temperature (in C) - The temperature of the tile, duh.
- Heat flux (in C/s) - The amount of temperature distributed to adjacent tiles per second. This is calculated based on the gases on the tile.
- Heat capacity (no unit) - A multiplier used when calculating heat spread. Example: If heat capacity of tile A is 2, and tile B attempts to distribute 10C to tile A, tile A will only receive 5C.

Tiles are checked left to right, then up and down.

If a tile has temperature, it will attempt to spread it to any tiles that have less temperature than it (and if the difference between the two tile's temperature <= 0.3).

## Basics of Fire Spreading

Temperature spreads based off **the heat flux of the tile spreading** and **the heat capacity of the tile being spread to**. Currently, heat will flow through the same means that gases spread through, making airlocks double as fire locks. This may change in the future. 

If there are two adjacent tiles (left/right in this case), both having a heat flux of 1C/s and a heat capacity of 1, but the left tile has a temperature of 100C when the right tile has 0C, heat will transfer as such...

100C | 0C -> 99C | 1C -> 98C | 2C ...etc.

## Heat Capacity

The heat capacity of a tile impacts how much heat moves to it. In our previous example, let's say the right tile has a heat capacity of 2. This means **that tile will receive 2x less heat**.

So instead of...

100C | 0C -> 99C | 1C ...etc.

The heat will instead spread like...

100C | 0C -> 99.5C | 0.5C -> 99C | 1C ...etc.

## Heat Flux

The heat flux of a tile determines how much heat spreads to adjacent tiles. Remember the first example, but the left tile instead has a heat flux of 10 C/s.

Assuming ticks last 1 second long (they don't, but it makes the math easier), heat will spread like...

100C | 0C -> 90C | 10C -> 80C | 20C ...etc.

However, heat flux is not the only factor that impacts how much heat a tile will give to an object (ignoring heat capacity). You see, heat always wants to be in equilibrium with the tiles around it if possible. Assume the last example, with the heat flux being 10 C/s, but where the tiles are these temperatures...

55C | 45C

If we assumed heat flux was the only factor at play, the tiles would have their temperature become...

45C | 55C

However, this won't happen because the temperatures can be at equilibrium (this, along with the fact that heat will never spread from a low temperature tile to a high temperature tile, means that a tile will NEVER give more temperature to another tile). 

Instead, the tile will cap off its heat flux and the tiles will instead have the temperatures...

50C | 50C

...and be at equilibrium.

However, heat flux gets a bit weird when dealing with more than just one adjacent tile. Assume this scenario (heat capacities are all 1, middle tile's heat flux is some number over 90).

0C | 90C | 0C

The ideal method of spreading heat in this case would be...

30C | 30C | 30C

...but this is **not the case**. Instead, tiles have temperature distributed individually (the order of which they do this is undocumented and can be intentionally/unintentionally changed at any point without warning, but the scenarios where this matters is so few to care about). 

Assume that heat is spread to first the left tile, then the right tile. The temperatures of the tiles will first be...

45C | 45C | 0C (Note: this won't happen in game because this is all calculated at the same tick).

Then, the tile will spread its heat to the right tile. The temperatures will become...

45C | 22.5C | 22.5C

However, as previously stated, this scenario rarely happens because not only is heat flux unlikely to be this large (and if it is, you're on some special tile that'll likely have a high temperature anyway), but in the next tick (which happens frequently), the heat will start to spread out. Skipping over the individual calculations, the next tick will spread the heat in this way.

33.75C | 28.125C | 28.125C

Notice how the temperatures are a bit more evenly spread. This happens every tick, and soon enough temperature becomes even with each other.

## Space

Space is cold. Duh. To be exact, space is 2.7K (-270.45C). Just like how the gas distribution of space cannot be modified, neither can the temperature of space, meaning space will *always* be 2.7K. Space has no heat flux or heat capacity, but this wouldn't matter anyway because space is especially coded.

It's very simple. **If an area is breached, ALL tiles will become 2.7K and will lose whatever temperature they had previously**. It's the exact same for gas distribution (all gases of an area are terminated once they come into contact with space).