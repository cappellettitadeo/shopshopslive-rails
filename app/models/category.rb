class Category < ApplicationRecord
  has_and_belongs_to_many :products

  scope :level_1, -> { where(level: 1) }
  scope :level_2, -> { where(level: 2) }

  def sync_with_central_app
    categories = CentralApp::Utils::Category.list_all
    categories.each do |category|
      if category[:level] && category[:level].to_i == 1
        # 1. Create/Update Top level category
        cat = Category.where(ctr_category_id: category[:id], level: 1).first_or_create
        cat.name_en = category[:name_en].downcase
        cat.name = category[:name].downcase
        cat.save

        # 2. Create/Update Sub-categories
        category[:sub_categories].each do |sub|
          sub_cat = Category.where(ctr_category_id: sub[:id], level: 2).first_or_create
          sub_cat.name_en = sub[:name_en].downcase
          sub_cat.name = sub[:name].downcase
          sub_cat.parent_id = cat.id
          sub_cat.save
        end
      end
    end
  end
end
