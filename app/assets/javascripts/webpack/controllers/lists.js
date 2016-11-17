import React from "react";
import { route } from "controller_helpers/routing";
import * as filterValues from "controller_helpers/filter_values";
import recordsToDisplay from "controller_helpers/records_to_display";
import _ from "lodash";

const Lists = ({model, dispatch}) => {
  if(shouldDisplay(model)){
    return (
      <div className="lists">
        {
          specializationsShowing(model).map((specialization) => {
            return(
              <List
                specialization={specialization}
                model={model}
                key={specialization.id}
              />
            )
          })
        }
      </div>
    )
  }
  else {
    return <noscript/>
  }
};

const List = ({specialization, model}) => {
  let _profilesForSpecialization =
    profilesForSpecialization(model, specialization)

  return(
    <div style={{marginBottom: "10px"}}>
      <div style={{
        fontWeight: "bold",
        fontFamily: "Bitter",
        fontSize: "14px",
        marginBottom: "5px"
      }}
        key="title"
      >
        {
          `${specialization.name} ` +
          `(${_profilesForSpecialization.length} total)`
        }
      </div>
      <div>
        <table className="table">
          <tbody>
            {
              _profilesForSpecialization.map((profile) => {
                return(
                  <tr
                    className="profiles_by_specialty__row"
                    key={`${profile.collectionName}${profile.id}`}
                  >
                    <td>
                      <a href={`/${profile.collectionName}/${profile.id}`}>
                        {profile.name}
                      </a>
                      <div
                        style={{float: "right"}}
                        className="profiles_by_specialty__faded_content"
                      >
                        {
                          `Added: ${profile.createdAt}, ` +
                          `Last Updated: ${profile.updatedAt}`
                        }
                      </div>
                    </td>
                  </tr>
                );
              })
            }
          </tbody>
        </table>
      </div>
    </div>
  );
}

const profilesForSpecialization = (model, specialization) => {
  return recordsToDisplay(model).filter((record) => {
    return _.includes(record.specializationIds, specialization.id);
  }).pwPipe((profiles) => {
    return _.sortBy(profiles, (profile) => {
      if(profile.collectionName === "specialists"){
        return profile.lastName;
      }
      else {
        return profile.name;
      }
    })
  });
};

const shouldDisplay = (model) => {
  return route === "/reports/profiles_by_specialty" &&
    filterValues.reportStyle(model) === "expanded"
}

const specializationsShowing = (model) => {
  return recordsToDisplay(model).
    map(_.property("specializationIds")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    map((id) => model.app.specializations[id]).
    pwPipe((specializations) => _.sortBy(specializations, _.property("name")));
}

export default Lists;
