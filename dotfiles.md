## **Dotfiles for Arch Linux**

A reproducible, version-controlled system configuration for Arch Linux using **GNU Stow** to manage dotfiles (Starship, Qtile, Rofi, Fish, Wezterm) and leverage **archinstall** for simplified OS setup. Deliver a one-command environment deployment.

### **Structure**  

   ```  
   dotfiles/  
   ├── archinstall/    
   │   └── config.json
   ├── wezterm/  
   │   └── .config/wezterm/wezterm.lua  
   ├── fish/  
   │   └── .config/fish/  
   ├── starship/  
   │   └── .config/starship.toml  
   ├── qtile/  
   │   └── .config/qtile/  
   ├── rofi/  
   │   └── .config/rofi/  
   ├── scripts/  
   │   └── dotfiles-setup.sh  
   └── README.md  
   ```  
   - Version-controlled configs for:  
     - **Starship** (cross-shell prompt)  
     - **Qtile** (window manager)  
     - **Rofi** (application launcher)  
     - **Fish** (shell with plugins like `fisher`)  
     - **Wezterm** (GPU-accelerated terminal with Lua config)
     - Other tools (e.g., Neovim, Picom).  
   - Run `stow -vt ~ */` to symlink all configs to `$HOME`.

### **Bash Automation Scripts**  
   - `config.json`: Guided Arch Linux installation configuration. 
   - `dotfiles-setup.sh`: Installs dependencies, clones the repo, and links/configures dotfiles.  
