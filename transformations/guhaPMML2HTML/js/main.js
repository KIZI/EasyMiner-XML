$(document).ready(function(){
  alert('jo');

  prepareFourFtTables();
});

var prepareRelativeBgColor = function (ratio) {
  //TODO zlepšení výpočtu barev (aby to vypadalo líp ;)
  var x = 255-Math.round(255*ratio);
  return 'rgb(255,'+x+','+x+')';
};

var prepareFourFtTables = function () {
  $('table.fourFtTable').each(function() {
    var tdA = $(this).find('td.a');
    var tdB = $(this).find('td.b');
    var tdC = $(this).find('td.c');
    var tdD = $(this).find('td.d');
    var a = parseInt(tdA.text());
    var b = parseInt(tdB.text());
    var c = parseInt(tdC.text());
    var d = parseInt(tdD.text());
    var sum = a + b + c + d;
    tdA.css('background',prepareRelativeBgColor(a/sum));
    tdB.css('background',prepareRelativeBgColor(b/sum));
    tdC.css('background',prepareRelativeBgColor(c/sum));
    tdD.css('background',prepareRelativeBgColor(d/sum));
  });
};