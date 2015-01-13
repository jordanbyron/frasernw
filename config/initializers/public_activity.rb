PublicActivity::Activity.class_eval do
  attr_accessible :update_classification_type, :type_mask, :update_classification_type, :categorization, :type_mask, :type_mask_description
  belongs_to :parent, :polymorphic => true
end