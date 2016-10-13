import { route } from "controller_helpers/routing";
import { toDate } from "controller_helpers/month_options";
import * as filterValues from "controller_helpers/filter_values";

const isDataDubious = (model) => {
  return route === "/reports/entity_page_views" &&
    _.some(DubiousDateRanges, (range) => range.test(model))
}

export const DubiousDateRanges = [
  {
    test: (model) => {
      return toDate(filterValues.startMonth(model)) >
        toDate(filterValues.endMonth(model))
    },
    label: (model) => {
      return "Start month can't be later than end month";
    }
  },
  {
    test: (model) => {
      return toDate(filterValues.startMonth(model)) < toDate("201511") &&
        _.includes(["physicianResources", "forms", "patientInfo", "redFlags", "communityServices"],
          filterValues.entityType(model))
    },
    label: (model) => {
      if(model.app.currentUser.role === "super"){
        return(
          "Data from before November 2015 may underreport clicks on links to " +
          "externally hosted content. " +
          "Use of this data is discouraged."
        );
      }
      else {
        return(
          _.startCase(filterValues.entityType(model)) +
          " page views are only available for November 2015 and later."
        );
      }
    }
  },
  {
    test: (model) => {
      return selectedMonthsIncludes(model, "201606") &&
        _.includes(["physicianResources", "forms", "patientInfo", "redFlags", "communityServices"],
          filterValues.entityType(model));
    },
    label: (model) => {
      return(
        "Due to a programming error, content item page views for June 2016 " +
        "may be slightly inflated.  By extrapolating from trends, we estimate " +
        "the error to be about 20% inflation."
      );
    }
  }
];

const selectedMonthsIncludes = (model, testMonth) => {
  return toDate(filterValues.startMonth(model)) <= toDate(testMonth) &&
    toDate(filterValues.endMonth(model)) >= toDate(testMonth);
}

export default isDataDubious;
