import React from 'react';
import { buttonIsh } from "stylesets";
import _ from "lodash";

const ExpandableFilterGroup = React.createClass({
  componentDidMount: function(){
    if (this.props.isExpanded){
      $(this.refs.contents).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    if (prevProps.isExpanded == false && this.props.isExpanded == true) {
      $(this.refs.contents).slideDown();
    } else if (prevProps.isExpanded == true && this.props.isExpanded == false){
      $(this.refs.contents).slideUp();
    }
  },
  render: function() {
    return (
      <div>
        <div className="filter_group__title filter_group__title--clickable open"
          onClick={this.props.toggleExpansion || _.noop}
          style={buttonIsh}
          key="title"
        >
          <span>{ this.props.title }</span>
          <ToggleIcon isExpanded={this.props.isExpanded}/>
        </div>
        <div className="filter_group__filters"
          key="contents"
          ref="contents"
          style={{display: "none"}}
        >
          <div style={{paddingTop: "12px", paddingBottom: "12px"}}>
            { this.props.children }
          </div>
        </div>
      </div>
    );
  }
});

const ToggleIcon = ({isExpanded}) => {
  if(isExpanded) {
    return(
      <i className={
        "icon-minus " +
        "specialization_table__filter_toggle " +
        "filter_group__toggle"
      }/>
    )
  }
  else {
    return(
      <i className={
        "icon-plus " +
        "specialization_table__filter_toggle " +
        "filter_group__toggle"
      }/>
    );
  }
}

const iconStyle = {
  background: "transparent url('/assets/filtering-divider.png') 0% 50% repeat-y",
  paddingLeft: "10px"
};

export default ExpandableFilterGroup;
