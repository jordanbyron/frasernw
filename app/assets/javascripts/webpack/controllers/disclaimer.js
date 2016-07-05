import React from "react";
import isDataDubious from "controller_helpers/dubious_data";
import * as filterValues from "controller_helpers/filter_values";
import _ from "lodash";
import { DubiousDateRanges } from "controller_helpers/dubious_data";

const Disclaimer = ({model}) => {
  if(isDataDubious(model)) {
    return(
      <div
        className="alert alert-info"
        style={{marginTop: "10px"}}
      >
        <ul>
          {
            labels(model).map((label, index) => {
              return <li key={index}>{label}</li>
            })
          }
        </ul>
      </div>
    );
  }
  else {
    return <noscript/>
  }
};

const labels = (model) => {
  return DubiousDateRanges.
    filter((range) => range.test(model)).
    map(_.property("label")).
    map((label) => label(model))
};

export default Disclaimer;
