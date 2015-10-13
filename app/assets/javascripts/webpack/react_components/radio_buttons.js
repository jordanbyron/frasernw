var React = require("react");

var RadioButtons = React.createClass({
  propTypes: {
    handleClick: React.PropTypes.func,
    options: React.PropTypes.arrayOf({
      key: React.PropTypes.string,
      checked: React.PropTypes.bool,
      label: React.PropTypes.string
    })
  },
  render: function() {
    return(
      <div>
        {
          this.props.options.map((option) => {
            return(
              <div>
                <label>
                  <input
                    type="radio"
                    value={option.key}
                    checked={option.checked}
                    onClick={this.props.handleClick}
                    style={{display: "inline-block", marginRight: "7px"}}
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
