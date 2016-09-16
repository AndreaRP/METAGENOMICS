function load_element(element){
	document.getElementById('pagina').innerHTML='<object class ="full" type="text/html" data="'+element+'.html"></object>';
} 

$(document).ready(function(){
   $(".menu").click(function(){
       	$('a.selected').removeClass('selected');
        $(this).addClass('selected');        
		}); 
   $(".tabs-style-bar nav ul li").click(function(){
       	$('.tab-current').removeClass('tab-current');
        $(this).addClass('tab-current');        
		}); 
});