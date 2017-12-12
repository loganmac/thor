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

    if (msg.fadeContentId != "") {
      const fadeOutContent = document.getElementById(msg.containerId + "-" + msg.fadeContentId);
      msg.oldHeight = fadeOutContent.parentElement.offsetHeight;
    } else {
      msg.oldHeight = 0;
    }
    msg.newHeight = content.offsetHeight;
    app.ports.newContentHeight.send(msg)
  })
})

registerServiceWorker();
