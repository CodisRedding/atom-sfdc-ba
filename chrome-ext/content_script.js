var port = gup('port');
var resourceDir = gup('rd');
var sessionId = gup('sid');
var apiVersion = gup('api');
var pod = gup('pod');

if (pod) {
  if (validApiVersion()) {
    if (sessionId) {
      sessionId = unescape(sessionId);
      if (!isNaN(port) && (port <= 65535) && (port > 0)) {
        if (resourceDir) {
          getExtensions()
          $("[href*='/resource']").attr('href', setNewValue);
          $("[src*='/resource']").attr('src', setNewValue);
          $("script[src*='/resource']").attr('src', replaceScript);
        } else {
          console.log('invalid resource directory');
        }
      } else {
        console.log('invalid port');
      }
    } else {
      console.log('invalid session');
    }
  } else {
    console.log('invalid api');
  }
} else {
  console.log('invalid pod')
}

function setNewValue(index, attrValue) {
  return ('https://localhost:' + port + '/' + resourceDir + removeResourceNum(attrValue));
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

// returns an array with [resource, ext]
function getExtensions(resources) {
  $.ajax({
    headers: {
      Authorization: "Bearer " + sessionId
    },
    url: "https://" + pod + ".salesforce.com/services/data/" + apiVersion + "/query/?q=SELECT+name+from+Account+LIMIT+1",
    processData: false,
    dataType: "json",
    success: function(json) {
      console.log('json: ', json);
    }
  });
  return null;
}

function validApiVersion() {
  return (apiVersion
      && apiVersion[0] === 'v'
      && apiVersion[3] === '.'
      && apiVersion.length == 5);
}
