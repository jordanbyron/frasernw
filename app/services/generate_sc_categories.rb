class GenerateScCategories
  attr_reader :user_divisions, :categories_with_resources

  def self.exec(user_divisions)
    new(user_divisions).exec
  end

  def initialize(user_divisions)
    @user_divisions = user_divisions
    @categories_with_resources =
      ScCategory.with_items_for_divisions(user_divisions)
  end

  def exec
    process_hsh(ScCategory.arrange).
      select(&:show_in_global_resources_dropdown?)
  end

  def process_hsh(hsh, ancestors = Set.new)
    hsh.inject(Set.new) do |memo, (category, children)|
      memo | process_category(
        category,
        children,
        ancestors
      )
    end
  end

  def process_category(category, children, ancestors)
    # if this division has resources, we add it and all of its parents
    to_add = begin
      if categories_with_resources.include? category
        ancestors | [ category ]
      else
        Set.new
      end
    end

    # pass the parents and this category to children to do the same thing..
    to_add + process_hsh(
      children,
      ( ancestors | [ category ])
    )
  end
end
