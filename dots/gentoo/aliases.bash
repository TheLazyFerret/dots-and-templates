#!/bin/bash

# Multiple aliases to make faster some operations with large commands
# Source this file to add the aliases to your bash sesion

# System update aliases
alias sys-update='sudo emerge --sync'
alias sys-upgrade='sudo emerge --ask --verbose --update --deep --changed-use --getbinpkg @world'
alias sys-clean='sudo emerge --ask --depclean'
alias sys-install='sudo emerge --ask'
