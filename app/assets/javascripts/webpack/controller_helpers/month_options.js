import _ from "lodash";
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

export const labelMonthOption = (monthKey) => {
  const month = AbbreviatedMonths[(parseInt(monthKey.slice(4, 6)))];
  const year = monthKey.slice(0, 4);

  return `${month} ${year}`;
}

const monthOptions = (startYear, startMonth) => {
  return _.range(startYear, ((new Date).getUTCFullYear() + 1)).map((year) => {
    if (year === startYear) {
      var startMonthForYear = startMonth;
    }
    else {
      var startMonthForYear = 1;
    }

    if (year === (new Date).getUTCFullYear()){
      var endMonthForYear = (new Date).getMonth() + 2;
    }
    else {
      var endMonthForYear = 12;
    }

    return _.range(
      startMonthForYear,
      endMonthForYear
    ).map((monthNumber) => `${year}${padTwo(monthNumber)}`)
  }).pwPipe(_.flatten).reverse().map((option) => {
    return { key: option, label: labelMonthOption(option) };
  });
};

export default monthOptions;
