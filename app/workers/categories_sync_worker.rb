class CategoriesSyncWorker
  include Sidekiq::Worker

  sidekiq_options unique: true

  def perform
    category = CentralApp::Utils::Category.list_all
    if category[:level] && category[:level].to_i == 1
      # 1. Create/Update Top level category
      cat = Category.where(name: category[:name].downcase, level: 1).first_or_create
      cat.ctr_category_id = category[:id]
      cat.save

      # 2. Create/Update Sub-categories
      category[:sub_categories].each do |sub|
        sub_cat = Category.where(name: sub[:name].downcase, level: 2).first_or_create
        sub_cat.ctr_category_id = sub[:id]
        sub_cat.parent_id = cat.id
        sub_cat.save
      end
    end
  end
end
