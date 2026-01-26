#!/bin/bash

# Multiple aliases to make faster some operations with large commands
# Source this file to add the aliases to your bash sesion

# System update aliases
## Sync portage tree.
alias sys-update='sudo emerge --sync'
## Update the system (with dependencies and using binhost).
alias sys-upgrade='sudo emerge --ask --verbose --update --deep --changed-use --getbinpkg @world'
## Remove orphaned and unused packages.
alias sys-clean='sudo emerge --ask --depclean'
