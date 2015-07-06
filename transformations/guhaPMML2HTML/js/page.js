/**
 * JavaScript pro zobrazení výsledku transformace v podobě standalone stránky
 */

$(document).ready(function(){
  var navigationElement=$('section#navigation');
  var navigationElementTop=navigationElement.offset().top-20;

  $('section#navigation a[href^="#"]').click(function(event){
    var elementId=$(this).attr('href');
    var element=$(elementId);
    if (element){
      event.preventDefault();
      navigationElement.addClass('onTop');
      $(window).scrollTop(element.position().top);
    }
  });

  var solveNavigationPosition = function(){
    if ($(document).scrollTop()>navigationElementTop){
      navigationElement.addClass('onTop');
    }else{
      navigationElement.removeClass('onTop');
    }
  };

  solveNavigationPosition();

  $(window).scroll(function(){
    solveNavigationPosition();
  });
});

