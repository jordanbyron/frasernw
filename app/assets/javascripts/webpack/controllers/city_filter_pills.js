import React from "react";
import { showCityFilterPills, withoutCityFilters }
  from "controller_helpers/filter_messages";
import { buttonIsh } from "stylesets";
import { changeFilterToValue } from "action_creators";
import * as filterValues from "controller_helpers/filter_values";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const CityFilterPills = ({model, dispatch}) => {
  if (showCityFilterPills(model)) {
    return(
      <div>
        <p style={{marginLeft: "0px", fontWeight: "bold"}}>
          You can also expand your search by selecting more cities:
        </p>
        <div style={{marginTop: "10px", marginBottom: "10px"}}>
          {
            _.map(otherCitiesCounts(model), (count, cityId) => {
              return (
                <div key={cityId}
                  onClick={
                    _.partial(
                      changeFilterToValue,
                      dispatch,
                      selectedTabKey(model),
                      "cities",
                      cityId,
                      true
                    )
                  }
                  style={buttonIsh}
                  className="specialization_table__city_filter_pill"
                >
                  {model.app.cities[cityId].name + " (" + count + ")"}
                </div>
              );
            })
          }
        </div>
      </div>
    );
  } else {
    return <noscript/>;
  }
}

const otherCitiesCounts = (model) => {
  return withoutCityFilters(model).
    map(_.property("cityIds")).
    pwPipe(_.flatten).
    pwPipe(_.countBy).
    pwPipe((counts) => {
      return _.pick(counts, (count, id) => !filterValues.cities(model, id))
    });
};

export default CityFilterPills;
