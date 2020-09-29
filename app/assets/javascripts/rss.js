$(document).ready(function() {

const RSS_URL = `https://cors-anywhere.herokuapp.com/https://www.atla.com/topic/atla-digital-library/feed/`;

$.ajax(RSS_URL, {
  accepts: {
    xml: "application/rss+xml"
  },

  dataType: "xml",

  success: function(data) {
    $(data)
      .find("item").each(function() {
        const el = $(this);

        const template = `
          <article>
        	<h4>
              <a href="${el.find("link").text()}" rel="noopener">
                ${el.find("title").text()}
              </a>
            </h4>
            <p class="rss-item-date">${el.find("pubDate").text()}</p>
            ${el.find("description").text()}
          </article>
        `;

        var rss = document.getElementById('rss');
        rss.insertAdjacentHTML("beforeend", template);
      });
  }
});
});
