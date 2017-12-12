import './scss/main.scss';
import { Main } from './elm/Main.elm';
import registerServiceWorker from './js/registerServiceWorker';
import logoPath from './svg/logo.svg'

console.log(logoPath)

const app = Main.embed(document.getElementById('root'),
  // FLAGS
  {
    "logoPath": logoPath
  }
);

// PORTS
app.ports.measureContent.subscribe(function(msg) {
  window.requestAnimationFrame(function() {
    const container = document.getElementById(msg.containerId);
    const content = document.getElementById(msg.containerId + "-" + msg.contentId);

    if (msg.contentId != "") {
      msg.newHeight = content.offsetHeight;
    } else {
      msg.newHeight = 0;
    }
    if (msg.oldContentId != "") {
      const oldContent = document.getElementById(msg.containerId + "-" + msg.oldContentId);
      msg.oldHeight = oldContent.parentElement.offsetHeight;
    } else {
      msg.oldHeight = 0;
    }
    app.ports.newContentHeight.send(msg)
  })
})

registerServiceWorker();
