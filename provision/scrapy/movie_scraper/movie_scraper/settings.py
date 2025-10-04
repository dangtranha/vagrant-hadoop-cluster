BOT_NAME = "movie_scraper"

SPIDER_MODULES = ["movie_scraper.spiders"]
NEWSPIDER_MODULE = "movie_scraper.spiders"

# Fake User-Agent để tránh bị chặn
DEFAULT_REQUEST_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/117.0.0.0 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.9',
}
