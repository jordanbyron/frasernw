import React from "react";

const ProcedureSpecializableForm = React.createClass({
  render: function(){
    return(
      <ProcedureSpecializableNodes
        model={this.props}
        nodes={this.props.hierarchy}
        offset={0}
      />
    );
  }
});

const ProcedureSpecializableNodes = ({model, nodes, offset}) => {
  return(
    <div>
      {
        nodes.map((node) => {
          const inputNameRoot =
            `[${model.procedureSpecializableType}_${node.type}s][${node.id}]`

          const link = model[`${node.type}_links`][node.id];

          return(
            <div key={`${node.id}${node.type}`} class={`offset${offset}`}>
              <input type="hidden" name={`${inputNameRoot}[${node.type}_id]`}/>
              <input type="hidden" name={`${inputNameRoot}[_destroy]`} value="1"/>
              <input
                type="checkbox"
                name={`${inputNameRoot}[_destroy]`}
                value="1"
                checked={link.checked}
              />
              <span>{node.name}</span>
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
                  /> : <div></div>
              }
            </div>
          );
        })
      }
    </div>
  )
}


export default ProcedureSpecializableForm;
