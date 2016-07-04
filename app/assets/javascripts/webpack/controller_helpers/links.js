export const link = (record) => {
  return `/${urlCollectionName(record)}/${id(record)}`;
}

export const urlCollectionName = (record) => {
  switch(record.collectionName){
  case "procedures":
    return "areas_of_practice"
  case "specializations":
    return "specialties";
  case "issues":
    if (useChangeRequestLink(record)){
      return "change_requests"
    }
    else {
      return "issues"
    }
  default:
    return _.snakeCase(record.collectionName);
  }
}

export const id = (record) => {
  switch(record.collectionName){
  case "issues":
    if (useChangeRequestLink(record)){
      return record.sourceId;
    }
    else {
      return record.id
    }
  default:
    return record.id;
  }
}

const useChangeRequestLink = (issue) => {
  return issue.sourceKey === 1 && issue.sourceId && issue.sourceId !== "";
}
