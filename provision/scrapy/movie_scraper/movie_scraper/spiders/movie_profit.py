import scrapy
import json
from urllib.parse import quote_plus
import os

class BoxOfficeSpider(scrapy.Spider):
    name = 'movie_profit'
    
    def start_requests(self):
        # Đọc danh sách phim từ file JSON
        data_path = os.path.join('data', 'tmdb_movies.json')
        with open(data_path, 'r', encoding='utf-8') as f:
            movies = json.load(f)
        
        for movie in movies:
            title = movie.get('title')  # Lấy trường title
            if title:
                url = f'https://www.boxofficemojo.com/search/?q={quote_plus(title)}'
                yield scrapy.Request(url, callback=self.parse_search, meta={'movie_name': title})

    def parse_search(self, response):
        movie_name = response.meta['movie_name']
        # Chọn phần tử đầu tiên
        first_result = response.css('div.mojo-gutter a.a-link-normal::attr(href)').get()
        if first_result:
            detail_url = response.urljoin(first_result)
            yield scrapy.Request(detail_url, callback=self.parse_detail, meta={'movie_name': movie_name})

    def parse_detail(self, response):
        movie_name = response.meta['movie_name']
        # Lấy các thông tin doanh thu
        revenue = {}
        sections = response.css('div.mojo-performance-summary-table > div.a-section.a-spacing-none')
        for sec in sections:
            label = sec.css('span.a-size-small::text').get()
            if not label:
                label = sec.xpath('normalize-space(span[@class="a-size-small"]/text())').get()
            
            value = sec.css('span.money::text').get()
            if label and value:
                label = label.strip().split()[0]  # lấy Domestic / International / Worldwide
                revenue[label] = value.strip()

        yield {
            'movie_name': movie_name,
            'domestic': revenue.get('Domestic', None),
            'international': revenue.get('International', None),
            'worldwide': revenue.get('Worldwide', None)
        }
