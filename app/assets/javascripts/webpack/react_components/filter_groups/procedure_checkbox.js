var React = require("react");
var CheckBox = require("../checkbox");

// 'level' used to generate nesting
var ProcedureCheckbox = React.createClass({
  propTypes: {
    filterId: React.PropTypes.string,
    label: React.PropTypes.string.isRequired,
    level: React.PropTypes.number.isRequired,
    value: React.PropTypes.bool.isRequired,
    children: React.PropTypes.array
  },
  children: function(procedure, level) {
    return(
      <div style={{display: "none"}} ref="children">
        {
          this.props.children.map((procedure) => {
            return(
              <ProcedureCheckbox
                key={procedure.id}
                filterId={procedure.id}
                label={procedure.label}
                value={procedure.value}
                children={procedure.children}
                level={level + 1}
                handleCheckboxUpdate={this.props.handleCheckboxUpdate}
              />
            );
          })
        }
      </div>
    );
  },
  componentDidMount: function(){
    if (this.props.value){
      $(this.refs.children).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    var selectedInCurrentProps = this.props.value;
    var selectedInPrevProps = prevProps.value;

    if (selectedInPrevProps == false && selectedInCurrentProps == true && this.props.children.length > 0) {
      $(this.refs.children).slideDown();
    } else if (selectedInPrevProps == true && selectedInCurrentProps == false){
      $(this.refs.children).slideUp();
    }
  },
  render: function() {
    return(
      <div key={this.props.filterId}>
        <CheckBox
          key={this.props.filterId}
          changeKey={this.props.filterId}
          label={this.props.label}
          value={this.props.value}
          onChange={this.props.handleCheckboxUpdate}
          style={{marginLeft: ((this.props.level * 20).toString() + "px")}}
        />
        { this.children(this.props.procedure, this.props.level) }
      </div>
    );
  }
});

module.exports = ProcedureCheckbox;
