# Package

version       = "0.4.1"
author        = "Jens Alfke"
description   = "Unofficial Nim bindings for libmdbx key-value database"
license       = "Apache-2.0, OpenLDAP"
installDirs   = @["nimdbx", "libmdbx-dist"]

# Dependencies

requires "nim >= 1.9.3"
requires "nimterop >= 0.6.13"
requires "balls >= 4.0.0 & < 5.0.0"
