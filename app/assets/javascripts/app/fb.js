// when document loads
$(document).ready(function () {
    // main function
    window.fbAsyncInit = function() {
        FB.init({
            appId   : '661467927263006',
            xfbml   : true,
            version : 'v2.0',
            status  : true
        });


        $("#fb_gift").on('click', function() {
            FB.login(function(res) {console.log(res);});
            FB.getLoginStatus(function(response) {
                console.log(response);
                if (response.status === 'connected') {
                    console.log('Logged into your app and Facebook.');
                    renderMFS();
                } else if (response.status === 'not_authorized') {
                    console.log('The person is logged into Facebook, but not your app.');
                } else {
                    console.log("The person is not logged into Facebook, so we're not sure if they are logged into this app or not.");
                    FB.login();
                }
            });
        });

        $("#fb_login").on('click', function() {
            FB.login(function(res) {console.log(res);});
        });

        $("#fb_logout").on('click', function() {
            FB.logout();
        });

        //renderMFS();
    };

    // auto executing => load sdk.js
    (function(d, s, id){
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) {return;}
        js = d.createElement(s); js.id = id;
        js.src = "//connect.facebook.net/en_US/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));



});

function renderMFS() {
    FB.api('/me/invitable_friends', function(response) {
        console.log(response);
        var container = document.getElementById('mfs');
        $("#mfs").empty();
        var mfsForm = document.createElement('form');

        mfsForm.id = 'mfsForm';
        // Iterate through the array of friends object and create a checkbox for each one.
        for(var i = 0; i < Math.min(response.data.length, 10); i++) {
            var friendItem = document.createElement('tr');
            friendItem.id = 'friend_' + response.data[i].id;
//            friendItem.style= ''
            friendItem.innerHTML = '<td style="margin-top: 10px; margin-right: 5px;margin-bottom: 3px;"><input type="checkbox" name="friends" value="'
                + response.data[i].id + '" /></td><td  style="margin-top: 10px; margin-right: 5px;margin-bottom: 3px;">' + response.data[i].name + '</td><td  style="margin-top: 10px; margin-right: 5px;margin-bottom: 3px;"><img width="30" height="30" src="'+ response.data[i].picture.data.url+ '"/></td>  ' ;
            mfsForm.appendChild(friendItem);
        }
        container.appendChild(mfsForm);
        // Create a button to send the Request(s)
        var sendButton = document.createElement('input');
        sendButton.type = 'button';
        sendButton.value = 'Send Request';
        sendButton.onclick = sendRequest;
//        mfsForm.appendChild(sendButton);
        $("#btn_send_koins").click(function(e) {
            sendRequest();
        });
    });
}


function sendRequest() {
    // Get the list of selected friends
    var sendUIDs = '';
    var mfsForm = document.getElementById('mfsForm');
    for(var i = 0; i < mfsForm.friends.length; i++) {
        if(mfsForm.friends[i].checked) {
            sendUIDs += mfsForm.friends[i].value + ',';
        }
    }
    // Use FB.ui to send the Request(s)
    FB.ui({
            method: 'feed',
            name: 'I made a rain of Koins for you',
            caption: 'via Koinify',
            message: 'Alex Chong Lian',
            description: ('Watch out for Koins! Check it out if you are one of them'),
            link: 'http://0.0.0.0:3000/en/sign_up_rewards',
            picture: 'http://everyonelookbusy.files.wordpress.com/2011/03/coin-rain.jpg'
        },

        function (response) {
            if (response && response.post_id) {
//                alert('Post was published.');
                $("#giftFriendModal").modal("hide");
            } else {
                $("#giftFriendModal").modal("hide");
            }
        });
 }

function callback(response) {
    console.log(response);
}