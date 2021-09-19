import $ from "jquery";
import * as Clipboard from "clipboard/dist/clipboard";

$(document).ready(() => {
  var clipboard = new Clipboard(".clipboard-btn");

  clipboard.on("success", e => {
    var currentText = e.trigger.innerText;
    e.trigger.innerText = "Copied";

    setTimeout(() => {
      e.trigger.innerText = currentText;
    }, 2000);
  });
});
