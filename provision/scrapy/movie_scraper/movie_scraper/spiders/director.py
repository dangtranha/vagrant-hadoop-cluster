import scrapy

class TMDbDirectorFromMovieSpider(scrapy.Spider):
    name = "tmdb_director"
    allowed_domains = ["themoviedb.org"]
    start_urls = [f"https://www.themoviedb.org/movie?page={i}" for i in range(1, 42)]

    def parse(self, response):
        # Lấy danh sách phim trong trang
        for movie in response.css('div.card.style_1'):
            detail_url = movie.css('h2 a::attr(href)').get()
            if detail_url:
                yield response.follow(detail_url, self.parse_detail)

        # Trang tiếp theo
        next_page = response.css('a[rel="next"]::attr(href)').get()
        if next_page:
            yield response.follow(next_page, self.parse)

    def parse_detail(self, response):
        # Chỉ lấy những người có vai trò Director
        for director_li in response.css('ol.people.no_image li.profile'):
            role = director_li.css('p.character::text').get()
            if role and role.strip().lower() == 'director':
                director_link = director_li.css('p a::attr(href)').get()
                if director_link:
                    yield response.follow(director_link, self.parse_director)

    def parse_director(self, response):
        credits = []  # Khai báo biến trước khi dùng

        director_name = response.css('h2 a::text').get() or response.css('h2::text').get()
        birthday = response.xpath('//section[@class="facts"]//p[strong/bdi[text()="Birthday"]]/text()').get()
        place_of_birth = response.xpath('//section[@class="facts"]//p[strong/bdi[text()="Place of Birth"]]/text()').get()
        known_for = response.xpath('//section[@class="facts"]//p[strong/bdi[text()="Known For"]]/text()').get()
        profile_img = response.css('div.image_content img.profile::attr(src)').get()

        # Lấy danh sách phim/TV show đạo diễn đã tham gia với vai trò Director
        for credit_group in response.css('table.credit_group'):
            for row in credit_group.css('tr'):
                role_text = row.css('td.role span.role::text').get()
                if role_text and role_text.strip().lower() == 'director':
                    year = row.css('td.year::text').get()
                    link_tag = row.css('td.role a.tooltip')
                    title = link_tag.css('bdi::text').get() if link_tag else None
                    url = link_tag.css('::attr(href)').get() if link_tag else None
                    media_type = 'tv' if url and '/tv/' in url else 'movie'

                    credits.append({
                        'year': year.strip() if year else None,
                        'title': title.strip() if title else None
                    })

        yield {
            'director_name': director_name.strip() if director_name else None,
            'birthday': birthday.strip() if birthday else None,
            'place_of_birth': place_of_birth.strip() if place_of_birth else None,
            'known_for': known_for.strip() if known_for else None,
            'profile_img': profile_img,
            'credits': credits
        }
