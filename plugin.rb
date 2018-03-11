# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 1.0
# authors: Jared Needell

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

  def self.watch_all(category_slug)
    category = Category.find_by(slug: category_slug)
    User.all.each do |user|
      watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
      CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], category.id) unless watched_categories.include?(category.id)  || user.staged
    end 
  end
  
  def self.watch_category!
    WatchCategory.mute_all("jungmedizinerforum-kalender-unbeantwortet")
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
