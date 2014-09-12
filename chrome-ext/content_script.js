$("[href*='/resource']").attr('href', setNewValue);
$("[src*='/resource']").attr('src', setNewValue);
$("script[src*='/resource']").attr('src', displayValue);

console.log($(location).attr('search'));

function setNewValue(index, attrValue) {
  return ('https://localhost:8000' + attrValue);
}

function displayValue(index, attrValue) {
  console.log(index + ' ' + attrValue);
}
