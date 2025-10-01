#!/usr/bin/env bash

is_ostree_busy() {
  while true; do
    state=$(rpm-ostree status | grep -i state | awk '{print $1}')
    if [ "$state" = "busy" ]; then
      echo "rpm-ostree is busy, waiting"
      sleep 10
    else
      return
    fi
  done
}

is_package_layered() {
  layered_packages=$(rpm-ostree status | grep -i LayeredPackages | head -n 1 | awk '{for (i = 2; i <= NF; ++i) printf "%s ", $i} END {print""}')
  for package in "$layered_packages"; do
    if [ "$1" = "$package" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}

is_package_overrided() {
  overrided_packages=$(rpm-ostree status | grep -i RemovedBasePackages | head -n 1 | awk '{for (i = 2; i <= NF; ++i) printf "%s ", $i} END {print""}')
  for package in "$overrided_packages"; do
    if [ "$i" = "$package" ]; then # Found a coincidence
      return 0
    fi
  done
  return 1
}