#!/bin/bash

# Path to .zshrc
zshrc_file="$HOME/.zshrc"
changes_made=false

# Get the current directory
current_dir=$(pwd)

# Add current directory to PATH if it's not already there
if ! grep -q "export PATH=\"$current_dir:\$PATH\"" "$zshrc_file"; then
  echo "export PATH=\"$current_dir:\$PATH\"" >> "$zshrc_file"
  echo "" >> "$zshrc_file"  # Add an empty line after the block
  echo "Added $current_dir to PATH in .zshrc"
  changes_made=true
fi

# Check if alias file exists in the current directory and source it if it's not already sourced
if [ -f "$current_dir/alias" ]; then
  if ! grep -q "source $current_dir/alias" "$zshrc_file"; then
    echo "if [ -f $current_dir/alias ]; then" >> "$zshrc_file"
    echo "  source $current_dir/alias" >> "$zshrc_file"
    echo "fi" >> "$zshrc_file"
    echo "" >> "$zshrc_file"  # Add an empty line after the block
    echo "Added alias sourcing block for $current_dir/alias to .zshrc"
    changes_made=true
  fi
fi

# Source .zshrc if changes were made
if [ "$changes_made" = true ]; then
  source "$zshrc_file"
  echo ".zshrc has been sourced"
else
  echo "No changes were made to .zshrc"
fi

