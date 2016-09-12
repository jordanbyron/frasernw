import base64 from "base-64";
import utf8 from "utf8";
import _ from "lodash";

window.base64 = base64;
window.utf8 = utf8;

export const encode = (object) => {
  return object.
    pwPipe(JSON.stringify).
    pwPipe(utf8.encode).
    pwPipe(base64.encode).
    pwPipe(encodeBase64ForUrl)
}

export const decode = (string) => {
  return string.
    pwPipe(decodeBase64FromUrl).
    pwPipe(base64.decode).
    pwPipe(utf8.decode).
    pwPipe(JSON.parse)
}

const encodeBase64ForUrl = (string) => {
  return string.replace(/\+/g, '-').
    replace(/\//g, '_').
    replace(/\=+$/, '');
}

const decodeBase64FromUrl = (string) => {
  if (string % 4 === 0){
    var decoded = string;
  }
  else {
    var decoded = string + _.repeat("=", (4 - (string % 4 )))
  }

  return decoded.
    replace(/-/g, '+').
    replace(/_/g, '/');
}

window.decodeBase64FromUrl = decodeBase64FromUrl;
