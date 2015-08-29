var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  handleFilterUpdate: function(val) {
    return(() => {
      return this.props.updateFilter(
        "specialization",
        val
      );
    });
  },
  render: function() {
    if (this.props.show) {
      if (this.props.showingOtherSpecialties) {
        return(
          <div className="other-phrase" style={{display: "block"}}>
            <a onClick={this.handleFilterUpdate(true)} style={buttonIsh}>
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
                this.props.remainder +
                " specialists who match your search.  "
              }
            </span>
            <a onClick={this.handleFilterUpdate(false)} style={buttonIsh}>
              Show
            </a>
            <span> these specialists.</span>
          </div>
        );
      }
    } else {
      return null;
    }
  }
})
