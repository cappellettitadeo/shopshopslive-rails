require 'rubyfish'

class Category < ApplicationRecord
  has_and_belongs_to_many :products

  scope :level_1, -> {where(level: 1)}
  scope :level_2, -> {where(level: 2)}

  def self.sync_with_central_app
    categories = CentralApp::Utils::Category.list_all
    if categories.present?
      categories.each do |category|
        create_update_from_ctr_category(category)
      end
    end
  end

  def self.create_update_from_ctr_category(category)
    if category[:level] && category[:level].to_i == 1
      # 1. Create/Update Top level category
      cat = Category.where(ctr_category_id: category[:id], level: 1).first_or_create
      cat.name_en = category[:name_en].downcase
      cat.name = category[:name].downcase
      cat.save

      # 2. Create/Update Sub-categories
      if category[:sub_count] > 0
          category[:sub_categories].each do |sub|
            sub_cat = Category.where(ctr_category_id: sub[:id], level: 2).first_or_create
            sub_cat.name_en = sub[:name_en].downcase
            sub_cat.name = sub[:name].downcase
            sub_cat.parent_id = cat.id
            sub_cat.save
          end
      end
      cat
    end
  end

  # Deprecated
  def self.most_alike_by_name_en(name_en, level = 1, level_1_id = nil)
    most_alike_category = nil
    categories = []
    if level == 2 && level_1_id
      categories = Category.where(parent_id: level_1_id)
    elsif level == 1
      categories = Category.where("name_en LIKE ? AND level = 1", "%#{name_en.downcase}%")
    end
    if categories.present?
      max_dist = -1
      categories.each do |category|
        dist = RubyFish::JaroWinkler.distance(category.name_en.downcase, name_en)
        if dist > max_dist && dist > 0
          most_alike_category = category
          max_dist = dist
        end
      end
    end
    most_alike_category
  end

  # Search All Categories to find the most alike match(it could be either
  # level 1 or level 2 category)
  def self.fuzzy_match_by_name_en(name_en, gender = nil)
    case gender
    when 'men'
      lvl_1_men_cat = Category.find_by(level: 1, name_en: 'men')
      categories = Category.where(parent_id: lvl_1_men_cat.id)
    when 'women'
      lvl_1_women_cat = Category.find_by(level: 1, name_en: 'women')
      categories = Category.where(parent_id: lvl_1_women_cat.id)
    else
      categories = Category.all
    end
    fz = FuzzyMatch.new(categories, read: :name_en)
    result = fz.find(name_en)
    result
  end
end
