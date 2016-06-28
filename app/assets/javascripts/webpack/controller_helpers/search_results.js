import _ from "lodash";
import { memoizePerRender } from "utils";

export const searchResults = ((model) => {
  return toSearch(model).
    map((record) => decorateWithScore(record, model)).
    filter((decoratedRecord) => {
      return _.every(filters(model), (filter) => filter(decoratedRecord, model));
    }).pwPipe((decoratedRecords) => {
      return _.sortByOrder(decoratedRecords, _.property("score"), "desc")
    }).pwPipe((decoratedRecords) => _.take(decoratedRecords, 10)).
    pwPipe((decoratedRecords) => {
      return _.groupBy(decoratedRecords, _.property("raw.collectionName"));
    }).pwPipe((collections) => {
      return _.map(collections, (decoratedRecords, collectionName) => {
        if(collectionName === "contentItems"){
          return _.groupBy(decoratedRecords, _.property("raw.categoryId")).
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
}).pwPipe(memoizePerRender);

const filters = (model) => {
  let filters = []

  filters.push((decoratedRecord) => decoratedRecord.score > 0.5)

  filters.push((decoratedRecord) => {
    return !_.includes(
      ["contentItems", "contentCategories"],
      decoratedRecord.raw.collectionName
    ) || decoratedRecord.raw.searchable;
  })

  if (selectedCollectionFilter(model) === "Physician Resources"){
    filters.push((decoratedRecord) => {
      return _.intersection(
        decoratedRecord.raw.categoryIds,
        [ pearlsId(model), redFlagsId(model), physicianResourcesId(model) ]
      ).pwPipe(_.any)
    })
  }

  if (selectedCollectionFilter(model) === "Patient Info"){
    filters.push((decoratedRecord) => {
      return _.includes(
        decoratedRecord.raw.categoryIds,
        patientInfoId(model)
      )
    })
  }

  if (selectedGeographicFilter(model) === "My Regional Divisions"){
    filters.push((decoratedRecord) => {
      return !_.includes(
        ["clinics", "specialists"],
        decoratedRecord.raw.collectionName
      ) || inLocalReferralArea(decoratedRecord, model)
    })
  }
  else {
    filters.push((decoratedRecord) => {
      return !_.includes(
        ["clinics", "specialists", "contentItems", "specializationIds"],
        decoratedRecord.raw.collectionName
      ) || specializationsShownToUser(decoratedRecord.raw, model).pwPipe(_.some)
    })
  }

  filters.push((decoratedRecord) => {
    return decoratedRecord.raw.collectionName !== "specializations" ||
      specializationComplete(decoratedRecord.raw.id, model);
  })

  filters.push((decoratedRecord) => {
    return !_.includes(
      ["clinics", "specialists"],
      decoratedRecord.raw.collectionName
    ) || notInProgress(decoratedRecord, model)
  })

  return filters;
}

export const selectedSearchResult = (model) => {
  return _.get(
    model,
    ["ui", "selectedSearchResult"],
    0
  )
}

const notInProgress = (decoratedRecord, model) => {
  return decoratedRecord.
    raw.
    specializationIds.
    filter((specializationId) => {
      return _.some(decoratedRecord.raw.divisionIds, (divisionId) => {
        return model.
          app.
          specializations[specializationId].
          inProgressInDivisionIds.
          indexOf(divisionId) === -1;
      })
    }).pwPipe(_.some)
};

const specializationComplete = (specializationId, model) => {
  return _.some(model.app.currentUser.divisionIds, (divisionId) => {
    return model.
      app.
      specializations[specializationId].
      inProgressInDivisionIds.
      indexOf(divisionId) === -1;
  })
}

export const specializationsShownToUser = (record, model) => {
  return record.
    specializationIds.
    filter((specializationId) => specializationComplete(specializationId, model))
};

const inLocalReferralArea = (decoratedRecord, model) => {
  return _.some(model.app.currentUser.divisionIds, (divisionId) => {
    return _.some(
      specializationsShownToUser(decoratedRecord.raw, model),
      (specializationId) => {
        return _.intersection(
          model.app.divisions[divisionId].referralCities[specializationId],
          decoratedRecord.raw.cityIds
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
  default:
    return _.values(model.app.contentItems);
  }
}

const decorateWithScore = (record, model) => {
  return {
    score: score((model.ui.searchTerm || ""), searchString(record), 0.5),
    raw: record
  };
};

const searchString = (record) => {
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

export const link = (record) => {
  return `/${urlCollectionName(record)}/${record.id}`;
}

const urlCollectionName = (record) => {
  switch(record.collectionName){
  case "procedures":
    return "areas_of_practice"
  case "specializations":
    return "specialties";
  default:
    return _.snakeCase(record.collectionName);
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

const score = (string1, string2, fuzziness) => {
  if (string1.trim() == "" || string2.trim() == "")
  {
    return 0.0;
  }

  var arr1 = string1.trim().toLowerCase().split(' ');
  var arr2 = string2.trim().toLowerCase().split(' ');

  var best_match = new Array(arr1.length);

  for(var x = 0; x < arr1.length; ++x)
  {
    best_match[x] = 0;
    var piece1 = arr1[x];
    var piece1_length = piece1.length;

    for (var y = 0; y < arr2.length; ++y )
    {
      var piece2 = arr2[y]

      // perfect match?
      if (piece1 == piece2)
      {
        best_match[x] = 1.0;
        break;
      }

      var total_character_score = 0;
      var piece2_length = piece2.length;
      var max_length = Math.max(piece1_length, piece2_length);
      var start_of_word_matches = 0;
      var num_matches = 0;
      var fuzzies = 1;
      var piece_score;

      var piece1_index = 0;
      var bonuses = 0;

      while (piece1_index < piece1_length)
      {
        // Find the longest match remaining.
        var found = false;
        var piece2_index = -1;

        for (var match_length = 1; match_length <= piece1_length - piece1_index; ++match_length)
        {
          var cur_index = piece2.indexOf( piece1.substr(piece1_index, match_length) );

          if (cur_index != -1)
          {
            found = true;
            piece2_index = cur_index;
          }
          else
          {
            match_length -= 1;
            break;
          }
        }

        if (!found)
        {
          fuzzies += 1-fuzziness;
          ++piece1_index;
          continue;
        }

        ++num_matches;

        var match_score = match_length / max_length;

        if (piece2_index == 0)
        {
          //matching the start of a search term
          ++start_of_word_matches;
        }

        //bonuses!
        if ((match_length >= 2) && (piece1_index == 0) && (piece2_index == 0))
        {
          //matching the start of a search term to the start of a term
          bonuses += 0.1;

          if ((x == 0) && (y == 0))
          {
            //matched the start of our search to the start of the result
            bonuses += 0.2;
          }
        }

        // Left trim the already matched part of the string (forces sequential matching).
        piece1_index += match_length;
        piece2 = piece2.substring(piece2_index + match_length, piece2_length);

        total_character_score += match_score;
      }

      if (num_matches == 0)
      {
        continue;
      }

      //penalize each match that isn't a start of string
      piece_score = total_character_score - ((num_matches-start_of_word_matches) * 0.1);

      //take into account errors and bonuses
      piece_score = (piece_score / fuzzies) + bonuses;

      best_match[x] = Math.max(piece_score, best_match[x]);
    }
  }

  var overall_score = 0;
  for ( var x = 0; x < best_match.length; ++x )
  {
    overall_score += best_match[x];
  }
  overall_score /= best_match.length;

  return overall_score;
};
