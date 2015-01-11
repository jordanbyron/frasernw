PublicActivity::Activity.class_eval do
  attr_accessible :update_classification_type
  belongs_to :parent, :polymorphic => true
end