var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

const SpecializationFilterMessage = React.createClass({
  propTypes: {
    shouldDisplay: React.PropTypes.bool,
    remainderCount: React.PropTypes.number,
    dispatch: React.PropTypes.func,
    showingOtherSpecialties: React.PropTypes.bool
  },
  handleFilterUpdate: function(val) {
    return(() => {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "specializationFilterActivated",
        update: val
      });
    });
  },
  render: function() {
    if (this.props.shouldDisplay) {
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
                this.props.remainderCount +
                " " +
                this.props.collectionName +
                " from other specialties who match your search.  "
              }
            </span>
            <a onClick={this.handleFilterUpdate(false)} style={buttonIsh}>
              Show
            </a>
            <span>{" these " + this.props.collectionName + "."}</span>
          </div>
        );
      }
    } else {
      return null;
    }
  }
})
module.exports = SpecializationFilterMessage
