/**
 * Created by john on 6/22/14.
 */
(function($){
    $.ajax({
        url: "/api/get_coin_info.json"
    }).done(function(res){
        data = res['data']
        table = $("#sellTable > tbody:last")
        for (key in data){
            d = data[key];
            ele =  "<tr><td>"+ d.name + "</td><td>" + d.amount + "</td> <td>"  +
                "100</td> <td><div class='input-group col-lg-3'> <input class='form' type='text'> </div> </td> <td> <div class='btn btn-warning'> Sell </div> </td> </tr>";
//            console.log(ele);
            table.append(ele);
        }
    })
})(jQuery)