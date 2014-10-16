jQuery(function($){
	'use strict';
	
	// ------------------------
	//   Centered Navigation
	// ------------------------
	(function () {
		var $frame = $('#centered');
		var $wrap  = $frame.parent();

		// Call Sly on frame
		$frame.sly({
			horizontal: 1,
			itemNav: 'centered',
			smart: 1,
			activateOn: 'click',
			mouseDragging: 1,
			touchDragging: 1,
			releaseSwing: 1,
			startAt: 0,
			scrollBar: $wrap.find('.scrollbar'),
			scrollBy: 1,
			speed: 300,
			elasticBounds: 1,
			easing: 'easeOutExpo',
			dragHandle: 1,
			dynamicHandle: 1,
			clickBar: 1,

			// Buttons
			prev: $wrap.find('.prev'),
			next: $wrap.find('.next')
		});
	}());
	
	// -------------------------------------------------------------
	//   3D Effects
	// -------------------------------------------------------------
	/*	
	(function () {
		var $frame = $('#effects');
		var $wrap  = $frame.parent();

		// Call Sly on frame
		$frame.sly({
			horizontal: 1,
			itemNav: 'forceCentered',
			smart: 1,
			activateMiddle: 1,
			activateOn: 'click',
			mouseDragging: 1,
			touchDragging: 1,
			releaseSwing: 1,
			startAt: 3,
			scrollBar: $wrap.find('.scrollbar'),
			scrollBy: 1,
			speed: 300,
			elasticBounds: 1,
			easing: 'swing',
			dragHandle: 1,
			dynamicHandle: 1,
			clickBar: 1,

			// Buttons
			prev: $wrap.find('.prev'),
			next: $wrap.find('.next')
		});
	}());
	*/



	$('.toggle_sidebar').on('click',  function() {
		$('.sidebar').toggle();
	});


    var userIdElement = $("#user_id");
    var userId = -1;
    var userCpKey = "";
    if (userIdElement && userIdElement.size() > 0) {
        userId = userIdElement[0].attributes["data-user-id"].value;
        userCpKey = userIdElement[0].attributes["data-private-key"].value;
    }





    $('.coinButton').on('click', function(i) {
    	$('#project_image').attr('src' , $('img', this).attr('src'));
        console.log(i.target.id)
        updateCoinInfo(i.target.id, userId);
    });

	$('.usercoin_content').hide();
    $('#project_about').summernote();

	var rainfall = $('.usercoin_content_rainfall');
	var purchase = $('.usercoin_content_purchase');

	/*
	 * define the priority of showing various tabs
	 * 
	 * purchase > rainfall > redeem > trade
	 * 
	 * if the purchase tab exist, show purchase first
	 * them if the rainfall tab exist, show rainfall tab
	 */
	if (purchase.length) {
		$('.usercoin_content_purchase').show();
	} else if (rainfall.length){
		$('.usercoin_content_rainfall').show();
	}
	

	$('.usercoin_tab').on('click', function() {
		$('.usercoin_tab').removeClass('usercoin_tab_active').addClass('usercoin_tab_inactive');
		$(this).removeClass('usercoin_tab_inactive').addClass('usercoin_tab_active');
	});

	$('.usercoin_tab_purchase').on('click', function() {
		$('.usercoin_content').hide();
		$('.usercoin_content_purchase').show();
	});

	$('.usercoin_tab_rainfall').on('click', function() {
		$('.usercoin_content').hide();
		$('.usercoin_content_rainfall').show();
	});

	$('.usercoin_tab_redeem').on('click', function() {
		$('.usercoin_content').hide();
		$('.usercoin_content_redeem').show();
	});

	$('.usercoin_tab_trade').on('click', function() {
		$('.usercoin_content').hide();
		$('.usercoin_content_trade').show();
		window.open('http://testnet.counterwallet.co', '_blank');
	});

	$('.usercoin_tab_gift').on('click', function() {
		$('.usercoin_content').hide();
		$('.usercoin_content_gift').show();
	});


    $('#l_mykoins').on('click', function() {
        switchTab("mykoins");
    });

    $('#l_allkoins').on('click', function() {
        switchTab("allkoins");
    });
    $('#l_headlines').on('click', function() {
        switchTab("headlines");
    });

    switchTab("mykoins");


    $(document).on('click', 'input.btn-primary', function(){
        var ids = new Array();
        $('.coin_power_li input[type=checkbox]:checked').each(function(){
            ids.push(this.value);
        });
        $.ajax({
            type: "post",
            url: "/api/redeem.json",
            data: {coin_power_ids:ids,
                account: $('#account_input').val()
            }
        }).done(
            function(r){
                var error = r.error
                if (error == 0)
                    alert("Successful!")
                else
                    alert("Unsuccessful!")
            }
        );
    });


    $('#project_submit').on('click', function() {
        var sHTML = $('.summernote').code();
        $('#project_form').append("<input type='hidden' value='" + sHTML + "'>");
        $('#project_form').submit();

    });

    $('.popup').click(function(event) {
        var width  = 575,
            height = 400,
            left   = ($(window).width()  - width)  / 2,
            top    = ($(window).height() - height) / 2,
            url    = this.href,
            opts   = 'status=1' +
                ',width='  + width  +
                ',height=' + height +
                ',top='    + top    +
                ',left='   + left;

        window.open(url, 'twitter', opts);

        return false;
    });

    var coinId = $("#coin_id");
    if (coinId && coinId.size() > 0)
        coinId = coinId[0].attributes["data-coin-id"].value;

    var handleCoinUpdate =function(id) {
        getUserCoin(id, userId, function(c) {
            var coin = c.coin;
            var usercoin = c.usercoin;
            var powers = c.powers;
            $("#koin_title").text(coin.name);

            $("#koin_quantity").text(usercoin[0].amount);
            $("#koin_powers").empty();
            for (i = 0; i < powers.length; i++)
                $("#koin_powers").append("<div class='input-group'><input type='checkbox'>" + powers[i].name +  " (Cost: " + powers[i].cost + ")</input></div>");
        });
    };
    handleCoinUpdate($(".coinbar-group-item")[0].id);

    $('.coinbar-group-item').on('click', function(e) {
//        e.target.addClass("active");
        handleCoinUpdate(e.target.id);
    });

    $('#private_key').on('click', function(e) {
        var t = $("#private_key");
        if (t.hasClass("shown")) {
            t.text("Reveal private key");
//            t.empty();
            t.toggleClass("shown");
        } else {
            t.text("Hide");
            t.append("<input type='text' value='" + userCpKey + "'>");
            t.toggleClass("shown");
        }
    });

    if (userId && coinId && userId.size > 0 &&  coinId.size > 0)
        updateCoinInfo(coinId[0].attributes["data-coin-id"].value, userId);

    /* Override default collapsing behavior */
    /// TBD


});

var pkShown = false;


var tabs = ["mykoins", "allkoins", "headlines"];

function switchTab(to) {
    for ( i = 0; i < tabs.length;i++) {

        if (tabs[i] != (to)) {
            $("#" + tabs[i]).hide();
            $("#l_" + tabs[i]).removeClass("active");
        } else {
            $("#" + tabs[i]).show();
            $("#l_" + tabs[i]).addClass("active");
        }
    }
}


function getUserCoin(coinId, userId,  f) {
    $.ajax({
        url: "http://localhost:3000/en/coins/" + coinId + "/find.json?user_id=" + userId
    })
        .done(function (resp) {
            console.log(resp);
            coin = resp.coin;
            usercoin = resp.usercoin;
            powers = resp.powers;
            features = resp.features;
            if (console && console.log) {
                console.log(window.features);
            }
            if (f) {
                return f(resp);
            }
            return resp;
        });
}



function updateCoinInfo(coinId, userId) {
    $.ajax({
        url: "http://localhost:3000/en/coins/" + coinId + "/find.json?user_id=" + userId
    })
        .done(function (resp) {
        	console.log(resp);
            coin = resp.coin;
            usercoin = resp.usercoin;
            powers = resp.powers;
            features = resp.features;
            if (console && console.log) {
                console.log(window.features);
            }

            $("#coin_title").text(coin.name);
            $(".coin_power_ul").empty();
            $("#redeem_power").empty();
            //features.forEach(function(f) {
              //  $(".coin_power_ul").append("<li style='margin-top: 5px;' class='list-group-item coin_power_li'><input type='checkbox' name='redeem_feature' value=" + f.id + ">" +  f.name +  " : $" + f.requirement + "</input></li>");
            //});
            powers.forEach(function(f) {
                // $(".coin_power_ul").append("<li style='margin-top: 5px;' class='list-group-item coin_power_li'>" + f.name +  " @" + f.cost + "");
                $(".coin_power_ul").append(
                        "<li  style='margin-top: 5px;' class='list-group-item coin_power_li'> <input type='checkbox' name='redeem_power' value=" + f.id + ">" +
                    f.name +  " @" + f.cost +  "</input></li>");
            });

            if (powers) {
            	$(".coin_power_ul").append("<label for='account_input' class='label-default'>Account:<label/><input id='account_input' type='text' class='form-control' />").append("<input class='btn btn-primary' type='submit' value='redeem'> ");
            }

            $("#tweet").empty();
            tweetButton =  "<center><a class='twitter btn btn-primary popup' href='http://twitter.com/share?text=I%20love%20" + coin.name + ".%20Retweet%20this%20msg.%20%23Koinify'>Tweet</a></center>"
            $("#tweet").append(tweetButton);
        });
}


