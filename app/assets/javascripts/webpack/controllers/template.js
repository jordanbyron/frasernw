import React from "react";
import TableController from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { padTwo } from "utils";

const AbbreviatedMonths = {
  1: "Jan",
  2: "Feb",
  3: "March",
  4: "April",
  5: "May",
  6: "June",
  7: "July",
  8: "Aug",
  9: "Sept",
  10: "Oct",
  11: "Nov",
  12: "Dec"
}

const labelMonthOption = (monthKey) => {
  const month = AbbreviatedMonths[(parseInt(monthKey.slice(4, 6)))];
  const year = monthKey.slice(0, 4);

  return `${month} ${year}`;
}

const monthOptions = () => {
  return _.reduce(
    _.range(2014, ((new Date).getUTCFullYear() + 1)),
    (accumulator, year) => {
      if (year === (new Date).getUTCFullYear()) {
        return accumulator.concat(
          _.range(
            1,
            ((new Date).getMonth() + 2)
          ).map((monthNumber) => `${year}${padTwo(monthNumber)}`)
        );
      }
      else {
        return accumulator.concat(
          _.range(1, 13).map((monthNumber) => `${year}${padTwo(monthNumber)}`)
        );
      }
    },
    []
  ).reverse();
};

const TemplateController = ({model, dispatch}) => {
  return(
    <div className="content-wrapper">
      <div className="content">
        <div className="row">
          <div className="span8half">
            <h2 style={{marginBottom: "10px"}}>
              { "Page Views by User" }
            </h2>
            <TableController model={model} dispatch={dispatch}/>
          </div>
          <div className="span3 offsethalf datatable-sidebar hide-when-reduced">
            <div className="well filter">
              <div className="title">{ "Configure Report" }</div>
              <div>
                <div className="filter_group__title">Date Range</div>
                <div className="filter_group__filters">
                  <label>
                    <div>Start Month:</div>
                    <select
                      value={FilterValues.startMonth(model)}
                      onChange={function(e) { changeFilterValue(dispatch, "startMonth", e.target.value) } }
                    >
                      {
                        monthOptions().map((option) => {
                          return(
                            <option key={option} value={option}>
                              { labelMonthOption(option) }
                            </option>
                          )
                        })
                      }
                    </select>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default TemplateController;
