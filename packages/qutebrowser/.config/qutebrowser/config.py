# pylint: disable=C0114
import os
from qutebrowser.config.configfiles import ConfigAPI
from qutebrowser.config.config import ConfigContainer

config = config  # type: ConfigAPI # pylint: disable=E0602,W0127
c = c  # type: ConfigContainer # pylint: disable=E0602,W0127

config.load_autoconfig(False)

c.content.javascript.clipboard = "access"  # enable clipboard access
c.content.local_content_can_access_remote_urls = True

c.fonts.default_family = ["FiraCode Nerd Font Mono", "Noto Color Emoji"]
c.fonts.default_size = "12pt"

startpage_path = os.path.expanduser(
    "~/.config/qutebrowser/startpage/index.html")
c.url.start_pages = [startpage_path]
c.url.default_page = startpage_path
c.url.searchengines = {
    "DEFAULT": "https://searx.foobar.vip/search?q={}",
}

c.window.hide_decoration = False
