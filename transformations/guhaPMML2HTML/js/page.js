/**
 * JavaScript pro zobrazení výsledku transformace v podobě standalone stránky
 */

$(document).ready(function(){
  var navigationElement=$('section#navigation');
  var navigationElementTop=navigationElement.offset().top-20;
  if ($(document).scrollTop()>navigationElementTop){
    navigationElement.addClass('onTop');
  }

  $(window).scroll(function(){
    if ($(document).scrollTop()>navigationElementTop){
      navigationElement.addClass('onTop');
    }else{
      navigationElement.removeClass('onTop');
    }
  });
});

