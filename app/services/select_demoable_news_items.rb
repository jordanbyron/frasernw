class SelectDemoableNewsItems < ServiceObject

  def call
    NewsItem.
      unscoped.
      not_demoable.
      order("news_items.created_at DESC").
      select([:title, :body, :type_mask, "news_items.id"]).
      each do |item|
        puts "---"

        ap NewsItem.
          demoable.
          count_by{ |item| item.type_mask }.
          map{ |k, v| [ NewsItem::TYPE_HASH[k], v ] }.
          to_h

        puts "---"

        ap item.attributes

        puts "---"
        print "Add item?: "

        resp = gets.chomp

        if resp == "y"
          item.demoable!
        elsif resp == "n"
          next
        else
          break
        end
      end
  end
end
