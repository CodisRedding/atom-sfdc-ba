var port = gup('port');
if (!isNaN(port) && (port <= 65535) && (port > 0)) {
  $("[href*='/resource']").attr('href', setNewValue);
  $("[src*='/resource']").attr('src', setNewValue);
  $("script[src*='/resource']").attr('src', replaceScript);
} else {
  console.log('invalid port');
}

function setNewValue(index, attrValue) {
  return ('https://localhost:' + port + '/resource-bundles' + removeResourceNum(attrValue));
}

function replaceScript(index, attrValue) {
  if (attrValue.indexOf('localhost:') >= 0) {
    $("script[src*='" + attrValue + "']").replaceWith('<script src="'
      + removeResourceNum(attrValue) + '.js" type="text/javascript">');
    return;
  }
}

function removeResourceNum(path) {
  // \/resource\/\d*\/
  var regexS = "\\\/resource\\\/(\\\d*\\\/)";
  var regex = new RegExp(regexS);
  var result = regex.exec(path);
  if (result === null) {
    return path;
  } else {
    return path.replace(result[0], '/resource/');
  }
}

function gup(name) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.href);
  if (results == null)
    return null;
  else
    return results[1];
}
