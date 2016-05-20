import React from 'react';
import { buttonIsh } from "stylesets";
import _ from "lodash";

const FilterGroup = React.createClass({
  render: function() {
    return (
      <div>
        <div className="filter_group__title open" key="title">
          <span>{ this.props.title }</span>
        </div>
        <div className="filter_group__filters" key="filters">
          <div style={{paddingTop: "12px", paddingBottom: "12px"}}>
            { this.props.children }
          </div>
        </div>
      </div>
    );
  }
});

export default FilterGroup;
