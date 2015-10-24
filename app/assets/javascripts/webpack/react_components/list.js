var React = require("react");

var List = React.createClass({
  listStyle: function() {
    if (this.props.isOpen) {
      return {};
    } else {
      return { display: "none" };
    }
  },
  render: function() {
    return(
      <div style={{marginBottom: "10px"}}>
        <div style={{fontWeight: "bold", fontFamily: "Bitter", fontSize: "14px", marginBottom: "5px"}}
          key="title"
        >
          { `${this.props.title}`}
        </div>
        <div style={this.listStyle()}>
          <table className="table">
            <tbody>
              {
                this.props.items.map((item) => {
                  return(
                    <tr
                      className="referents_by_specialty__row"
                      key={item.reactKey}
                    >
                      <td>
                        {item.content}
                        <div
                          style={{float: "right"}}
                          className="referents_by_specialty__faded_content"
                        >{item.fadedContent}</div>
                      </td>
                    </tr>
                  );
                })
              }
            </tbody>
          </table>
        </div>
      </div>
    );
  }
})

module.exports = List;
