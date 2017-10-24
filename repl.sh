#!/usr/bin/env bash

# dist can cause problems with nix-build (called by nix-shell)
# so delete this in between builds
rm -rf dist

## jailbreaks
# chronos
cabal2nix https://github.com/chessai/chronos.git > nix/chronos.nix
# http-types
cabal2nix https://github.com/chessai/http-types.git > nix/http-types.nix
# savage
cabal2nix https://github.com/chessai/savage.git > nix/savage.nix

#this is a workaround while cabal-repl is broken (https://github.com/haskell/cabal/issues/4602)
nix-shell -A silvi.env release.nix --run "cabal update; runhaskell Setup.hs configure; runhaskell Setup.hs repl lib:silvi"

# dist can cause problems with nix-build (called by nix-shell)
# so delete this in between builds
rm -rf dist