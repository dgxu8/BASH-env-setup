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

## Setting up NERD fonts
1. goto nerd-fonts releases page and download source code pro (saucecodepro)
2. Set it a terminal font via tweaker
3. Set size to 12
4. Set scaling to 0.96 (trying to get 11.5p font)
