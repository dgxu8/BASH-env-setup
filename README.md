# BASH-env-setup
setup scripts for linux bash environments

# WSL
## Improve wsl performance
In powershell run:
New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)" -Action Allow

## Common issues
### apt broken
Sometimes the clock may be wrong reset the hwclock with: `sudo hwclock --hctosys`

### treesitter issues
may need to explicitly install treesitter for language: `:TSUpdate {language}`
