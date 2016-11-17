const contentCategoryHierarchy = (model, contentItem) => {
  return _.compact([
    model.app.contentCategories[item.categoryId].ancestry,
    item.categoryId
  ]);
}
