import './scss/main.scss';
import { Main } from './elm/Main.elm';
import registerServiceWorker from './js/registerServiceWorker';
import logoPath from './svg/logo.svg'


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
    const containerBorderHeight = parseInt(getComputedStyle(container).getPropertyValue('border-top-width'), 10);
    const tab = document.getElementById(msg.containerId + "-" + msg.contentId);
    const tabHeight = tab.offsetHeight;
    msg.newHeight = tabHeight;
    app.ports.newContentHeight.send(msg)
  })
})

registerServiceWorker();
