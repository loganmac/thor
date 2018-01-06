import './scss/main.scss';
import { Main } from './elm/Main.elm';
import registerServiceWorker from './js/registerServiceWorker';
import logoPath from './svg/logo.svg'
import homeLogoPath from './svg/home.svg'
import supportLogoPath from './svg/support.svg'


const app = Main.embed(document.getElementById('root'),
  // FLAGS
  {
    "session": localStorage.session || null,
    "logoPath": logoPath,
    "homeLogoPath": homeLogoPath,
    "supportLogoPath": supportLogoPath
  }
);

app.ports.storeSession.subscribe(function(session) {
  localStorage.session = session;
});

window.addEventListener("storage", function(event) {
  if (event.storageArea === localStorage && event.key === "session") {
    app.ports.onSessionChange.send(event.newValue);
  }
}, false);


// PORTS
app.ports.measureContent.subscribe(function(msg) {
  window.requestAnimationFrame(function() {
    let containerId = msg.containerId;
    let contentId = containerId + "-" + msg.contentId;
    let oldContentId = containerId + "-" + msg.oldContentId;
    let container = document.getElementById(containerId);
    let content = document.getElementById(contentId);
    if (msg.contentId != "") {
      msg.newHeight = content.offsetHeight;
    } else {
      msg.newHeight = 0;
    }
    if (msg.oldContentId != "") {
      let oldContent = document.getElementById(oldContentId);
      msg.oldHeight = oldContent.parentElement.offsetHeight;
    } else {
      msg.oldHeight = 0;
    }
    app.ports.newContentHeight.send(msg);
  });
});

registerServiceWorker();
