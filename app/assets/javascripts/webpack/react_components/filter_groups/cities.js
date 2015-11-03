var React = require("react");
var CheckBox = require("../checkbox");
var mapValues = require("lodash/object/mapValues");
var checkboxLabelStyle = require("../../stylesets").halfColumnCheckbox;
var values = require("lodash/object/values");
var some = require("lodash/collection/some");
var every = require("lodash/collection/every");

var handleUpdateCities = function(dispatch, update) {
  dispatch({
    type: "UPDATE_FILTER",
    filterType: "cities",
    update: update
  })
}

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      cities: React.PropTypes.arrayOf(React.PropTypes.shape({
        value: React.PropTypes.boolean,
        filterId: React.PropTypes.string,
        label: React.PropTypes.string
      }))
    })
  },
  hrStyle: {
    margin: "0px",
    borderColor: "#CEC9C9",
    marginBottom: "6px",
    marginTop: "4px",
    borderWidth: "1px"
  },
  handleOneCityUpdate: function(event, key) {
    handleUpdateCities(this.props.dispatch, { [key] : event.target.checked });
  },
  everyCityUpdate: function(cities, value) {
    return cities.reduce((memo, city) => {
      return _.assign(
        memo,
        { [ city.filterId ] : value }
      );
    }, {});
  },
  render: function() {
    return (
      <div>
        <div style={{color: "#CEC9C9"}}>
          <a style={{cursor: "pointer"}}
            onClick={handleUpdateCities.bind(this, this.props.dispatch, this.everyCityUpdate(this.props.filters.cities, true))}
          >
            All Cities
          </a>
          <span style={{marginLeft: "3px", marginRight: "3px"}}>|</span>
          <a style={{cursor: "pointer"}}
            onClick={handleUpdateCities.bind(this, this.props.dispatch, undefined)}
          >
            Regional Cities
          </a>
          <span style={{marginLeft: "3px", marginRight: "3px"}}>|</span>
          <a style={{cursor: "pointer"}}
            onClick={handleUpdateCities.bind(this, this.props.dispatch, this.everyCityUpdate(this.props.filters.cities, false))}
          >
            No Cities
          </a>
        </div>
        <hr style={this.hrStyle}/>
        {
          this.props.filters.cities.map(function(filter: Object){
            return(<CheckBox
              key={filter.filterId}
              changeKey={filter.filterId}
              label={filter.label}
              value={filter.value}
              onChange={this.handleOneCityUpdate}
              labelStyle={checkboxLabelStyle}
            />);
          }, this)
        }
      </div>
    );
  }
});
