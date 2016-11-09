export const navTabKey = (type, id) => {
  if (id) {
    return (type + id);
  } else {
    return type;
  }
};

export const navTabKeyId = (navTabKey) => {
  if (navTabKey.match(/\d+/)){
    return parseInt(navTabKey.match(/\d+/));
  }
  else {
    return null
  }
}

export const navTabKeyType = (navTabKey) => {
  navTabKey.match(/[A-Za-z]+/);
}

export const recordShownByTabKey = (navTabKey) => {
  if(navTabKeyId(navTabKey)){
    return model.app[pluralize(navTabKeyType(navTabKey))][navTabKeyId(navTabKey)];
  }
  else {
    return {};
  }
}

const pluralize = (tabType) => {
  return PLURALIZATIONS[tabType]
}

const PLURALIZATIONS = {
  contentCategory: "contentCategories"
}
