import React from "react";

const ProcedureSpecializableForm = React.createClass({
  getInitialState: function(){
    return this.props;
  },
  render: function(){
    console.log(this.state);

    return(
      <ProcedureSpecializableNodes
        model={this.state}
        nodes={this.state.hierarchy}
        setState={this.setState.bind(this)}
        offset={0}
      />
    );
  }
});

const ProcedureSpecializableNodes = ({model, nodes, offset, setState}) => {
  return(
    <div>
      {
        nodes.
          pwPipe((nodes) => _.sortBy(nodes, _.property("name"))).
          map((node) => {
            const inputNameRoot = model.procedure_specializable_type +
              `[${model.procedure_specializable_type}_${node.type}s_attributes]` +
              `[${node.id}]`

            const link = model[`${node.type}_links`][node.id];

            return(
              <div
                key={`${node.id}${node.type}`}
                style={{marginBottom: "5px", marginTop: "5px", marginLeft: `${offset * 30}px`}}
              >
                <input type="hidden"
                  name={`${inputNameRoot}[${node.type}_id]`}
                  value={node.id}
                />
                <input type="hidden" name={`${inputNameRoot}[_destroy]`} value="1"/>
                <input
                  type="checkbox"
                  name={`${inputNameRoot}[_destroy]`}
                  value="0"
                  checked={link.checked}
                  onChange={_.partial(onNodeChange, node.type, node.id, setState, model)}
                />
                <div
                  style={{
                    display: "inline-block",
                    minHeight: "28px",
                    marginLeft: "5px",
                    fontWeight: (node.type === "specialization" ? "bold" : "normal")
                  }}
                >{node.name}</div>
                {
                  (_.includes(["specialist", "clinic"], model.procedure_specializable_type)  &&
                    node.type === "procedure") &&
                    link.checked ?
                    <span style={{marginLeft: "5px"}}>
                      (
                      <input type="text" style={{margin: "0px 5px"}}></input>
                      )
                    </span> : <span></span>
                }
                {
                  (_.includes(["specialist", "clinic"], model.procedure_specializable_type)  &&
                    node.type === "procedure") &&
                    node[`${model.procedure_specializable_type}s_specify_wait_times`] &&
                    link.checked ?
                    <span>
                      <i style={{marginRight: "5px"}}>, Booking Wait Time:</i>
                      <select style={{width: "70px", marginRight: "5px"}}>
                        <option>1 week</option>
                      </select>
                      <i style={{marginRight: "5px"}}>, Consultation Wait Time:</i>
                      <select style={{width: "70px", marginRight: "5px"}}>
                        <option>1 week</option>
                      </select>
                    </span> : <span></span>
                }
                {
                  link.id ?
                    <input type="hidden" name={`${inputNameRoot}[id]`} value={link.id}/>
                    : <div></div>
                }
                {
                  link.checked ?
                    <ProcedureSpecializableNodes
                      model={model}
                      nodes={node.children}
                      offset={offset + 1}
                      setState={setState}
                    /> : <div></div>
                }
              </div>
            );
          })
      }
    </div>
  )
}

const onNodeChange = (nodeType, nodeId, setState, model, event) => {
  setState({
    [`${nodeType}_links`]: _.assign(
      {},
      model[`${nodeType}_links`],
      {
        [nodeId]: _.assign(
          {},
          model[`${nodeType}_links`][nodeId],
          { checked: event.target.checked }
        )
      }
    )
  });
}


export default ProcedureSpecializableForm;
