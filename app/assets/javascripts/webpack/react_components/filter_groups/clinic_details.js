var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var Selector = require("../selector");

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      public: React.PropTypes.shape({ value: React.PropTypes.bool }),
      private: React.PropTypes.shape({ value: React.PropTypes.bool }),
      wheelchairAccessible: React.PropTypes.shape({ value: React.PropTypes.bool }),
    })
  },
  handlePublicUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "public",
      update: event.target.checked
    });
  },
  handlePrivateUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "private",
      update: event.target.checked
    });
  },
  handleWheelchairAccessibleUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "wheelchairAccessible",
      update: event.target.checked
    });
  },
  render: function() {
    return (
      <div>
        <CheckBox
          label="Public"
          value={this.props.filters.public.value}
          onChange={this.handlePublicUpdate}
        />
        <CheckBox
          label="Private"
          value={this.props.filters.private.value}
          onChange={this.handlePrivateUpdate}
        />
        <CheckBox
          label="Wheelchair Accessible"
          value={this.props.filters.wheelchairAccessible.value}
          onChange={this.handleWheelchairAccessibleUpdate}
        />
      </div>
    );
  }
});
