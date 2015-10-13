var React = require("react");
var CheckBox = require("../checkbox");
var mapValues = require("lodash/object/mapValues");
var checkboxLabelStyle = require("../../stylesets").halfColumnCheckbox;
var values = require("lodash/object/values");
var some = require("lodash/collection/some");
var every = require("lodash/collection/every");

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      cities: React.PropTypes.arrayOf(React.PropTypes.shape({
        value: React.PropTypes.boolean,
        key: React.PropTypes.string,
        label: React.PropTypes.string
      }))
    })
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "cities",
      update: { [key] : event.target.checked }
    });
  },
  handleSearchAll: function(event) {
    if (event.target.checked) {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "searchAllCities",
        update: true
      });
    } else {
      this.props.dispatch({
        type: "RESET_SEARCH_ALL_CITIES"
      });
    };
  },
  hrStyle: {
    margin: "0px",
    borderColor: "#CEC9C9",
    marginBottom: "6px",
    borderWidth: "1px"
  },
  render: function() {
    return (
      <div>
        <CheckBox
          key="All"
          label="All Cities"
          value={this.props.filters.searchAllCities.value}
          onChange={this.handleSearchAll}
        />
        <hr style={this.hrStyle}/>
        {
          this.props.filters.cities.map(function(filter: Object){
            return(<CheckBox
              key={filter.filterId}
              changeKey={filter.filterId}
              label={filter.label}
              value={filter.value}
              onChange={this.handleCheckboxUpdate}
              labelStyle={checkboxLabelStyle}
            />);
          }, this)
        }
      </div>
    );
  }
});
