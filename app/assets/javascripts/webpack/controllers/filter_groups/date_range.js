import FilterGroup from "component_helpers/filter_group";
import * as FilterValues from "controller_helpers/filter_values";
import { padTwo } from "utils";
import React from "react";
import { changeFilterValue } from "action_creators";

const DateRangeFilter = ({model, dispatch}) => {
  return(
    <FilterGroup title="Date Range">
      <label style={{marginTop: "10px"}}>
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
      <label style={{marginTop: "10px", marginBottom: "20px"}}>
        <div>End Month:</div>
        <select
          value={FilterValues.endMonth(model)}
          onChange={function(e) { changeFilterValue(dispatch, "endMonth", e.target.value) } }
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
    </FilterGroup>
  );
};


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

export default DateRangeFilter;
