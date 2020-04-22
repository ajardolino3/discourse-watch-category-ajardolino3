# name: discourse-watch-category-ajardolino3
# about: Forked and customized for Acumatica Partner Hub
# version: 0.1
# authors: Arthur Ardolino
# url: https://github.com/ajardolino3/discourse-watch-category-ajardolino3

module ::WatchCategory
  def self.watch_by_group(category_slug, group_name)
    category = Category.find_by(slug: category_slug)
    group = Group.find_by_name(group_name)
    return if category.nil? || group.nil?

    group.users.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], category.id) unless watched_categories.include?(category.id) || user.staged
    end
  end

  def self.get_categories_recursive(category)
    categories = [category]
    subcategories = Category.where("categories.parent_category_id = ?", category.id)
    
    subcategories.each do |subcategory|
      categories += get_categories_recursive(subcategory)
    end
    
    return categories
  end
  
  def self.mute_recursive_by_group(category_slug, group_name)
    category = Category.find_by(slug: category_slug)
    categories = self.get_categories_recursive(category)
    group = Group.find_by_name(group_name)
    return if category.nil? || group.nil?

    categories.each do |subcategory|
      group.users.each do |user|
        muted_categories = CategoryUser.lookup(user, :muted).pluck(:category_id)
        CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:muted], subcategory.id) unless muted_categories.include?(subcategory.id) || user.staged
      end
    end
  end
  
  def self.watch_all(category_slug)
    category = Category.find_by(slug: category_slug)
    User.all.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], category.id) unless watched_categories.include?(category.id)  || user.staged
    end 
  end
  
  def self.mute_all(category_slug)
    category = Category.find_by(slug: category_slug)
    User.all.each do |user|
      muted_categories = CategoryUser.lookup(user, :muted).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:muted], category.id) unless muted_categories.include?(category.id)  || user.staged
    end 
  end

  def self.watch_category!
    #WatchCategory.mute_all("jungmedizinerforum-kalender-unbeantwortet")
    #WatchCategory.mute_recursive_by_group("deutsch", "english-only")
    WatchCategory.watch_all("acumatica-direct")
    #WatchCategory.watch_by_group("Case-Study-Discussion-Group","case-study-group")
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        WatchCategory.watch_category!
      end
    end
  end
end
