import './scss/main.scss';
import { Main } from './elm/Main.elm';
import registerServiceWorker from './js/registerServiceWorker';
import logoPath from './svg/logo.svg';
import homeLogoPath from './svg/home.svg';
import supportLogoPath from './svg/support.svg';
// LEGACY
// new app
import './scss/legacy.scss'
import './legacy/new_app/legacy';
import newApp from './legacy/newApp';
// globals for new app
import 'sequin';
import 'script-loader!jquery';
import 'script-loader!lexi/rel/app';
import 'script-loader!./legacy/new_app/legacy.js';
import 'script-loader!shadow-icons/rel/app';
import 'script-loader!jade/runtime';

import './legacy/provider_manager/legacy';
import providerManager from './legacy/providerManager';

const app = Main.embed(document.getElementById('root'),
  // FLAGS
  {
    "session": localStorage.session || null,
    "logoPath": logoPath,
    "homeLogoPath": homeLogoPath,
    "supportLogoPath": supportLogoPath
  }
);

// PORTS

// SESSION MANAGMENT
app.ports.storeSession.subscribe(function(session) {
  localStorage.session = session;
});

window.addEventListener("storage", function(event) {
  if (event.storageArea === localStorage && event.key === "session") {
    app.ports.onSessionChange.send(event.newValue);
  }
}, false);


// DYNAMIC CONTAINER
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


// LEGACY

app.ports.newApp.subscribe(function(msg){
  console.log(msg);
  newApp(msg);
})




// PROGRESSIVE WEB APP SERVICE WORKER

registerServiceWorker();
