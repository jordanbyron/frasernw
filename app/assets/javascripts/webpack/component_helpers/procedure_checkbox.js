import React from "react";
import CheckBox from "component_helpers/check_box";

const ProcedureCheckbox = React.createClass({
  componentDidMount: function(){
    if (this.props.checked){
      $(this.refs.children).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    var selectedInCurrentProps = this.props.checked;
    var selectedInPrevProps = prevProps.checked;

    if (selectedInPrevProps == false &&
      selectedInCurrentProps == true &&
      this.props.children &&
      this.props.children.length > 0) {

      $(this.refs.children).slideDown();
    } else if (selectedInPrevProps == true && selectedInCurrentProps == false){
      $(this.refs.children).slideUp();
    }
  },
  render: function() {
    return(
      <div>
        <CheckBox
          label={
            <ProcedureCheckboxLabel
              labelText={this.props.label}
              waitTimesSpecified={this.props.waitTimesSpecified}
            />
          }
          checked={this.props.checked}
          onChange={this.props.onChange}
          style={{marginLeft: ((this.props.level * 20).toString() + "px")}}
        />
        <div style={{display: "none"}} ref="children">
          { this.props.children }
        </div>
      </div>
    );
  }
});

const ProcedureCheckboxLabel = ({labelText, waitTimesSpecified}) => {
  if (waitTimesSpecified) {
    return(
      <span>
        <span>{labelText}</span>
        <i className="icon-link" style={{marginLeft: "5px"}}/>
      </span>
    );
  }
  else {
    return (<span>{labelText}</span>)
  }
}

export default ProcedureCheckbox;
