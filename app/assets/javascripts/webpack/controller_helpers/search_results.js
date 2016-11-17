import _ from "lodash";
import { memoizePerRender, memoize } from "utils";
import hiddenFromUsers from "controller_helpers/hidden_from_users";
import { urlCollectionName } from "controller_helpers/links";
import { matchesUserDivisions } from "controller_helpers/preliminary_filters";
import scoreString from "utils/score_string";
import { link } from "controller_helpers/links";
import { encode as encodeUrlHash } from "utils/url_hash_encoding";
import BitapSearcher from "utils/bitap_searcher";
import contentCategoryHierarchy from "controller_helpers/content_categories";

const BitapOptions = {
  threshold: 0.3,
  distance: 5,
  maxPatternLength: 20
};

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

const memoizeSearchFn = (fn) => {
  return memoize(
    (model) => model.app,
    (model) => model.ui.searchTerm,
    selectedCollectionFilter,
    selectedGeographicFilter,
    fn
  );
}

export const searchResults = ((model) => {
  if(!model.app.currentUser || !model.ui.searchTerm || model.ui.searchTerm.length < 3){
    return [];
  }

  return toSearch(model).
    filter((record) => {
      return _.every(filters(model), (filter) => filter(record, model));
    }).
    pwPipe((records) => {
      return records.map((record) => {
        const _entryLabel = entryLabel(record);
        const _queryTokens = model.ui.searchTerm.split(/\s+/g);
        const _queryTokensSearchers = _queryTokens.map((token) => {
          return new BitapSearcher(token, BitapOptions)
        })

        return _.assign(
          {
            raw: record,
            entryLabel: _entryLabel
          },
          scoreString(_queryTokensSearchers, _entryLabel)
        )
      })
    }).
    filter((decoratedRecord) => decoratedRecord.queryScore > 0 ).
    pwPipe((decoratedRecords) => {
      return _.sortByOrder(
        decoratedRecords,
        [
          _.property("queryScore"),
          (decoratedRecord) => groupOrder[decoratedRecord.raw.collectionName],
          _.property("queriedScore")
        ],
        ["desc", "asc", "desc"]
      );
    })
}).pwPipe(memoizeSearchFn)

export const groupedSearchResults = ((model) => {
  return searchResults(model).
    pwPipe((decoratedRecords) => {
      return _.groupBy(decoratedRecords, _.property("raw.collectionName"));
    }).pwPipe((collections) => {
      return _.map(collections, (decoratedRecords, collectionName) => {
        if(collectionName === "contentItems"){
          return _.groupBy(decoratedRecords, _.property("raw.categoryId")).
            pwPipe((categories) => {
              return _.map(categories, (decoratedRecords, id) => {
                const _scores = decoratedRecords.map(_.property("queryScore"));

                return {
                  label: model.app.contentCategories[id].fullName,
                  decoratedRecords: decoratedRecords.
                    pwPipe((records) => {
                      return _.sortByOrder(records, _.property("queryScore"), "desc");
                    }),
                  groupOrder: groupOrder["contentItems"],
                  maxScore: _.max(_scores),
                  meanScore: _scores / _scores.length
                };
              })
            });
        }
        else {
          const _scores = decoratedRecords.map(_.property("queryScore"));

          return {
            label: labelGroup(model, collectionName),
            decoratedRecords: decoratedRecords.
              pwPipe((records) => _.sortByOrder(records, _.property("queryScore"), "desc")),
            groupOrder: groupOrder[collectionName],
            maxScore: _.max(_scores),
            meanScore: _scores / _scores.length
          }
        }
      });
    }).pwPipe(_.flatten).
    pwPipe((groups) => {
      return _.sortByOrder(
        groups,
        [_.property("maxScore"), _.property("meanScore"), _.property("groupOrder")],
        ["desc", "desc", "asc"]
      );
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
}).pwPipe(memoizeSearchFn);

const labelGroup = (model, collectionName) => {
  switch(collectionName){
  case "specializations":
    return "Specialties";
  case "contentCategories":
    return "Content";
  case "procedures":
    if (_.includes(["Specialists", "Clinics"], selectedCollectionFilter(model))){
      return `${selectedCollectionFilter(model)} accepting referrals for:`;
    }
    else {
      return "Areas of Practice";
    }
  default:
    return _.capitalize(collectionName);
  }
}

const filters = ((model) => {
  let filters = []

  filters.push((record) => {
    return record.collectionName !== "contentItems" ||
      (_.includes(["super", "admin"], model.app.currentUser.role) &&
        selectedGeographicFilter(model) === "All Divisions") ||
      matchesUserDivisions(record, model)
  })

  filters.push((record) => {
    return !_.includes(
      ["contentItems", "contentCategories"],
      record.collectionName
    ) || record.searchable;
  })

  if (selectedCollectionFilter(model) === "Physician Resources"){
    filters.push((record) => {
      return _.intersection(
        contentCategoryHierarchy(model, record),
        [ pearlsId(model), redFlagsId(model), physicianResourcesId(model) ]
      ).pwPipe(_.any)
    })
  }

  if (selectedCollectionFilter(model) === "Patient Info"){
    filters.push((record) => {
      return _.includes(
        contentCategoryHierarchy(model, record),
        patientInfoId(model)
      )
    })
  }

  if (selectedGeographicFilter(model) === "My Regional Divisions"){
    filters.push((record) => {
      return !_.includes(
        ["clinics", "specialists"],
        record.collectionName
      ) || shownInLocalReferralArea(record, model)
    })
  }

  if (model.app.currentUser.role === "user"){
    filters.push((record) => {
      return !hiddenFromUsers(record, model)
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

const shownInLocalReferralArea = (record, model) => {
  return _.some(model.app.currentUser.divisionIds, (divisionId) => {
    return _.some(
      record.specializationIds,
      (specializationId) => {
        return !_.includes(
          model.app.specializations[specializationId].hiddenInDivisionIds,
          divisionId
        ) && _.intersection(
          model.app.divisions[divisionId].referralCities[specializationId],
          record.cityIds
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
    return _.values(model.app.specialists).concat(..._.values(model.app.procedures));
  case "Clinics":
    return _.values(model.app.clinics).concat(..._.values(model.app.procedures));
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

export const adjustedLink = (model, record) => {
  if (record.collectionName === "procedures" &&
    _.includes(["Specialists", "Clinics"], selectedCollectionFilter(model))){

    return (link(record) +
      "#" +
      encodeUrlHash({selectedTabKey: selectedCollectionFilter(model).toLowerCase()}));
  }
  else {
    return link(record);
  }
}
