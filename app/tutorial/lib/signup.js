//jQuery time
var current_fs, next_fs, previous_fs; //fieldsets
var left, opacity, scale; //fieldset properties which we will animate
var animating; //flag to prevent quick multi-click glitches

$(".next").click(function(){
	if(animating) return false;
	animating = true;
	
	current_fs = $(this).parent();
	next_fs = $(this).parent().next();
	
	//activate next step on progressbar using the index of next_fs
	$("#progressbar li").eq($("fieldset").index(next_fs)).addClass("active");
	
	//show the next fieldset
	next_fs.show(); 
	//hide the current fieldset with style
	current_fs.animate({opacity: 0}, {
		step: function(now, mx) {
			//as the opacity of current_fs reduces to 0 - stored in "now"
			//1. scale current_fs down to 80%
			scale = 1 - (1 - now) * 0.2;
			//2. bring next_fs from the right(50%)
			left = (now * 50)+"%";
			//3. increase opacity of next_fs to 1 as it moves in
			opacity = 1 - now;
			current_fs.css({'transform': 'scale('+scale+')'});
			next_fs.css({'left': left, 'opacity': opacity});
		}, 
		duration: 800, 
		complete: function(){
			current_fs.hide();
			animating = false;
		}, 
		//this comes from the custom easing plugin
		easing: 'easeInOutBack'
	});
});

$(".previous").click(function(){
	if(animating) return false;
	animating = true;
	
	current_fs = $(this).parent();
	previous_fs = $(this).parent().prev();
	
	//de-activate current step on progressbar
	$("#progressbar li").eq($("fieldset").index(current_fs)).removeClass("active");
	
	//show the previous fieldset
	previous_fs.show(); 
	//hide the current fieldset with style
	current_fs.animate({opacity: 0}, {
		step: function(now, mx) {
			//as the opacity of current_fs reduces to 0 - stored in "now"
			//1. scale previous_fs from 80% to 100%
			scale = 0.8 + (1 - now) * 0.2;
			//2. take current_fs to the right(50%) - from 0%
			left = ((1-now) * 50)+"%";
			//3. increase opacity of previous_fs to 1 as it moves in
			opacity = 1 - now;
			current_fs.css({'left': left});
			previous_fs.css({'transform': 'scale('+scale+')', 'opacity': opacity});
		}, 
		duration: 800, 
		complete: function(){
			current_fs.hide();
			animating = false;
		}, 
		//this comes from the custom easing plugin
		easing: 'easeInOutBack'
	});
});

$(".submit").click(function(){
	return false;
});

//$( "#draggable" ).draggable();
$( "#draggable" ).draggable({ axis: "x", containment: "parent" });
$( "#dialog" ).dialog({ autoOpen: false });
$( "#dialog" ).dialog( "option", "modal", true );
$( "#dialog" ).dialog({
	dialogClass: "no-close",
	buttons: [
	{
		text: "OK",
		click: function() {
			$( this ).dialog( "close" );
			 $('#getkoinNextButton').attr("disabled", false);
			 $('.coin-text').html(500);
			 $('.coin-text').val(500);

		}
	}
	]
});
$( "#droppable" ).droppable({
	drop: function() {
		$( "#dialog" ).dialog( "open" );
		$( "#draggable" ).draggable({ disabled: true });
	}
});

$( "#selectable" ).selectable();
$(".image-picker").imagepicker();
$('.topic').upvote();

/*
$('#giftbox').on({
    'click': function(){
        $('#giftbox').attr('src','giftbox-close.png');
		$( "#dialog" ).dialog( "open" );
    }
}); */

$('.claim-button').on({
    'click': function(){
    	$('#giftbox').fadeOut(500);
		$( "#giftbox" ).promise().done(function() {
    		$('#giftbox').attr('src','lib/images/star.png').fadeIn(1500);
		//	$('#big-coin').fadeIn(1).fadeOut(1500);
		//	$('#small-coin').delay(1).fadeIn(1500);
			$('#coin-text').delay(1).fadeIn(1500);
			$('#coin-statement').text('You just claimed 500 free Koins').fadeIn(1500);
			$(".claim-button").hide();
  		});
	//	$(this).unbind('click').attr('disabled', 'disabled');
	//	$('#getkoinNextButton').attr("disabled", false);
    }
});
