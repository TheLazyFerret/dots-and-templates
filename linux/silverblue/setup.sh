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
    state=$(rpm-ostree status | grep -i state | awk '{print $2}')
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
  aux=""
  for package in $LAYER_PACKAGES; do
    if ! is_package_layered "$package"; then
      aux="$aux $package"
    fi
  done
  if [ -z "$aux" ]; then
    echo "Not packages to install"
    return 0
  fi
  wait_ostree_busy
  echo -n "Installing layered packages..."
  if ! rpm-ostree install "$aux" > /dev/null 2>&1; then
    echo " Found an error!"
    return 1
  fi
  echo " Done"
  return 0
}

remove_overrides_ostree() {
  aux=""
  for package in $OVERRIDE_PACKAGES; do
    if ! is_package_overrided "$package"; then
      aux="$aux $package"
    fi
  done
  if [ -z "$aux" ]; then
    echo "Not packages to remove"
    return 0
  fi
  wait_ostree_busy
  echo -n "Removing override packages..."
  if ! rpm-ostree override remove "$OVERRIDE_PACKAGES" > /dev/null 2>&1; then
    echo " Found an error!"
    return 1
  fi
  echo " Done"
  return 0
}

uninstall_flatpak_remote() { # remote
  if ! is_remote_added $1; then
    echo "The remote is not in the remote list"
    return 0
  elif ! is_remote_enabled $1; then
    echo "The remote is already disabled"
    return 0
  fi
  packages_to_remove=$(flatpak list --all --columns=ref,origin | grep "$1" | awk '{print $1}')
  if [ -z "$packages_to_remove" ]; then
    echo "Not packages to uninstall"
    return 0
  fi
  for package in $packages_to_remove; do
    echo -n "Uninstalling $package..."
    flatpak uninstall --delete-data --assumeyes "$package" "$1" > /dev/null 2>&1
    echo " Done"
  done
}

disable_remote() { # remote
  if ! is_remote_added $1; then
    echo "The remote is not in the remote list"
    return 0
  elif ! is_remote_enabled $1; then
    echo "The remote is already disabled"
    return 0
  fi
}

ask_confirmation() { # message

}

### MAIN
