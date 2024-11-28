
# plevel

simple tool for converting [ldtk json files](https://ldtk.io/json/) into a more friendly to parse format for nullstars.


## how

compile with cargo

```sh
cargo build --release
```

```sh
cargo run --release path/to/input.ldtk path/to/output.bin
```


## why

the original naive solution to loading nullstars' map was to load every json file when the game starts, using `json_parse()`.
this had a tendency to use a massive amount of memory, likely from the bloated size of ldtk files. by the time I had finished `room_52`, nullstars was eating 900mbs of ram. I didn't like that.

to fix this, I was planning on only loading the files in when they got nearby. 
however, performance tests showed that on my intel 11th gen i5, parsing an `.ldtkl` file using gml's `json_parse()` blocks for a worst case of 90ms. well enough to feel a long stutter. 

this tool extracts the information nullstars needs from map files and packs them into contiguous file things. this is much faster to parse in gamemaker, and leaves open the option of deferring the unpacking of some layers over multiple frames.


