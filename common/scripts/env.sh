#!/bin/sh

# .env loading in the shell
dotenv () {
  set -a
  [ -f $HOME/.env ] && . $HOME/.env
  set +a
}

# Run dotenv on login
dotenv