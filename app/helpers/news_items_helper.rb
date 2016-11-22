module NewsItemsHelper
  def render_news_item(news_item)
    case news_item.type_mask
    when NewsItem::TYPE_DIVISIONAL
      content_tag(:div, class: "news_item") do
        content_tag(:div, news_item.date, class: "news_item_date") +
        content_tag(:div, news_item.title, class: FrontHelper.news_item_class(news_item)) +
        content_tag(:div, BlueCloth.new(news_item.body).to_html.html_safe, class: "news_item_body")
      end
    end
  end
end
