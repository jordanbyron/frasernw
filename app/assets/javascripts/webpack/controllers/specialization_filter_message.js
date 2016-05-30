import React from "react";
import { toggleSpecializationFilter } from "action_creators";
import { buttonIsh } from "stylesets";
import _ from "lodash";
import { collectionShownName } from "controller_helpers/collection_shown";
import {
  showSpecializationFilterMessage,
  withAllFilters,
  withoutSpecializationFilter,
  showingOtherSpecializations
} from "controller_helpers/table_modifiers";

const SpecializationFilterMessage = ({model, dispatch}) => {
  if (showSpecializationFilterMessage(model)) {
    if (showingOtherSpecializations(model)) {
      return(
        <div className="other-phrase" style={{display: "block"}}>
          <a onClick={
              _.partial(
                toggleSpecializationFilter,
                dispatch,
                model,
                true
              )
            }
            style={buttonIsh}
          >
            Hide
          </a>
          <span> results from other specialties.</span>
        </div>
      );
    } else {
      return(
        <div className="other-phrase" style={{display: "block"}}>
          <span>
            {
              "There are " +
              countFromOtherSpecializations(model) +
              " " +
              collectionShownName(model) +
              " from other specialties who match your search.  "
            }
          </span>
          <a onClick={
              _.partial(
                toggleSpecializationFilter,
                dispatch,
                model,
                false
              )
            }
            style={buttonIsh}
          >
            Show
          </a>
          <span>{" these " + collectionShownName(model) + "."}</span>
        </div>
      );
    }
  } else {
    return <noscript/>;
  }
}

const countFromOtherSpecializations = (model) => {
  return withoutSpecializationFilter(model).length - withAllFilters(model).length;
}

export default SpecializationFilterMessage;
