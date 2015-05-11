class PathwaysSweeper < ActionController::Caching::Sweeper

  def after_create(entity)
  end

  def before_controller_update(entity)
    expire_self(entity)
  end

  def before_update(entity)
  end

  def before_controller_destroy(entity)
    expire_self(entity)
  end

end