var React = require("react");

module.exports = React.createClass({
  styleClass: function(sectionName) {
    if (sectionName === this.props.reducedView){
      return "";
    } else {
      return "hide-when-reduced";
    }
  },
  render: function() {
    return (
      <div className="content">
        <div className="row">
          <div className={["span8half", this.styleClass("main")].join(" ")}>
            {this.props.main}
          </div>
          <div className={["span3", "offsethalf", "datatable-sidebar", this.styleClass("sidebar")].join(" ")}>
            {this.props.sidebar}
          </div>
        </div>
      </div>
    );
  }
});
