#!/usr/bin/env bash

cd functions

# Get dependencies
pub get

# Get npm packages
npm install --save stream-chat

# Build project
pub run build_runner build --output=build

# Uploading functions to firebase
firebase deploy --only functions