import React from "react";

const RadioButtons = ({value, options, name, onChange}) => {
  return(
    <div>
      {
        options.map((option) => {
          return(
            <div key={option.key}>
              <label>
                <input
                  name={name}
                  type="radio"
                  value={option.key}
                  checked={option.key === value}
                  onChange={onChange}
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
};

export default RadioButtons
