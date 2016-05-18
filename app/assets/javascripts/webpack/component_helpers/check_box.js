import React from "react";

const CheckBox = ({checked, onChange, style, label, labelStyle}) => {
  return (
    <label style={labelStyle}>
      <input
        type="checkbox"
        checked={checked}
        onChange={onChange}
        className="checkbox"
        style={style}
      ></input>
      <span>{label}</span>
    </label>
  );
};

export default CheckBox;
