$(document).ready(function(){
  prepareFourFtTables();
  prepareGraphTables();
  prepareCollapsableSections();
});


var prepareCollapsableSections = function(){
  var sectionH3s = $('section h3');
  sectionH3s.click(function(){
    $(this).parent('section').toggleClass('collapsed');
  });
  sectionH3s.css('cursor','pointer');

  prepareFoundRuleCollapsableDetails();
  $('section#sect5 section.foundRule').addClass('collapsed');
};

/**
 * Funkce pro přípravu detailů o nalezených pravidlech
 */
var prepareFoundRuleCollapsableDetails = function(){
  var foundRulesCounter=1;
  $('section#sect5 section.foundRule').each(function(){
    var h3 = $(this).find('h3');
    //příprava jednoduchých detailů nalezeného pravidla, které se zobrazí, pokud je daná sekce sbalená
    var imValuesTable = $(this).find('table.imValuesTable');
    if (imValuesTable){
      var ruleDetailsStr="";
      imValuesTable.find('tr').each(function(){
        var name = $(this).find('td.name').text().trim();
        var value = $(this).find('td.value').text().trim();
        if (name!=''){
          if (ruleDetailsStr!=""){
            ruleDetailsStr+=", ";
          }
          ruleDetailsStr+=name+': '+value;
        }
      });
      h3.after('<div class="ruleSimpleDetails">'+ruleDetailsStr+'</div>');
    }
    h3.append('<span class="counter">#'+foundRulesCounter+'</span>');
    foundRulesCounter++;
  });

  //region odkazy pro hromadné (roz)balení všech detailů
  var rulesCount=$('section#sect5 .foundRulesCount');
  var multiCollapsers=$('<div class="multiCollapsers"></div>');
  var uncollapseAllLink=$('<a href="" class="uncollapse">uncollapse all</a>').click(function(e){e.preventDefault();$('section#sect5 section.foundRule').removeClass('collapsed');});
  var collapseAllLink=$('<a href="" class="collapse">collapse all</a>').click(function(e){e.preventDefault();$('section#sect5 section.foundRule').addClass('collapsed');});
  multiCollapsers.append(uncollapseAllLink, collapseAllLink);
  rulesCount.after(multiCollapsers);
  //endregion odkazy pro hromadné (roz)balení všech detailů
};

/**
 * Funkce pro přiřazení barevných grafů k buňkám čtyřpolních tabulek
 */
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
    tdA.addClass('bg'+Math.round(a*100/sum)+'p');
    tdB.addClass('bg'+Math.round(b*100/sum)+'p');
    tdC.addClass('bg'+Math.round(c*100/sum)+'p');
    tdD.addClass('bg'+Math.round(d*100/sum)+'p');
  });
};

var prepareGraphTables = function(){
  $('table.graphTable').each(function(){
    generateTdGraphsForGraphTable($(this));
    generateGraphForGraphTable($(this).attr('id'));
  });
  //TODO zvážit, jestli to negenerovat zvlášť po kliknutí na odkaz...
};

var generateTdGraphsForGraphTable = function(table){
  //region calculate total count of frequencies
  var frequenciesSum=0;
  var TDs=table.find('td.frequency');
  TDs.each(function(){
    var value=$(this).text();
    if (!isNaN(value)){
      frequenciesSum+=parseInt(value);
    }
  });
  if (frequenciesSum==0){return;}
  //add classes to each td.frequency
  TDs.each(function () {
    var value=$(this).text();
    if (!isNaN(value)){
      value=Math.round(parseInt(value)*100/frequenciesSum);
      $(this).addClass('bg'+value+'p');
    }
  });
};

var generateGraphForGraphTable = function(id){
  var table = $('#'+id);
  table.after('<canvas id="'+id+'-graph"></canvas>');

  var labelsArr = [];
  var dataArr = [];

  table.find('tr').each(function(){
    //zpracujeme všechny jednotlivé řádky
    var name = $(this).find('.name').text();
    if (!name){return;}
    var frequency = $(this).find('.frequency').text();
    if (!frequency){return;}
    labelsArr.push(name);
    dataArr.push(parseInt(frequency));
  });

  var barChartData = {
    labels: labelsArr,
    datasets: [
      {
        label: "label",
        backgroundColor: "rgba(220,220,220,0.5)",
        data: dataArr
      }
    ]
  };

  var ctx = document.getElementById(id+"-graph").getContext("2d");
  new Chart(ctx).Bar({
    data: barChartData,
    options: {
      responsive: false
    }
  });

};