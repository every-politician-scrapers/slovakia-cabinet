#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//h3[.//span[contains(.,'Primátori')]]//following-sibling::ul[1]//li")
  end

  class Officeholder < OfficeholderNonTableBase
    def name_node
      noko.css('a').reject { |link| link.text.to_s =~ /CSc|LL.M/ }.last
    end

    def raw_combo_date
      years = noko.text.split('–').reverse.drop(1).reverse.map(&:tidy).join("-")
      years =~ /^\d{4}$/ ? "#{years} - #{years}" : years
    end

    def empty?
      (noko.text !~ /2/) || too_early?
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
