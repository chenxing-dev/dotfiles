**Project 23: Minimalistic Startpage with TUI Aesthetics**  
We are building a single HTML file that uses Alpine.js to create a TUI style startpage.
The page will have keyboard navigation and a terminal-like appearance.
Features:
 - Use a monospace font and GitHub Light High Contrast theme.
 - Keyboard navigation:
     - Arrow keys (up/down) to navigate through the list of entries.
     - Arrow right to open the currently focused link or to expand a category (if it has content).
     - Letter keys to jump to an entry that has a matching shortcut (if defined) or starting letter.
We have an array of entries (files). Each entry can be:
   - A simple link: { name, icon (optional), href }
   - A category: has a `content` array of sub-entries.
 Additionally, some entries have:
   - `dialog`: if true, then instead of directly opening the href, we show a search dialog (a text input) and then use the `search` URL pattern.
   - `description`: shown when the entry is focused.
