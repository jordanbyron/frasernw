var React = require("react");

var RadioButtons = React.createClass({
  propTypes: {
    handleChange: React.PropTypes.func,
    options: React.PropTypes.arrayOf(React.PropTypes.shape({
      key: React.PropTypes.string,
      checked: React.PropTypes.bool,
      label: React.PropTypes.string
    }))
  },
  render: function() {
    return(
      <div>
        {
          this.props.options.map((option) => {
            return(
              <div key={option.key}>
                <label>
                  <input
                    type="radio"
                    value={option.key}
                    checked={option.checked}
                    onChange={this.props.handleChange}
                    style={{display: "inline-block", marginRight: "7px"}}
                    key={option.key}
                  />
                  { option.label }
                </label>
              </div>
            );
          })
        }
      </div>
    )
  }
})
module.exports = RadioButtons;
