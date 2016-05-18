import React from "react";
import { buttonIsh } from "stylesets";

const ExpandBox = React.createClass({
  componentDidMount: function(){
    if (this.props.expanded){
      $(this.refs.contents).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    if (prevProps.expanded == false && this.props.expanded == true) {
      $(this.refs.contents).slideDown();
    } else if (prevProps.expanded == true && this.props.expanded == false){
      $(this.refs.contents).slideUp();
    }
  },
  toggleText: function() {
    if (this.props.expanded) {
      return "Less...";
    } else {
      return "More...";
    }
  },
  render: function() {
    return (
      <div>
        <a onClick={this.props.handleToggle} style={buttonIsh}>{ this.toggleText() }</a>
        <div style={{display: "none", marginTop: "2px"}} ref="contents">
          {
            React.Children.map(this.props.children, (child) => child)
          }
        </div>
      </div>
    );
  }
});

export default ExpandBox;
