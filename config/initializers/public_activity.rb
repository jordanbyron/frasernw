PublicActivity::Activity.class_eval do
  attr_accessible :update_classification_type, :type_mask, :type_mask_description, :parent_id, :parent_type, :recipient_id, :recipient_type
  belongs_to :parent, :polymorphic => true
end