export const link = (record) => {
  return `/${urlCollectionName(record)}/${record.id}`;
}

export const urlCollectionName = (record) => {
  switch(record.collectionName){
  case "procedures":
    return "areas_of_practice"
  case "specializations":
    return "specialties";
  default:
    return _.snakeCase(record.collectionName);
  }
}
