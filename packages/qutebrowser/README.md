In your dotfiles repository:

```bash
# Add submodule to startpage directory
git submodule add https://github.com/chenxing-dev/startpage-alpine.git .\packages\qutebrowser\.config\qutebrowser\startpage

# Initialize and update submodule
git submodule update --init --recursive

# Commit the changes
git commit -m "Add startpage-alpine as submodule"
```

In your qutebrowser config (`config.py`):
```python
# Path to startpage in dotfiles repo
startpage_path = os.path.expanduser('~/dotfiles/startpage/index.html')

c.url.start_pages = [startpage_path]
c.url.default_page = startpage_path
```
