/*
 * 20 Lines JavaScript - July : Super Mario Tribute
 * Copyright (c) 2008 Jacob Seidelin, cupboy@gmail.com, http://blog.nihilogic.dk/
 *
 * A Super Mario inspired game in 20 lines of JavaScript.
 *
 */
// data and variables used in the game
/* 01 */
var data = {
    pal: [
        // 0  1      2       3         4         5         6         7         8        9         10         11         12      13         14
        "", "000", "FFF", "E75A10", "F7D6B5", "FFA542", "C0FF2B", "00AD00", "F7D6B5", "39BDFF", "FFA044", "F83800", "FF3900", "AD7B00", "F0D0B0"
    ],
    sprites: [
        [
            [3, 1, 0, 4],
            "310703b0303010d31b0032c1034d203a1033a60339a0138c03190091f1031f6081ee0019f5011f5010a1012b1014c3017d0118a011b5301b4003b630".split()
        ],
        [
            [4, 1, 3, 0],
            s1 = "200f02010d10ff01f10d1220012d001d2001dd0015413154301a5131881218c11244122534029413287002781127b11"
        ],
        [
            [5, 1, 3, 0],
            s1
        ],
        [
            // Tube
            [0, 1, 6, 7],
            "1200f230cf3601f3d00f"
        ],
        [
            // Tube
            [0, 1, 6, 7],
            "1d00f2903f3008f391103931039510397103991039b1039d1039f10"
        ],
        [
            // Tube

            [0, 1, 6, 7],
            "100fe211ec3124b3c23b2132a2d31a12fd0"
        ],
        [
            // Tube

            [0, 1, 6, 7],
            "100fe10fd0201ec302ab3b2303b4103b6103b8103ba103bc10"
        ],
        [

            // Wooden blocks
            [3, 1, 0, 14],
            "300f0103f0107f010bf010ff0171011f101134021b40213c021bc02178021f802"
        ],
        [
            [1, 3, 0, 8],
            "111dd0220002d000d2000dd00"
        ],
        [

            // Step stones
            [3, 0, 1, 14],
            "310d0321b033290343703010d3120b32309334072f00e2e10c2d20a2c30820fe021ec022da023c80"
        ],
        [

            // hard blocks
            [0, 1, 6, 7],
            s2 = "2c93629c231d8201c9001ba0119c1018d0119f00"
        ],
        [

            // cloud
            [0, 1, 6, 7],
            s3 = "207f8224c32d23802515116030151001a100132101230211600107001b2011c4001d3001e4001f5023561034700395003a600"
        ],
        [

            // cloud
            [0, 1, 6, 7],
            s4 = "20a322390020c631080111a0012900138001490215c0016b0017c0216f00"
        ],
        [
            [0, 1, 2, 9],
            s2
        ],
        [
            [0, 1, 2, 9],
            s3
        ],
        [
            [0, 1, 2, 9],
            s4
        ],
        [
            // cloud

            [0, 1, 2, 9],
            "2b0412d2211a0001b1001c2011d4303d0003e1003f200"
        ],
        [
            // cloud

            [0, 1, 2, 9],
            "200f5116501372023620186702a6301a730105001750030220362303235039340344103a4203110038100390003e200"
        ],
        [
            // cloud

            [0, 1, 2, 9],
            "200452511215000161001720115410135101161010500"
        ],
        [
            // tree

            [0, 1, 7, 0],
            s5 = "10f0011e0012d0013c0014b0015a00169001780018700196001a5001b4001c3001d2001e1001f00021fe022ed023dc024cb025ba026a902798028870297602a6502b5402c4302d3202e2102f100"
        ],
        [
            [0, 1, 7, 0],
            s5,
            true
        ],
        [
            // tree

            [7, 1, 7, 0],
            "194131c1231d005"
        ],
        [

            [0, 1, 7, 0],
            "22eb110f1012e2015d501be201ef10"
        ],
        [
            [0, 10, 2, 11],
            "1711d1623b15359145752650539505274003840027b0038b00"
        ],
        [
            //gumbas
            [0, 1, 3, 4],
            s6 = "26030251502427023390224b0215d1207f221ad034503357113b5033971135a5034b7337f00134101b410155021a5021663013d1114e1116f001cc101ad4119e41"
        ],
        [
            [0, 1, 3, 4],
            s6,
            true
        ],
        [
            // mario

            [0, 12, 13, 5],
            s7 = "37230343813d400355612450023302242202530025410292012a4002953015040141802475023890229b123e2022f302ae202af3016701198001693015a5214b2219b2232a123ca12"
        ],
        [
            [0, 12, 13, 5],
            s8 = "30a2131c002d3223d02238330354812d3223d5103666125600244022532026400265102a3012b5002a6402a64016140152802d700228a22190014b3418b231bb2226b001894129920178001b8002eb122f90123c0224d0022d0121e01"
        ],
        [
            [0, 12, 13, 5],
            s9 = "38330354813e5003666125600244022532026400265102a3012b5002a630161401528023871259713d9212da003191233a0015b6222e2114c2213d001ac222dc022eb03178121990019a20"
        ],
        [
            [0, 12, 13, 5],
            s7,
            true
        ],
        [
            [0, 12, 13, 5],
            s8,
            true
        ],
        [
            [0, 12, 13, 5],
            s9,
            true
        ],
        [
            [7, 0, 0, 0],
            "00000"
        ],
        [
            [0, 1, 3, 4],
            "268302399021ad020bf133d9034e7011f401af4032bb013a2016b301aa20"
        ],
        [
            [0, 0, 0, 0],
            "0000"
        ]
    ],
    spriteHTML: [],
    lvl: [

        [
                  "0000000000o000000000000000000000"
                + "0000000o002000000000000000000000"
                + "0000o0020000000efg00000000000000"
                + "000020000000000hij00000000000000"
                + "00000000000000000000000000000000"
                + "000888888888800000000a000ppp0000"
                + "00000000pppppp000o0000a000000000"
                + "00000000000000000200000a00000000"
                + "0000000p00000000000000000effg000"
                + "00000000o0000000000000000hiij000"
                + "00000000200000000000000000000000"
                + "00000000000000pp0000000a0ppp000"
                + "00p00000000000000670000000a00000"
                + "0aaaa00000000000045000000a000000"
                + "00000a00a00000008888000000000000"
                + "a0000azza000000000000a0000000000"
                + "a000006700000000000000a00000n000"
                + "a00n0045000000000000000a000kxl00"
                + "a0kml04500bcd00p0p00bcccd00kxxml0"
                + "111da111111111111111111111111111",
            5, 2, 17.5, 11
        ],
        [
                "0000p0p000o000000000000000000000"
                + "0p0p00pp000o002000ppp00000000pp0"
                + "0000o0020p00000efg00000000000000"
                + "000020000000000hij000000p0000000"
                + "00000pppp00000000000000000000000"
                + "000888888888800000p00a0000000000"
                + "0000p0000000p000po0000ap00000000"
                + "0000000pp00000002p00000a00000000"
                + "000000000pppp000000000000effg000"
                + "00000000o0000000000000000hiij000"
                + "0000000020000pp00000000000000000"
                + "000000000000000000000000000a0000"
                + "00p0000p00p000p0670p00p000a00000"
                + "0aaaa00000000000045000000a000000"
                + "00000a00a000pp008888000000000000"
                + "a0000azza000000000000a0000000000"
                + "a000006700000pp0000pp0a00000n000"
                + "a00n0045000000000000000a000kxl00"
                + "a0kml04500bcd00p0p00bcccd00kxxml0"
                + "111da111111111111111111111111111",
            5, 2, 17.5, 11
        ],


        [
                "000000000o000000000000000000o000"
                + "00000000020000000000000000002000"
                + "000006700000000000efg00000000000"
                + "000004500000000000hij0000000p000"
                + "88888888800000000000000000088880"
                + "00000000000000000000000000000000"
                + "000efg00000000o00000000000a00000"
                + "000hij0000000020000000000000000a"
                + "00000000000000000000000000000000"
                + "00000000o00000000000000000a00000"
                + "00000000200000a0000000000000000a"
                + "00000000000000000zz0000000000000"
                + "00o00000000000000670000000a00000"
                + "00200000a0000000045000000000000a"
                + "00000000000000000450000000000000"
                + "00000000000000000450000000a00000"
                + "00a00000000000000450000000000000"
                + "00000000000000000450000000000000"
                + "00bcd00p000bccd0045000000p000000"
                + "11111111111111111111111111111111",
            5, 3, 5.5, 1
        ],
        [
                "00000000000000000000000000000000"
                + "0ooooo00000000000000000000000000"
                + "0222220efg00a000000000000000a00a"
                + "0000000hij00a000000000000000azza"
                + "00p000000000a000aa0000aa00000670"
                + "088888000000a000000oo00000000450"
                + "0o0000000000a000000220000efg0450"
                + "020000000a00a000000000000hij0450"
                + "000p00000000a000000p000000000450"
                + "08888800000000000088880000000450"
                + "0o00000000effg000000000000000450"
                + "020000000ahiij000000000000000450"
                + "00p00000000000000000000000000450"
                + "88888800000000000000000000000450"
                + "00000a00a00000000000000000000450"
                + "00000azza00000000000000000000450"
                + "000000670a000000000n000000000450"
                + "000n004500a0000000kxl0000n000450"
                + "00kml045000abcd00kxmxl00kml00450"
                + "11111111111111111111111111111111",
            9, 4, 6.5, 15
        ],
        [
                "00000000000000000000000000000000"
                + "0000efg0000000000000000000000000"
                + "0000hij0000000000000000000000000"
                + "000000000000000effg0000000000000"
                + "000000000000000hiij0000000000000"
                + "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "0zz00000000000000000000000000000"
                + "06700000000000000000000000000670"
                + "04500000000000000000000000000450"
                + "88888888888888800888888888888888"
                + "00000000000000000000000000000000"
                + "000000000000000oo000000000000000"
                + "oo00000o0000088228800000o0o0o000"
                + "220000a2800000000000000828282800"
                + "00000aa0000000000000000000n00000"
                + "0000aaa000000000000000000kxl0000"
                + "000aaaa000bccdp00bccdp00kmxxl000"
                + "11111111111111111111111111111111",
            8, 2, 29.5, 8
        ],
        [
                "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "000efg00000000000000000000000000"
                + "000hij00000000000000000000000000"
                + "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "0zz0000000000000efg0000000000000"
                + "0670000000000000hij000000efffg00"
                + "0450000000000000000o00000hiiij00"
                + "88880000000000000002000000000000"
                + "00000000000000000000000000000000"
                + "00000000000000000000000000000000"
                + "000000000000000000o0o00000000000"
                + "00000000000000000828280000000000"
                + "00000000000000000000000000zz0000"
                + "000000000000000n0000000000670000"
                + "0000000000bccdkml0p00bcd00450000"
                + "11111111111111111111111111111111",
            3, 1, 1.5, 8
        ],
        [
                "00000000000000000000000000000000"
                + "000o0000000000000000000000000000"
                + "00020000000effg00000000000000000"
                + "00000000000hiij00000000000000000"
                + "00000000000000000000000000000670"
                + "000a00000p00000000p0000000000450"
                + "00000000aaaaa0000aaaaa00efgaaaaa"
                + "00000000a0o0a0000a0o0a00hija0000"
                + "00000000a020a0000a020a00000a0zz0"
                + "a0000000a000a0efga000a00000a0670"
                + "00000000000000hij0000000000a0450"
                + "0000000000a00000000a0000000aaaa0"
                + "00000000000000000000000000000000"
                + "08888880000000p000000000000a000a"
                + "000000a00000o8888o00000000000000"
                + "a00oo0a000082aaaa280000000000a00"
                + "000220a0000000000000000000000000"
                + "000n00a0000000000000000000000000"
                + "00kml0a000000000bccd0000bcd00000"
                + "11111111111111111111111111111111",
            7, 3, 29.5, 3
        ]

    ],
    curLvl: 0,
    coins: 0,
    goombas: 0,
    mapHTML: "",
    ground: false,
    keys: [],
    dirX: 1,
    mov: {
        x: 0,
        y: 0
    },
    interval: 0
}


for (var i = 0; i < data.sprites.length; i++) {
    /* 03 */
    for (var b = 0; b < (pix = (data.sprites[i][1] + "").split("")).length;
         data.spriteHTML[i] = (data.spriteHTML[i] || "<div style=' position:absolute;width:16px;height:16px;"
             + ((data.pal[data.sprites[i][0][0]] != "")
                 ? ("background-color:#" + data.pal[data.sprites[i][0][0]])
                 : "")
             + "' >") +

             ((data.sprites[i][0][parseInt(pix[b], 16)] != "") ?

                 ("<div style=' position:absolute;"
                     + "left:" + (data.sprites[i][2] ? (16 - parseInt(pix[b + 1], 16) - (parseInt(pix[b + 3], 16) + 1)) : parseInt(pix[b + 1], 16) ) + "px;"
                     + "top:" + parseInt(pix[b + 2], 16) + "px;"
                     + "width:" + (parseInt(pix[b + 3], 16) + 1) + "px;"
                     + "height:" + (parseInt(pix[b + 4], 16) + 1) + "px;"
                     + "background-color:#" + data.pal[data.sprites[i][0][parseInt(pix[b], 16)]] + ";"
                     + "overflow:hidden;"
                     + "'></div>")

                 : "")

             + ( (b += 5) >= pix.length ? "</div>" : "")
        ) {
    }
}

// keyboard events
document.onkeydown = document.onkeyup = function (e) {
    /* 04 */
    data.keys[(e || window.event).keyCode] = (e || window.event).type == "keydown";
}

// is tile at (x,y) blocking?
function block(x, y) {
    /* 05 */
    return (
        (data.map[Math.floor(y / 16) * 32 + Math.floor(x / 16)] != "0"
            && parseInt(data.map[Math.floor(y / 16) * 32 + Math.floor(x / 16)], 16) < 11)
        );
}


function getPowers(success) {
    $.ajax({
        url: "http://localhost:3000/en/api/koin.json?account=lugi@nintendo.com&koin=KOBEARBEAR"

    })
        .done(function (resp) {
            window.powers = resp.powers;
            if (console && console.log) {
                console.log(window.powers.goombas);
            }
            success();
            $("#powers").text(powers=" Goombas redeemd! " + powers.goombas);

        });

}

window.goombas = 0;

window.goombas_switch = []

function enoughGoomba(i) {


    if (window.goombas_switch[i] == null) {
        if (window.goombas < window.powers.goombas ) {
            console.log (window.goombas + "/ " + window.powers.goombas)
            window.goombas_switch[i] = 20;
            return false;
        } else {
            window.goombas_switch[i] = 0;
            return true;
        }


    } else {
        if (window.goombas_switch[i] == 20)
            return false;
    }
//    console.log("Enough goomba: " + window.goombas);
    return true;
}

// start the game and/or continue to next level
window.onload = nextLevel = function () {
    getPowers(function () {

    // reset game vars
    /* 06 */



    data = {
        pal: data.pal,
        sprites: data.sprites,
        spriteHTML: data.spriteHTML,
        mapHTML: "",
        curLvl: data.curLvl + 2,
        lvl: data.lvl,
        map: data.lvl[(thisLvl = (data.curLvl + 1) % data.lvl.length)][0].split(""),
        coins: data.lvl[thisLvl][1],
        goombas: data.lvl[thisLvl][2],
        startx: data.lvl[thisLvl][3],
        starty: data.lvl[thisLvl][4],
        mov: {
            x: data.mov.x,
            y: -6
        },
        dirX: data.dirX,
        ground: false,
        keys: [],
        interval: data.interval
    }


// generate map
    /* 07 */
    for (var i = 0; i < data.map.length; i++) {


        if (data.map[i] == "0")
            continue;
        data.mapHTML +=

                 "<div id='map_sprite_" + i + "' class='mapsprite' style=' position:absolute;"
                 + "left:" + ((i % 32) * 16) + "px;top:" + (Math.floor(i / 32) * 16) + "px;"
                 + (data.map[i] == "o" ? "display:none;" : "")
                 + "'><div style='height:16px;width:48px;'>"
                 + ((data.map[i] == "p" && enoughGoomba(i) )?"":data.spriteHTML[parseInt(data.map[i], 36) - 1]);
        if (  data.map[i] == "2" ) {
            data.mapHTML +=
                // are we a question box?


                ("<div style='left:16px;'>" + data.spriteHTML[2] + "</div>"
                    + "<div style='left:32px;'>" + data.spriteHTML[8] + "</div>")

            ;
        }
        if (  data.map[i] == "p" && !enoughGoomba(i)) {
            window.goombas ++;
        }
//        if (  data.map[i] == "p" && !enoughGoomba(i)) {
//            console.log("goomba painted: " + i);
//            console.log(window.goombas);
//            window.goombas ++;
//            data.mapHTML +=
//                    ("<div style='left:16px;'>" + data.spriteHTML[25] + "</div>"
//                        + "<div style='left:32px;'>" + data.spriteHTML[33] + "</div>")
//                    ;
//        }

        data.mapHTML += "</div></div>";


    }

// add the map sprites + Mario sprite to container div
    /* 08 */
    document.getElementById("mario").innerHTML =
        data.mapHTML
        + "<div id='mario_sprite' style=' position:absolute;left:" + (data.startx * 16) + "px;top:" + (data.starty * 16) + "px;'>"
        + "<div style='left:0px;'>" + data.spriteHTML[26] + "</div>"
        + "<div style=' position:absolute;left:" + (1 * 16) + "px;'>" + data.spriteHTML[27] + "</div>"
        + "<div style=' position:absolute;left:" + (2 * 16) + "px;'>" + data.spriteHTML[28] + "</div>"
        + "<div style=' position:absolute;left:" + (3 * 16) + "px;'>" + data.spriteHTML[29] + "</div>"
        + "<div style=' position:absolute;left:" + (4 * 16) + "px;'>" + data.spriteHTML[30] + "</div>"
        + "<div style=' position:absolute;left:" + (5 * 16) + "px;'>" + data.spriteHTML[31] + "</div>"
        + "<div style=' position:absolute;left:" + (6 * 16) + "px;'>" + data.spriteHTML[32] + "</div>"
        + "</div>";

// start the game cycle if not already started
    /* 09 */
    data.interval = data.interval || setInterval(function () {

        // where does wittle Mario want to go?
        /* 10 */
        var newPos = {
            x: Math.min(32 * 16 - 16,
                Math.max(0,
                        (oldX = parseInt((mspr = document.getElementById("mario_sprite")).style.left || 0))
                        + (data.mov.x =
                        (data.keys[37] ?
                            Math.max(-6, --data.mov.x) :
                            (
                                data.keys[39] ?
                                    Math.min(6, ++data.mov.x)
                                    : (Math.abs(data.mov.x) > 0.7 ? (data.mov.x < 0 ? (data.mov.x + 0.7) : (data.mov.x - 0.7)) : 0)
                                )
                            )
                        )
                )
            ),
            y: ((data.mov.y = (data.ground && (data.keys[38] || data.keys[65])) ? -8 : (data.mov.y + (data.mov.y < 8 ? (data.mov.y < -4 ? 0.7 : 1) : 0))) < 0) ?
                Math.floor(((oldY = parseInt(mspr.style.top || 0)) + data.mov.y) / 4) * 4
                : Math.ceil(((oldY = parseInt(mspr.style.top || 0)) + data.mov.y) / 4) * 4
        };


// bonk any question box above
        /* 11 */
        (document.getElementById("map_sprite_" + (idxLastBonkCheck = Math.floor(newPos.y / 16) * 32 + Math.floor((newPos.x + 8) / 16))) || {}).bonked =
            (data.map[idxLastBonkCheck] == "2")
                ? (document.getElementById("map_sprite_" + (idxLastBonkCheck - 32)) ).style.display = "block"
                : 0xDECAFBAD;


// collect coin
        /* 12 */
        if (
            (data.map[ idxCoin = Math.floor((newPos.y) / 16) * 32 + Math.floor((newPos.x + 8) / 16) ] == "o"
                || data.map[ idxCoin = Math.floor((newPos.y + 8) / 16) * 32 + Math.floor((newPos.x + 8) / 16) ] == "o")
            && document.getElementById("map_sprite_" + (idxCoin + 32)).bonked
            && !(coinSprite = document.getElementById("map_sprite_" + idxCoin) ).collected
            && (coinSprite.collected = true) && data.coins-- && (coinSprite.innerHTML = "")) {
        }

// do collision detection against map tiles and move Mario to new pos
        /* 13 */
        mspr.style.left =
            (newPos.x = Math.round(data.mov.x ?
                    (
                            data.mov.x < 0 ?
                        (
                            (block(newPos.x, oldY) || block(newPos.x, oldY + 15)) ?
                                (Math.floor(oldX / 16) * 16) : newPos.x
                            )
                        : (
                        (block(newPos.x + 16, oldY) || block(newPos.x + 16, oldY + 15)) ?
                            (Math.ceil(oldX / 16) * 16) : newPos.x
                        )
                        )
                    : oldX
            )) + "px";


        /* 14 */
        mspr.style.top =
            (newPos.y = Math.round(data.mov.y ?
                    (
                            data.mov.y < 0 ?
                        (
                            (!(data.ground = false) && (block(newPos.x, newPos.y) || block(newPos.x + 15, newPos.y))) ?
                                ((Math.floor(oldY / 16) * 16) + (data.mov.y = 0)) : newPos.y
                            )
                        : (
                        (block(newPos.x, newPos.y + 16) || block(newPos.x + 15, newPos.y + 16)) ?
                            (Math.ceil(oldY / 16) * 16) + (!(data.ground = true)) : newPos.y + (data.ground = false)
                        )
                        )
                    : oldY
            )) + "px";

// change Mario sprite
        /* 15 */
        mspr.scrollLeft =
            (data.ground ? (
                data.mov.x ? (
                    ((data.dirX = data.mov.x ? (data.mov.x < 0 ? -1 : 1) : data.dirX) < 0) ? (
                        (new Date().getTime() % 300 > 150) ? 48 : 80 ) : ( (new Date().getTime() % 300 > 150) ? 0 : 32)
                    ) : (
                    ((data.dirX = data.mov.x ? (data.mov.x < 0 ? -1 : 1) : data.dirX) < 0) ? 48 : 0
                    )
                ) : (
                ((data.dirX = data.mov.x ? (data.mov.x < 0 ? -1 : 1) : data.dirX) < 0) ? 64 : 16
                )
                );

// animate coin boxes and goombas, stomp goombas below
        /* 16 */
        for (var i = 0, stompThis = [0]; i < data.map.length; i++) {

            // stomp any goomba below Mario, let him jump a little after stomping
            /* 17*/
            data.mov.y =
                ( data.map[i] == "p"  && !enoughGoomba(i) &&
                    (
                        (goomba = document.getElementById("map_sprite_" + i)).stomped = goomba.stomped ||
                            (stompThis[i] = (data.mov.y > 0
                                && (my = parseInt(mspr.style.top, 10)) < (gy = parseInt(goomba.style.top, 10))
                                && my > gy - 16
                                && (mx = parseInt(mspr.style.left, 10)) + 16 > (gx = parseInt(goomba.style.left, 10))
                                && mx < gx + 16))
                        ) && stompThis[i] && data.goombas--) ? -4 * (data.ground = 1) : data.mov.y;


// move goombas
            /* 18 */
            if (data.map[i] == "p"  && !enoughGoomba(i)
                && (g = document.getElementById("map_sprite_" + i))
                && (g.style.left =
                    (g.stomped ? g.style.left
                        : (g.orgLeft || (g.orgLeft = parseInt(g.style.left, 10)))
                        + (g.walkStep = (g.walkStep || 0) +
                        (g.walkDir = ((g.walkStep || 0) < -7 ? 1 : ( (g.walkStep || 0) > 15 ? -1 : (g.walkDir || 1) )) )) * 2
                        ))
                ) {
            }

// change sprites for qboxes and goombas
            /* 19 */

        }

// try to exit the level
        /* 20 */
        if (
            data.keys[40]
            && data.map[ Math.floor((newPos.y) / 16) * 32 + Math.floor((newPos.x + 8) / 16) ] == "z"
            && !data.coins && !data.goombas
            && nextLevel(alert("Thank you, Mario! But our princess is in another pipe!\r\nProceeding to level 1-" + (data.curLvl + 2)))
            ) {
        }

    }, 40);
    });
}





