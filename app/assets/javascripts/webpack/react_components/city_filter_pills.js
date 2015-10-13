var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;
var flatten = require("lodash/array/flatten");
var uniq = require("lodash/array/uniq");
var countBy = require("lodash/collection/countBy");
var map = require("lodash/collection/map");
var objectAssign = require("object-assign");

const CityFilterPills = React.createClass({
  propTypes: {
    shouldDisplay: React.PropTypes.bool,
    availableFromOtherCities: React.PropTypes.arrayOf(React.PropTypes.object),
    dispatch: React.PropTypes.func,
    cityFilterValues: React.PropTypes.object,
    cities: React.PropTypes.object
  },
  handleClick: function(id) {
    return (e) => {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "cities",
        update: { [id] : true }
      });
    };
  },
  otherCities: function() {
    // how many times the city id comes up in all the records
    var idCounts = countBy(
      flatten(this.props.availableFromOtherCities.map((record) => record.cityIds)),
      (id) => id
    );

    return map(idCounts, (count, id) => {
      return {
        id: id,
        name: this.props.cities[id].name,
        count: count
      };
    }).filter((city) => {
      return !this.props.cityFilterValues[city.id];
    });
  },
  render: function() {
    if (this.props.shouldDisplay) {
      return(
        <div>
          <p style={{marginLeft: "0px", fontWeight: "bold"}}>You can also expand your search by selecting more cities:</p>
          <div style={{marginTop: "10px", marginBottom: "10px"}}>
            {
              this.otherCities().map((city) => {
                return (
                  <div key={city.id} onClick={this.handleClick(city.id)} style={buttonIsh} className="specialization_table__city_filter_pill">
                    {city.name + " (" + city.count + ")"}
                  </div>
                );
              })
            }
          </div>
        </div>
      );
    } else {
      return null;
    }
  }
});
module.exports = CityFilterPills;
