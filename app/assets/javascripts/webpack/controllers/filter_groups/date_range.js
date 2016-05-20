import FilterGroup from "controllers/filter_group";
import FilterSelector from "controllers/filter_selector";
import { padTwo } from "utils";
import React from "react";
import { matchedRoute } from "controller_helpers/routing";

const DateRangeFilters = ({model, dispatch}) => {
  if(matchedRoute(model) === "/reports/pageviews_by_user"){
    return(
      <FilterGroup title="Date Range" isCollapsible={false}>
        <FilterSelector
          label="Start Month:"
          filterKey="startMonth"
          model={model}
          dispatch={dispatch}
          options={monthOptions()}
        />
        <FilterSelector
          label="End Month:"
          filterKey="endMonth"
          model={model}
          dispatch={dispatch}
          options={monthOptions()}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>
  }
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
  ).reverse().map((option) => {
    return { key: option, label: labelMonthOption(option) };
  });
};

export default DateRangeFilters;
