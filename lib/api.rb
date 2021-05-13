class Api

  require 'json'
  require 'rest-client'

  def self.base_url
    "https://mlb21.theshow.com/apis"
  end

  def run
      base_url = @base_url
      response = RestClient.get(base_url + '/items.json')
      body = JSON.parse(response.body, symbolize_names: true)

      total_pages = body[:total_pages]
      @item_ids = []

      total_pages.times { |i|
        resp = RestClient.get(base_url + "/items.json?page=#{i}")
        puts "getting page #{i}"
        bod = JSON.parse(resp.body, symbolize_names: true)

        bod[:items].each do |item|
          if item[:rarity] == "Diamond" or item[:rarity] == "Gold"
            @item_ids << item[:uuid]
            puts "added #{item[:type]} with a rarity of #{item[:rarity]}"
          end
        end
      }

      response = RestClient.get(base_url + '/items?type=equipment.json')
      body = JSON.parse(response.body, symbolize_names: true)

      stuff_total_pages = body[:total_pages]

      stuff_total_pages.times { |i|
        resp = RestClient.get(base_url + "/items.json?type=equipment&page=#{i}")
        puts "getting page #{i}"
        bod = JSON.parse(resp.body, symbolize_names: true)

        bod[:items].each do |item|
          if item[:rarity] == "Diamond" or item[:rarity] == "Gold"
            @item_ids << item[:uuid]
            puts "added #{item[:type]} with a rarity of #{item[:rarity]}"
          end
        end
      }

    cards = []
    puts "checking #{@item_ids.uniq.size} good cards for profit margins"
    @item_ids.uniq.each do |id|
      response = RestClient.get(base_url + "/listing.json?uuid=#{id}")
      body = JSON.parse(response.body, symbolize_names: true)

      tax = (body[:best_sell_price] * 0.10).round
      delta = (body[:best_sell_price] - body[:best_buy_price])
      profit = delta - tax > 0 ? delta - tax : 1
      buy = body[:best_buy_price] > 0 ? body[:best_buy_price] : 1
      card = {
          name: body[:listing_name],
          sell_price: body[:best_sell_price],
          buy_price: buy,
          tax: tax,
          delta: delta,
          profit: profit,
          prof_percent: ((profit.to_f / buy.to_f) * 100).round
      }

      if card[:profit] > 1000 && buy > 1
        cards << card
        puts "added #{card[:name]} with a profit of #{card[:profit]}"
      end
    end

    sorted_cards = cards.sort { |a,b| b[:profit] <=> a[:profit] }

    sorted_cards.each do |card|
      puts "#{card[:name]} -- PROFIT: #{card[:profit]} -- PERCENT: #{card[:prof_percent]} -- BUY: #{card[:buy_price]} -- SELL: #{card[:sell_price]}"
      puts "----------------------------------------------------------------------------------------------------"
    end

    return

  end

end
