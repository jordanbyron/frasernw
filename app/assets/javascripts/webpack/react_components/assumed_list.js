var React = require("react");

var AssumedList = React.createClass({
  render: function() {
    if (this.props.shouldDisplay) {
      return(
        <div id="specialist_assumed_list">
          <i className="icon-asterisk icon-disabled icon-small"
            style={{marginRight: "5px"}}
          />
          {
            (
              "Areas of practice we assume all " +
              this.props.membersName +
              " see or do: " +
              this.props.list.join(", ")
            )
          }
        </div>
      )
    } else {
      return null;
    }
  }
})
module.exports = AssumedList;
