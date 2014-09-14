var current = '-on';

function updateIcon() {
  chrome.browserAction.setIcon({path:"icon" + current + ".png"});

  if (current === '-on')
    current = '-off';
  else
    current = '-on';
}

chrome.browserAction.onClicked.addListener(updateIcon);
updateIcon();
