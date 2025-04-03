#!/bin/bash

# General function to print text in a given color
colored_format() {
  local texto="$1"
  local color="$2"
  local reset="\e[0m"
  echo -e "${color}${texto}${reset}"
}

# Function to print text in bold blue
blod_blue_format() {
  colored_format "$1" "\e[1;34m"
}

# Function to print text in bold orange (using an ANSI orange approximation)
blod_orange_format() {
  colored_format "$1" "\e[38;5;208m"
}

# Function to print text in bold green
blod_green_format() {
  colored_format "$1" "\e[1;32m"
}