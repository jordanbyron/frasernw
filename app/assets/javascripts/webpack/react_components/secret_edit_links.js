import React from "react";
import _ from "lodash";
import Modal from "react_components/modal";

const ExpireButton = (props) => {
  if(props.link.canExpire) {
    return(
      <i className="icon-remove" onClick={props.onClick}/>
    );
  }
  else {
    return(<div></div>);
  }
}

const SecretEditLinkTable = (props) => (
  <table className="table">
    <thead>
      <tr>
        <th>Recipient</th>
        <th>Creator</th>
        <th>Created At</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <GenerateButton {...props.generateButton}/>
      {
        props.links.map((link, index) => (
          <tr key={link.id}>
            <td>{link.recipient}</td>
            <td>{link.creator}</td>
            <td>{link.created_at}</td>
            <td><ExpireButton link={link} onClick={props.expireLink.bind(null, link.id)}/></td>
          </tr>
        ))
      }
    </tbody>
  </table>
)

const GenerateButton = React.createClass({
  generateLink() {
    if(this.refs.recipient.value.length > 0){
      this.props.addLink(this.refs.recipient.value);
    }
    else {
      alert("Recipient must be present");
    }
  },
  onKeyPress(e) {
    if(e.keyCode === 13) {
      this.generateLink();
    }
  },
  onGenerateClick() {
    this.generateLink();
  },
  render() {
    if(this.props.canEdit) {
      return(
        <tr>
          <td style={{backgroundColor: "#F3F8FC"}}>
            <input
              style={{margin: "5px 0px"}}
              placeholder="Email"
              ref="recipient"
              onChange={this.props.onUpdateRecipient}
              onKeyUp={this.onKeyPress}
              value={this.props.recipient}>
            </input>
          </td>
          <td style={{backgroundColor: "#F3F8FC"}}>{this.props.currentUserName}</td>
          <td style={{backgroundColor: "#F3F8FC"}}></td>
          <td style={{backgroundColor: "#F3F8FC"}}>
            <i
              className="icon-plus"
              onClick={this.onGenerateClick}
            />
          </td>
        </tr>
      );
    }
    else {
      return <tr></tr>;
    }
  }
});

const margins = { marginBottom: "10px" }
const ModalContents = (modalProps) => (
  <div>
    <h4 style={margins}>Secret Edit Link Created!</h4>
    <div style={margins}>{ `Your secret edit link for ${modalProps.link.recipient} is:` }</div>
    <div style={_.assign({fontWeight: "bold"}, margins)}>{ modalProps.link.link }</div>
    <div style={margins}>Please copy and email the link now, since it will not be visible after this dialogue is closed.</div>
    <div className="btn btn-primary" onClick={modalProps.close}>Done</div>
  </div>
)

const SecretEditModal = (modalProps) => (
  <Modal isVisible={modalProps.isVisible} renderContents={ModalContents.bind(null, modalProps)}/>
)

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
      this.setState({
        links: [ data.link ].concat(this.links()),
        modal: { isVisible: true, link: data.link },
        recipient: ""
      });
    })
  },
  modalProps() {
    return _.assign(
      {},
      (this.state.modal || this.props.modal),
      { close: this.closeModal }
    );
  },
  closeModal() {
    this.setState({modal: { isVisible: false }});;
  },
  onUpdateRecipient: function(e) {
    this.setState({ recipient: e.target.value });
  },
  expireLink: function(id) {
    if(confirm("Are you sure you would like to expire this secret edit link?")){
      $.ajax({
        url: `/secret_tokens/${id}`,
        type: "DELETE"
      }).done((data) => {
        this.setState({
          links: _.filter(this.state.links, (link) => link.id !== id)
        });
      })
    }
  },
  recipient() {
    return (this.state.recipient || "");
  },
  generateButtonProps() {
    return({
      canEdit: this.props.canEdit,
      addLink: this.addLink,
      recipient: this.recipient(),
      currentUserName: this.props.currentUserName,
      onUpdateRecipient: this.onUpdateRecipient
    });
  },
  render() {
    return(
      <div style={{marginTop: "10px"}}>
        <h6 style={{marginBottom: "5px"}}>Secret Edit Links</h6>
        <i style={{marginLeft: "5px"}}>Anyone can edit the record if they have one of the following links:</i>
        <SecretEditLinkTable
          links={this.links()}
          expireLink={this.expireLink}
          generateButton={this.generateButtonProps()}
        />
        <SecretEditModal {...this.modalProps()}/>
      </div>
    );
  }
});

export default SecretEditLinks;
