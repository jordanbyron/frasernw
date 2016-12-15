import React from "react";

const IssueComment = React.createClass({
  getInitialState: function() {
    var note_component = this;
    document.addEventListener("click", function() {
      note_component.deselect();
    })
    return _.assign({editing: false}, this.props);
  },
  edit: function() {
    if ((this.state.creator_id === this.state.current_user_id) &&
      (!this.state.editing)) {
        this.setState({editing: true});
      }
  },
  deselect: function() {
    var note_text = this;
    var save_triggered = false;
    $('#save_btn').mousedown(function() {
      save_triggered = true;
    });
    $('.comment_input').blur(function() {
      if (!save_triggered) {
        note_text.setState({editing: false});
      }
    });
  },
  onContentChange: function(event) {
    this.setState({raw_content: event.target.value});
  },
  save: function() {
    var component = this;
    $.ajax({
      url: `/notes/${this.state.id}`,
      type: "PATCH",
      data: { content: this.state.raw_content },
      success: function(data) {
        component.setState({
          raw_content: data.raw_content,
          content: data.content,
          editing: false
        });
      }
    });
  },
  render: function() {
    return(
      <div className="well" style={{width: "400px"}}
        onClick={this.edit}
      >
        <div style={{display: "inline-block"}}>
          <b>{ this.state.author_name }</b>
        </div>
        <div className="pull-right">
          <i>{ this.state.created_at }</i>
        </div>
        {
          this.state.editing ?
            <div>
              <textarea className="comment_input"
                style={{width: "390px", height: "100px"}}
                autoFocus={true}
                value={this.state.raw_content}
                onChange={this.onContentChange}
              />
              <div className="btn" id="save_btn" onClick={this.save}>Save</div>
            </div> :
            <div style={{clear: "both", marginTop: "10px"}}
              dangerouslySetInnerHTML={{__html: this.state.content}}
            />
        }
      </div>
    )
  }
});

export default IssueComment
