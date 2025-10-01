#!/usr/bin/env bash

# For all functions: 
#   0 -> true 
#   1 -> false

### CONSTANTS
LAYER_PACKAGES="distrobox steam-devices"
OVERRIDE_PACKAGES="firefox firefox-langpacks"

### FUNCTIONS
wait_ostree_busy() {
  while true; do
    state=$(rpm-ostree status | grep -i state | awk '{print $1}')
    if [ "$state" = "busy" ]; then
      echo "rpm-ostree is busy, waiting"
      sleep 10
    else
      return 0
    fi
  done
}

is_package_layered() {
  layered_packages=$(rpm-ostree status | grep -i LayeredPackages | head -n 1 | awk '{for (i = 2; i <= NF; ++i) printf "%s ", $i} END {print""}')
  for package in $layered_packages; do
    echo $package
    if [ "$1" = "$package" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_package_overrided() {
  overrided_packages=$(rpm-ostree status | grep -i RemovedBasePackages | head -n 1 | awk '{for (i = 2; i <= NF; ++i) printf "%s ", $i} END {print""}')
  for package in $overrided_packages; do
    if [ "$1" = "$package" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_ref_installed() { # ref # package
  installed_refs=$(flatpak list --columns=ref,origin | grep flathub | awk '{print $1}')
  for ref in $installed_refs; do
    if [ "$1" = "$ref" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_remote_enabled() {
  active_remotes=$(flatpak remotes | awk '{print $1}')
  for remote in $active_remotes; do
    if [ "$1" = "$remote" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_remote_added() {
  added_remotes=$(flatpak remotes --show-disabled  | awk '{print $1}')
  for remote in $added_remotes; do
    if [ "$1" = "$remote" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

update_ostree() {
  wait_ostree_busy
  echo -n "Updating system..."
  rpm-ostree update > /dev/null 2>&1
  echo " Done"
  return 0
}

install_layers_ostree() {
  wait_ostree_busy
  echo -n "Installing layered packages..."
  if ! rpm-ostree install "$LAYER_PACKAGES" > /dev/null 2>&1; then
    echo " Found an error!"
    return 1
  fi
  echo " Done"
  return 0
}

remove_overrides_ostree() {
  wait_ostree_busy
  echo -n "Removing override packages..."
  if ! rpm-ostree override remove "$OVERRIDE_PACKAGES" > /dev/null 2>&1; then
    echo " Found an error!"
    return 1
  fi
  echo " Done"
  return 0
}

### MAIN
