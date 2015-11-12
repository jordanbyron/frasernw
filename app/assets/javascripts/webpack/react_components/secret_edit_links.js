import React from "react";
import _ from "lodash";

const SecretEditLinkTable = (props) => (
  <table className="table">
    <thead>
      <tr>
        <th>Recipient</th>
        <th>Creator</th>
        <th>Created At</th>
      </tr>
    </thead>
    <tbody>
      {
        props.links.map((link, index) => (
          <tr key={link.id}>
            <td>{link.recipient}</td>
            <td>{link.creator}</td>
            <td>{link.created_at}</td>
          </tr>
        ))
      }
    </tbody>
  </table>
)

const GenerateButton = React.createClass({
  onGenerateClick() {
    if(this.refs.recipient.value.length > 0){
      this.props.addLink(this.refs.recipient.value);
    }
    else {
      alert("Recipient must be present");
    }
  },
  render() {
    if(this.props.canEdit) {
      return(
        <div>
          <hr/>
          <div
            className="btn btn-default"
            onClick={this.onGenerateClick}
          >Generate new link for</div>
          <input
            style={{marginBottom: "0px", marginLeft: "5px"}}
            placeholder="recipient"
            ref="recipient"
          ></input>
        </div>
      );
    }
    else {
      return <div></div>;
    }
  }
})


const SecretEditLinks = React.createClass({
  getInitialState() {
    return {};
  },
  links() {
    return (this.state.links || this.props.links);
  },
  addLink(recipient) {
    $.post(this.props.addLink, {
      recipient: recipient,
      accessible_id: this.props.accessibleId,
      accessible_type: this.props.accessibleType
    }).done((data) => {
      let lineOne = `Your secret edit link for ${data.link.recipient} is:`
      let lineThree = "This link will not be visible after this notification is closed, in order to preserve knowledge of its creator and recipients."
      
      alert(`${lineOne}\n\n${data.link.link}\n\n${lineThree}`);

      this.setState({
        links: this.links().concat(data.link)
      });
    })
  },
  render() {
    return(
      <div style={{marginTop: "10px"}}>
        <h6 style={{margin: "0px", marginBottom: "5px"}}>Secret Edit Links</h6>
        <i style={{marginLeft: "5px"}}>Anyone can edit the record if they have one of the following links:</i>
        <SecretEditLinkTable links={this.links()}/>
        <GenerateButton canEdit={this.props.canEdit} addLink={this.addLink}/>
      </div>
    );
  }
});

export default SecretEditLinks;
