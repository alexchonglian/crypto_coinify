//helper functions for navigation
function show1() {
  $('#create_campaign_form_2').hide();
  $('#create_campaign_form_3').hide();
  $('#create_campaign_form_4').hide();
  $('#create_campaign_form_1').show();

    $('.goto1').addClass("active");
    $('.goto2').removeClass("active");
    $('.goto3').removeClass("active");
unlock(1);
}

function show2() {
  $('#create_campaign_form_1').hide();
  $('#create_campaign_form_3').hide();
  $('#create_campaign_form_4').hide();
  $('#create_campaign_form_2').show();


    $('.goto2').addClass("active");
    $('.goto1').removeClass("active");
    $('.goto3').removeClass("active");



}

function show3() {
  $('#create_campaign_form_1').hide();
  $('#create_campaign_form_2').hide();
  $('#create_campaign_form_4').hide();
  $('#create_campaign_form_3').show();

    $('.goto3').addClass("active");
    $('.goto1').removeClass("active");
    $('.goto2').removeClass("active");
}

function show4() {
  $('#create_campaign_form_1').hide();
  $('#create_campaign_form_2').hide();
  $('#create_campaign_form_3').hide();
  $('#create_campaign_form_4').show();
}

//helper function for enable [next] [previous] button

function unlock(pagenumber) {
    console.log("unlock");

}



// the starting point that load the web pages 
$(document).ready(function() {
  // show page 1
  show1();
  unlock(1);




    $("#addPower").on("click", function (f) {

        prefilled = "Koin power @ cost";
        index = ($("input[id*='koin_powers']").length+1);
        $(".powers").append("<div class='row'><div class='col-sm-6 col-sm-offset-2'> <input type='text' name='project[koin_powers_" + index  + "]' id='project_koin_powers_" + index + "' class='form-control' placeholder='" + prefilled + "'/></div></div>");
    });


  // bind the callback of [next] [previous] button
  $('.goto1').on('click', function() { show1() });
  $('.goto2').on('click', function() { show2() });
  $('.goto3').on('click', function() { show3() });
  $('.goto3').on('click', function() { show3() });

  // disable the submit button and only enable it after completion
//  $('#project_submit').hide();
  //$('.bootstrap-alert').hide();












    /*
     * a new iteration of validation
     */

    var valid_koinname   = false,
        valid_headline   = false,
        valid_goal       = false;


    $('.warn').css('color', 'red').hide();

    $('.goto2').attr('disabled', 'disabled');
    $('.goto3').attr('disabled', 'disabled');
    $('#project_submit').attr('disabled', 'disabled');




    /*
     * validation for koin name
     *
     */
    $('.input_koinname').on('keyup', function() {
        var valkoinname = $(this).val();
        //console.log(valkoinname);
        // 1.Validation
        // 2.Set valid_koinname
        var letters = /^[a-zA-Z]+$/

        if (valkoinname.match(letters) && valkoinname.length > 0) {
            valid_koinname = true;
        } else {
            valid_koinname = false;
        }

        if (valid_koinname && valid_headline) {
            $('.goto2').removeAttr('disabled');
        } else {
            $('.goto2').attr('disabled', 'disabled');
        }
    });

    $('.input_koinname').on('blur', function () {
        var valkoinname = $(this).val();
        //console.log(valkoinname);
        // 1.Validation
        // 2.Set valid_koinname
        var letters = /^[a-zA-Z]+$/

        if (valkoinname.match(letters) && valkoinname.length > 0) {
            valid_koinname = true;
        } else {
            valid_koinname = false;
        }

        if (valid_koinname && valid_headline) {
            $('.goto2').removeAttr('disabled');
        } else {
            $('.goto2').attr('disabled', 'disabled');
        }

        if (valid_koinname) {
            // 1.show error msg
            // 2.addClass has-error
            $('.warn-koinname').hide();
            $('.col-sm-4').removeClass('has-error');
        } else {
            // 1.hide error msg
            // 2.removeClass has-error
            $('.warn-koinname').show();
            $('.col-sm-4').addClass('has-error');
        }
    });




    /*
     * validation for headline
     *
     */
    $('.input_headline').on('keyup', function() {
        var valheadline = $(this).val();
        console.log(valheadline);
        // 1.Validation
        // 2.Set valid_koinname

        if (valheadline.length > 0 && valheadline.length < 140) {
            valid_headline = true;
        } else {
            valid_headline = false;
        }

        if (valid_koinname && valid_headline) {
            $('.goto2').removeAttr('disabled');
        } else {
//            $('.goto2').attr('disabled', 'disabled');
        }
    });

    $('.input_headline').on('blur', function () {
        var valheadline = $(this).val();
        console.log(valheadline);
        // 1.Validation
        // 2.Set valid_koinname

        if (valheadline.length > 0 && valheadline.length < 140) {
            valid_headline = true;
        } else {
            valid_headline = false;
        }

        if (valid_koinname && valid_headline) {
            $('.goto2').removeAttr('disabled');
        } else {
            $('.goto2').attr('disabled', 'disabled');
        }

        if (valid_headline) {
            // 1.show error msg
            // 2.addClass has-error
            $('.warn-headline').hide();
            $('.col-sm-8').removeClass('has-error');
        } else {
            // 1.hide error msg
            // 2.removeClass has-error
            $('.warn-headline').show();
            $('.col-sm-8').addClass('has-error');
        }
    });



    /*
     * validation for goal
     *
     */
    $('.input_goal').on('keyup', function() {
        var valgoal = $(this).val();
        console.log(valgoal);
        // 1.Validation
        // 2.Set valid_koinname
        if (!isNaN(valgoal) && valgoal.length > 0) {
            valid_goal = true
        } else {
            valid_goal = false;
        }

        if (valid_koinname && valid_headline && valid_goal) {
            $('.goto3').removeAttr('disabled');
            $('#project_submit').removeAttr('disabled');
        } else {
//            $('.goto3').attr('disabled', 'disabled');
//            $('#project_submit').attr('disabled', 'disabled');
        }

    });

    $('.input_goal').on('blur', function () {
        var valgoal = $(this).val();
        console.log(valgoal);
        // 1.Validation
        // 2.Set valid_koinname
        if (!isNaN(valgoal) && valgoal.length > 0) {
            valid_goal = true
        } else {
            valid_goal = false;
        }

        if (valid_koinname && valid_headline && valid_goal) {
            $('.goto3').removeAttr('disabled');
            $('#project_submit').removeAttr('disabled');
        } else {
//            $('.goto3').attr('disabled', 'disabled');
//            $('#project_submit').attr('disabled', 'disabled');
        }


        if (valid_goal) {
            // 1.show error msg
            // 2.addClass has-error
            $('.warn-goal').hide();
            $('.col-sm-2').removeClass('has-error');

        } else {
            // 1.hide error msg
            // 2.removeClass has-error
            $('.warn-goal').show();
            $('.col-sm-2').addClass('has-error');
        }
    });





});
