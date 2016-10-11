var margin;


$(document).ready(function(){
	/*changes properties of naviagtion menus*/
    set_size();
    //set_color();
   $(".menu").click(function(){
      // Change style of the selected sample
       	$('a.selected').removeClass('selected');
        $(this).addClass('selected');  
		}); 
   $(".tabs-style-bar nav ul li").click(function(){
       	$('.tab-current').removeClass('tab-current');
        $(this).addClass('tab-current');      
		}); 
   $(".vertical-nav nav ul li ul li a").click(function(){
           // loads the corresponding result page 
        //get organism and sample 
        var organism=($(this).text().toLowerCase()); 
        var sample=$(this).parent().parent().parent().find('span#sample').text().toLowerCase();
        load_result('C1','bacteria');
        //load_result(sample,organism);  
    });
   $(window).resize(function(){
      set_size();
      
   	});
});

function set_size(){
  // Horizontal and vertical nav behaviour
  if($(window).width() > 1350) {
        margin = $('#horizontal-nav').css('marginLeft').replace(/[^-\d\.]/g, '');
        $('.vertical-nav').css("width", margin);
        //$('.results').css(width, $(window).width()-margin);
      }else{
          $('.vertical-nav').css("width", 80);
          //$('.results').css(width, $(window).width()-margin);
      }
  $('.results').css("width", $(window).width()- parseInt(margin) - 3);

  // 2nd level responsive behaviour. We change the class so the css
  //can change it
  if($('.vertical-nav').width() < 155){
    $('.submenu li a span').css("float", "none");
    //$('.submenu li a span').addClass('mobile');
  }else{
    $('.submenu li a span').css("float", "right");
    //$('.submenu li a span').removeClass('mobile');
  }
}

function load_result(sample, organism){
  $(".results").attr("data", "data/"+sample+"_"+organism+"_results.html");
}
