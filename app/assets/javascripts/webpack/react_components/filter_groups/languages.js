var React = require("react");
var CheckBox = require("../checkbox");
var sortBy = require("lodash/collection/sortBy");
var keys = require("lodash/object/keys");
var checkboxLabelStyle = require("../../stylesets").halfColumnCheckbox;
var mask = require("../../utils").mask

var Languages = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      interpreterAvailable: React.PropTypes.shape({
        value: React.PropTypes.bool
      }),
      languages: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          filterId: React.PropTypes.string,
          label: React.PropTypes.string,
          value: React.PropTypes.bool
        })
      )
    })
  },
  handleLanguageUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "languages",
      update: { [key] : event.target.checked }
    });
  },
  handleInterpreterUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "interpreterAvailable",
      update: event.target.checked
    });
  },
  render: function() {
    return (
      <div>
        <CheckBox
          key="interpreterAvailable"
          changeKey="interpreterAvailable"
          label="Interpreter Available"
          value={this.props.filters.interpreterAvailable.value}
          onChange={this.handleInterpreterUpdate}
          labelStyle={checkboxLabelStyle}
        />
        {
          this.props.filters.languages.map((language) => {
            return (
              <CheckBox
                key={language.filterId}
                changeKey={language.filterId}
                label={language.label}
                value={language.value}
                onChange={this.handleLanguageUpdate}
                labelStyle={checkboxLabelStyle}
              />
            );
          })
        }
      </div>
    );
  }
});
module.exports = Languages;
