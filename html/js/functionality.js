var margin;

function load_element(element){
	get_size();
	document.getElementById('pagina').innerHTML='<div hidden="true" id="prueba">'+margin+'</div><object type="text/html" data="'+element+'.html"></object>';
	
	/*document.getElementById('pagina').innerHTML='<iframe src="'+element+'.html"></iframe>';*/
	/*set_size();*/
} 

$(document).ready(function(){
	/*changes properties of naviagtion menus*/
   $(".menu").click(function(){
       	$('a.selected').removeClass('selected');
        $(this).addClass('selected');        
		}); 
   $(".tabs-style-bar nav ul li").click(function(){
       	$('.tab-current').removeClass('tab-current');
        $(this).addClass('tab-current');        
		}); 

   /*$("#horizontal-nav").on("load", function(){
   		margin = $('#horizontal-nav').css('marginLeft').replace(/[^-\d\.]/g, '');
   		alert('margin1: '+ margin);
   		});

   /*$(window).resize(function(){
   		margin = $('#horizontal-nav').css('marginLeft');
   		alert('margin: '+margin);
		$('#vertical-bar').css("width",margin);
		alert('width: '+$('#vertical-bar').css('width'));
   });*/
   	/*set_size();*/
});

function get_size(){
	margin = $('#horizontal-nav').css('marginLeft').replace(/[^-\d\.]/g, '');
}

function set_size(){
	/*margin = $('#horizontal-nav').css('marginLeft');*/
	alert('margin2: '+ $('#prueba').html());
	$('#vertical-bar').css("width",$('#prueba').text());
}