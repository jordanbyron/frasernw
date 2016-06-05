import React from "react";

const Selector = ({onChange, label, options, style, value}) => {
  return (
    <label>
      <span>{label}</span>
      <select value={value}
        style={style}
        onChange={onChange}>
        {
          options.map((option) => {
            return (
              <option key={option.key}
                value={option.key}
              >
                {option.label}
              </option>
            );
          })
        }
      </select>
    </label>
  );
};

export default Selector;
