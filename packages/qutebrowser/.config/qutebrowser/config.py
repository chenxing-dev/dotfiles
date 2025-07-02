# pylint: disable=C0114
from qutebrowser.config.configfiles import ConfigAPI
from qutebrowser.config.config import ConfigContainer
config = config  # type: ConfigAPI # pylint: disable=E0602,W0127
c = c  # type: ConfigContainer # pylint: disable=E0602,W0127

# c.fonts.default_family = "'FiraCode Nerd Font Mono'"

c.url.default_page = "~/.config/qutebrowser/startpage/index.html"
c.url.start_pages = "~/.config/qutebrowser/startpage/index.html"

c.url.searchengines = {
    'DEFAULT': 'https://searx.foobar.vip/search?q={}',
}
