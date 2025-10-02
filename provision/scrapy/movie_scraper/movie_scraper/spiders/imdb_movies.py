import scrapy

class TMDBSpider(scrapy.Spider):
    name = "tmdb_movies"
    allowed_domains = ["themoviedb.org"]

    # Crawl 40 trang đầu tiên
    start_urls = [f"https://www.themoviedb.org/movie?page={i}" for i in range(1, 42)]

    def parse(self, response):
        for movie in response.css('div.card.style_1'):
            title = movie.css('h2 a::text').get()
            detail_url = movie.css('h2 a::attr(href)').get()
            rating = movie.css('div.user_score_chart::attr(data-percent)').get()

            if detail_url:
                yield response.follow(
                    detail_url,
                    self.parse_detail,
                    meta={'title': title, 'rating': rating}
                )

    def parse_detail(self, response):
        title = response.meta['title']
        rating = response.meta['rating']
        release_date = response.css('span.release::text').get()
        if release_date:
            release_date = release_date.strip()

        keywords = response.css('section.keywords ul li a::text').getall()

        cast_list = []
        for li in response.css('ol.people li.card'):
            actor = li.css('p a::text').get()
            character = li.css('p.character::text').get()
            cast_list.append({'actor': actor, 'character': character})

        director = response.css('li.profile a[href*="/person/"]::text').get()

        # Lấy budget
        budget = None
        budget_tag = response.xpath('//p[strong/bdi[text()="Budget"]]')
        if budget_tag:
            budget_text = budget_tag.xpath('text()').get()
            if budget_text:
                budget = budget_text.strip()  # "$200,000,000.00"

        yield {
            'title': title,
            'rating': rating,
            'release_date': release_date,
            'keywords': keywords,
            'cast': cast_list,
            'director': director,
            'budget': budget
        }
