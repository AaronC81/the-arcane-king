# The Arcane King

This is my entry to the [second Gosu Game Jam](https://itch.io/jam/gosu-game-jam-2).

Please see the [Itch page](https://orangeflash81.itch.io/the-arcane-king)!

## Running

```
bundle install
bundle exec ruby ./src/main.rb
```

This has been tested on Ruby 2.7.5 and Ruby 3.0.2, both on macOS Monterey (ARM native).

## Building

### macOS

```
./package_macos
```

Should just work! If uploading to itch, upload the generated .zip, NOT the .app! If you upload the
.app, macOS or Chrome will try to zip the .app automatically and get it wrong, stripping the
execute bit off the `Ruby` binary and breaking it.

### Windows

```
gem install ocra
.\package_windows.bat
```

When the game opens, wait a second and then close it again.

The copy on Itch was built on 32-bit Ruby 2.7.5 from RubyInstaller. The 64-bit Ruby 3.1.1
distribution (which I tried first) didn't work on my Windows on ARM system, giving an error about
`unexpected ucrtbase.dll`!

