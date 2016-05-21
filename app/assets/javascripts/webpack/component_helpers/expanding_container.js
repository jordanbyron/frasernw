import React from "react";

const ExpandingContainer = React.createClass({
  componentDidMount: function(){
    if (this.props.expanded){
      $(this.refs.container).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    var selectedInCurrentProps = this.props.expanded;
    var selectedInPrevProps = prevProps.expanded;

    if (selectedInPrevProps == false && selectedInCurrentProps == true && this.props.children.length > 0) {
      $(this.refs.container).slideDown();
    } else if (selectedInPrevProps == true && selectedInCurrentProps == false){
      $(this.refs.container).slideUp();
    }
  },
  render: function() {
    return(
      <div ref="container" style={{display: "none"}}>
        { this.props.children }
      </div>
    );
  }
})

export default ExpandingContainer;
