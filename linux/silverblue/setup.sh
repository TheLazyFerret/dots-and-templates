#!/usr/bin/env bash

# For all functions: 
#   0 -> true 
#   1 -> false

is_ostree_busy() {
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
