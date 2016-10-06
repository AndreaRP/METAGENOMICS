var margin;

/*function load_element(element){
	get_size();
	document.getElementById('pagina').innerHTML='<object type="text/html" data="'+element+'.html"></object>';	
	/*document.getElementById('pagina').innerHTML='<iframe src="'+element+'.html"></iframe>';*/
	/*set_size();
} */

$(document).ready(function(){
	/*changes properties of naviagtion menus*/
    set_size();

   $(".menu").click(function(){
       	$('a.selected').removeClass('selected');
        $(this).addClass('selected');        
		}); 
   $(".tabs-style-bar nav ul li").click(function(){
       	$('.tab-current').removeClass('tab-current');
        $(this).addClass('tab-current');        
		}); 
   $(window).resize(function(){
      set_size();
      
   	});
});

function set_size(){
  if($(window).width() > 1350) {
        margin = $('#horizontal-nav').css('marginLeft').replace(/[^-\d\.]/g, '');
        $('.vertical-nav').css("width", margin);
      }else{
          $('.vertical-nav').css("width", 80);
      }

}