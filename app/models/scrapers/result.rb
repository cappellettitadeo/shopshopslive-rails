require 'hash_traverser/dfs_traverser'

class Scrapers::Result

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :keywords
  validates_presence_of :material
  validates_presence_of :available

  validates_presence_of :store_id
  validates_presence_of :vendor_id
  validates_presence_of :source_id
  validates_presence_of :scraper_id

  def initialize
  end

  def persisted?
    false
  end

  def scraped
    true
  end

  def should_create?
    true
  end

  def save_if_rejected?
    false
  end

  protected
end
