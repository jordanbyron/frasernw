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
  let _referentsForSpecialization =
    referentsForSpecialization(model, specialization)

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
          `(${_referentsForSpecialization.length} total)`
        }
      </div>
      <div>
        <table className="table">
          <tbody>
            {
              _referentsForSpecialization.map((referent) => {
                return(
                  <tr
                    className="referents_by_specialty__row"
                    key={`${referent.collectionName}${referent.id}`}
                  >
                    <td>
                      <a href={`/${referent.collectionName}/${referent.id}`}>
                        {referent.name}
                      </a>
                      <div
                        style={{float: "right"}}
                        className="referents_by_specialty__faded_content"
                      >
                        {
                          `Added: ${referent.createdAt}, ` +
                          `Last Updated: ${referent.updatedAt}`
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

const referentsForSpecialization = (model, specialization) => {
  return recordsToDisplay(model).filter((record) => {
    return _.includes(record.specializationIds, specialization.id);
  }).pwPipe((referents) => {
    return _.sortBy(referents, (referent) => {
      if(referent.collectionName === "specialists"){
        return referent.lastName;
      }
      else {
        return referent.name;
      }
    })
  });
};

const shouldDisplay = (model) => {
  return route === "/reports/referents_by_specialty" &&
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
