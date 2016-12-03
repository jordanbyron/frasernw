const raiseWithAlert = (errorMsg) => {
  alert(errorMsg);
  throw new Error(errorMsg);
}
