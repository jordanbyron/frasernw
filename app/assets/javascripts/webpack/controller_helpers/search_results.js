import _ from "lodash";
import { memoizePerRender, memoize } from "utils";
import hiddenFromUsers from "controller_helpers/hidden_from_users";
import stringScore from "utils/string_score";
import { urlCollectionName } from "controller_helpers/links";
import { matchesUserDivisions } from "controller_helpers/preliminary_filters";
import Fuse from "fuse.js";

export const selectedCollectionFilter = (model) => {
  return _.get(
    model,
    ["ui", "searchCollectionFilter"],
    "Everything"
  )
}

export const selectedGeographicFilter = (model) => {
  return _.get(
    model,
    ["ui", "searchGeographicFilter"],
    "My Regional Divisions"
  )
}

export const entryLabel = (record) => {
  if (record.collectionName === "specialists" && record.billingNumber){
    return `${record.name} - MSP #${record.billingNumber}`;
  }
  else if (_.includes(["procedures", "contentCategories"], record.collectionName)){
    return record.fullName;
  }
  else if (record.collectionName === "contentItems"){
    return record.title;
  }
  else {
    return record.name;
  }
}

const fuseOptions = {
  include: [ "score", "matches"],
  keys: ["entryLabel"],
  getFn: entryLabel,
  tokenize: true,
  threshold: 0.2,
  distance: 10
}

export const searchResults = ((model) => {
  if(!model.app.currentUser){
    return [];
  }

  return toSearch(model).
    pwPipe((records) => {
      let fuse = new Fuse(records, fuseOptions)

      return fuse.search((model.ui.searchTerm || ""))
    }).
    filter((decoratedRecord) => {
      return _.every(filters(model), (filter) => filter(decoratedRecord, model));
    }).pwPipe((decoratedRecords) => {
      return _.sortByOrder(decoratedRecords, _.property("score"), "desc")
    }).pwPipe((decoratedRecords) => _.take(decoratedRecords, 10)).
    pwPipe((decoratedRecords) => {
      return _.groupBy(decoratedRecords, _.property("item.collectionName"));
    }).pwPipe((collections) => {
      return _.map(collections, (decoratedRecords, collectionName) => {
        if(collectionName === "contentItems"){
          return _.groupBy(decoratedRecords, _.property("item.categoryId")).
            pwPipe((categories) => {
              return _.map(categories, (decoratedRecords, id) => {
                return {
                  label: model.app.contentCategories[id].fullName,
                  decoratedRecords: decoratedRecords.
                    pwPipe((records) => {
                      return _.sortByOrder(records, _.property("score"), "desc");
                    }),
                  order: groupOrder["contentItems"]
                };
              })
            });
        }
        else {
          return {
            label: groupLabels[collectionName],
            decoratedRecords: decoratedRecords.
              pwPipe((records) => _.sortByOrder(records, _.property("score"), "desc")),
            order: groupOrder[collectionName]
          }
        }
      });
    }).pwPipe(_.flatten).
    pwPipe((groups) => {
      return _.sortByOrder(groups, _.property("order"), "asc");
    }).pwPipe((groups) => {
      let index = 0;

      groups.forEach((group) => {
        group.decoratedRecords.forEach((decoratedRecord) => {
          decoratedRecord.index = index;
          index++
          return decoratedRecord;
        })
      })

      return groups;
    });
}).pwPipe((generate) => {
  return memoize(
    (model) => model.app,
    (model) => model.ui.searchTerm,
    selectedCollectionFilter,
    selectedGeographicFilter,
    generate
  );
});

const filters = ((model) => {
  let filters = []

  filters.push((decoratedRecord) => {
    return decoratedRecord.item.collectionName !== "contentItems" ||
      (_.includes(["super", "admin"], model.app.currentUser.role) &&
        selectedGeographicFilter(model) === "All Divisions") ||
      matchesUserDivisions(decoratedRecord.item, model)
  })

  filters.push((decoratedRecord) => {
    return !_.includes(
      ["contentItems", "contentCategories"],
      decoratedRecord.item.collectionName
    ) || decoratedRecord.item.searchable;
  })

  if (selectedCollectionFilter(model) === "Physician Resources"){
    filters.push((decoratedRecord) => {
      return _.intersection(
        decoratedRecord.item.categoryIds,
        [ pearlsId(model), redFlagsId(model), physicianResourcesId(model) ]
      ).pwPipe(_.any)
    })
  }

  if (selectedCollectionFilter(model) === "Patient Info"){
    filters.push((decoratedRecord) => {
      return _.includes(
        decoratedRecord.item.categoryIds,
        patientInfoId(model)
      )
    })
  }

  if (selectedGeographicFilter(model) === "My Regional Divisions"){
    filters.push((decoratedRecord) => {
      return !_.includes(
        ["clinics", "specialists"],
        decoratedRecord.item.collectionName
      ) || shownInLocalReferralArea(decoratedRecord, model)
    })
  }

  if (model.app.currentUser.role === "user"){
    filters.push((decoratedRecord) => {
      return !hiddenFromUsers(decoratedRecord.item, model)
    })
  }

  return filters;
}).pwPipe(memoizePerRender);

export const selectedSearchResult = (model) => {
  return _.get(
    model,
    ["ui", "selectedSearchResult"],
    0
  )
}

export const highlightSelectedSearchResult = (model) => {
  return _.get(
    model,
    ["ui", "highlightSelectedSearchResult"],
    true
  );
}

const shownInLocalReferralArea = (decoratedRecord, model) => {
  return _.some(model.app.currentUser.divisionIds, (divisionId) => {
    return _.some(
      decoratedRecord.item.specializationIds,
      (specializationId) => {
        return !_.includes(
          model.app.specializations[specializationId].hiddenInDivisionIds,
          divisionId
        ) && _.intersection(
          model.app.divisions[divisionId].referralCities[specializationId],
          decoratedRecord.item.cityIds
        ).pwPipe(_.any)
      }
    )
  });
};

const categoryId = (categoryName, model) => {
  return model.
    app.
    contentCategories.
    pwPipe(_.values).
    pwPipe((categories) => {
      return _.find(categories, (category) => category.name === categoryName)
    }).id
}

const pearlsId = _.partial(categoryId, "Pearls").
  pwPipe(memoizePerRender)
const redFlagsId = _.partial(categoryId, "Red Flags").
  pwPipe(memoizePerRender)
const physicianResourcesId = _.partial(categoryId, "Physician Resources").
  pwPipe(memoizePerRender)
const patientInfoId = _.partial(categoryId, "Patient Info").
  pwPipe(memoizePerRender)

const groupOrder = {
  specializations: 1,
  specialists: 2,
  clinics: 3,
  contentCategories: 4,
  procedures: 5,
  hospitals: 6,
  languages: 7,
  contentItems: 8
}

const groupLabels = {
  specializations: "Specialties",
  specialists: "Specialists",
  clinics: "Clinics",
  procedures: "Areas of Practice",
  hospitals: "Hospitals",
  languages: "Languages",
  contentCategories: "Content"
}

const toSearch = (model) => {
  switch(selectedCollectionFilter(model)){
  case "Everything":
    return [
      model.app.specialists,
      model.app.clinics,
      model.app.procedures,
      model.app.specializations,
      model.app.hospitals,
      model.app.languages,
      model.app.contentItems,
      model.app.contentCategories
    ].map(_.values).pwPipe(_.flatten);
  case "Specialists":
    return _.values(model.app.specialists);
  case "Clinics":
    return _.values(model.app.clinics);
  case "Areas of Practice":
    return _.values(model.app.procedures);
  default:
    return _.values(model.app.contentItems);
  }
}

export const recordAnalytics = (record, model) => {
  _gaq.push([
    "_trackEvent",
    "search_result",
    urlCollectionName(record),
    record.id
  ]);

  _gaq.push([
    "_trackEvent",
    "search_term",
    (model.ui.searchTerm || ""),
  ]);

  _gaq.push([
    "_trackEvent",
    "search_user",
    model.app.currentUser.adjustedTypeMask,
    model.app.currentUser.id
  ]);

  return true;
}
