# Dotfiles

a dotfiles repository for Arch Linux using GNU Stow, with an automated setup script and `archinstall` configuration.  

1. **Repository Structure**:  
   ```bash
   dotfiles/
   ├── packages/          # GNU Stow directories
   │   ├── qtile/.config/qtile/
   │   ├── picom/.config/picom/
   │   ├── wezterm/.config/wezterm/
   │   └── ...                
   ├── scripts/
   │   └── setup.sh            # Dotfiles deployment script
   ├── config.json             # archinstall configuration
   └── README.md               # Usage/docs
   ```  

2. **Automated Setup Script (`setup.sh`)**  
   - **Functionality**:  
     - Install GNU Stow if missing.  
     - Backup existing dotfiles to `~/dotfiles_backup/`.  
     - Deploy new dotfiles via `stow`.  
     - Restore backups on failure.  
   - **Usage**: `./setup.sh --all` (deploy all) or `./setup.sh qtile wezterm` (selective).  

#### **Action Plan**  

**Build `setup.sh`**:  
   - Implement backup logic with `mkdir -p ~/dotfiles_backup && cp -RL ~/.config ~/dotfiles_backup`.  
   - Use `stow --target=$HOME --restow $package` for deployment.  
