var cacheUrl = null;
var config = null;
var reports = {};

window.addEventListener('message', (event) => {
   var data = event.data;
 
   switch (data.action){ 
     case "report":
        $(".report-container").show("fade");
        $("button").hide("fade");
        __init__(data);
     break;
     case "showReports":
        $(".admin-hub").show("fade");
        __reports__(data);
     break;
     case "updateIMG":
        $(".img").html("");
        cacheUrl = data.img;
        $(".img").css({ "background":"url("+data.img+")", "background-size":"cover"  });
        $("button").show("fade");
     break;
     case "showNotif":
        AddNotify(data.data);
     break;
     case "config":
        config = data.config;
     break;  
    }
});

AddNotify = (data) => {
    ran = Math.floor(Math.random() * 10000000)
    $(".reports").append(`
        <div class="report" id="rep_${ran}" style="display:none;" >
            <p><i class="fa-light fa-circle-question"></i>&nbsp;&nbsp;Új jelentés</p>
            <div class="repimg" style="background: url(${data.data.img}); background-size:cover;" ></div>
            <b>Jelentve: <strong>${data.data.id}</strong>, Jelentő: <strong>${data.src}</strong></b>
            <script>
                $("#rep_${ran}").show("${config.NotifEffect}");
                setTimeout(() => {
                    $("#rep_${ran}").hide("${config.NotifEffect}");
                    setTimeout(() => {
                         $("#rep_${ran}").remove();
                    }, 1000);
                }, ${config.NotifTimeout});
             </script>
        </div>
    `);
}

__init__ = (data) => {
    if(data.id != 0) {
       $(".content input").val(data.id);
    }
}

__reports__ = (data) => {
   $(".altcon").html(``);
   
   $.each(data.data, function (i, v) { 
        reports[v.uniqueid] = v;
        $(".altcon").append(`
        <div class="repo">
        <i class="fa-solid fa-circle" style="color: ${v.extends}" id="col_${v.uniqueid}" ></i>
        <p>#${v.uniqueid} számú jelentés</p>
        <h1>Jelentett játékos ID: ${v.pid}</h1>
        <textarea disabled style="color: #ffffff !important;">${v.text}</textarea>
        <div class="repo_img" style="background:url(${v.img}); background-size:cover;"></div>
        <select onchange="durum_degis(this);" data-col="${v.uniqueid}">
            <option value="#ff004c">Megoldatlan</option>
            <option value="#ffaa00">Folyamatban</option>
            <option value="#00ff62">Megoldva</option>
        </select>   
        <button data-id="${v.uniqueid}">Megnyitás</button>
        </div>
    `);
   });
}

__close__ = () => {
    $.post("https://s4-reportsystem/close");
    $(".report-container").hide("fade");
    $(".admin-hub").hide("fade");
}

__back__ = () => {
    $.post("https://s4-reportsystem/reqReports");
}


$(document).on('click','button',function(){
    if($(this).data("id")) {
        var v = reports[$(this).data("id")];
        var date = new Date(v.datetime);
        var d =  date.getDay() + "/" + date.getMonth() + "/" + date.getFullYear();
        var vid = `<i class="fa-duotone fa-spinner-third fa-spin"></i>`;

        $.post("https://s4-reportsystem/getRepPoint", JSON.stringify({ identifier: v.identifier }), function (data) {
               
                $(".rep_points input").val(parseInt(data));
        });


        $(".altcon").html(`
        <div class="repbilgi">
        <i class="fa-solid fa-circle" style="color: ${v.extends}" id="col_${v.uniqueid}" ></i>
        <p>#${v.uniqueid}' számú jelentés</p>
        <h1>Jelentett játékos ID: ${v.pid}</h1>
        <textarea disabled style="color: #ffffff !important;">${v.text}</textarea>
        
        <div class="rep_points" align=center>
            <i class="fa-duotone fa-circle-caret-up"></i>
            <input type="number" data-identifier="${v.identifier}" value="0" disabled />
            <i class="fa-duotone fa-circle-caret-down"></i>
        </div>

        <div class="rep_x_box">
        <a href="#" data-action="ban" data-id="${v.pid}" data-identifier="${v.identifier    }" style="background: #d22a50;" ><i class="fa-solid fa-ban"></i> Kitiltás</a>
       
        <select onchange="durum_degis(this);" data-col="${v.uniqueid}">
            <option value="#ff004c">Megoldatlan</option>
            <option value="#ffaa00">Folyamatban</option>
            <option value="#00ff62">Megoldva</option>
        </select>   
        </div>
        

        <div class="repo_img" style="height: 100px; bottom: unset;  border-radius: 20px; background:url(${v.img}); background-size:cover;"></div>
        <table>
            <tr>
              <th style="color: #ffffff !important;">Név</th>
              <th style="color: #ffffff !important;">Jelentett játékos ID</th>
              <th style="color: #ffffff !important;">Beküldő ID</th>
              <th style="color: #ffffff !important;">Idő</th>
            </tr>
            <tr>
              <td style="color: rgb(0, 174, 255) !important;">${v.rname}</td>
              <td style="color: rgb(0, 174, 255) !important;">${v.rip} | ${v.identifier}</td>
              <td style="color: rgb(0, 174, 255) !important;">${v.pid} | ${v.owner}</td>
              <td style="color: rgb(0, 174, 255) !important;">${d}</td>
            </tr>
          
          </table>
        <div class="rep_video" align="center">
            <img src="${v.img}"width="977.7777778" height="550" style="border-radius: 20px;">
        </div>
        </div>
        `);
    }else {
        __close__();
        $.post("https://s4-reportsystem/save", JSON.stringify({ img: cacheUrl, id: $(".content input").val(), text: $(".content textarea").val()    }));
        cacheUrl = null;
    }
});

$(document).on('click','.fa-circle-xmark', __close__);

$(document).on('click','textarea',function(){
    if($(this).val() == "Írd le a részleteket...")
       $(this).val("")
});

$(document).on('click','.rep_x_box a',function(){
    if($(this).data("action") == "ban") {
       $.post("https://s4-reportsystem/ban", JSON.stringify({ id: $(this).data("id"), identifier: $(this).data("identifier")  }));
    }
    if($(this).data("action") == "msg") {

    }
});



$(document).on('click','.fa-circle-caret-up',function(){
    $("input").val(parseInt($("input").val()) + 1);
    $.post("https://s4-reportsystem/repPoint", JSON.stringify({ point: $("input").val(), identifier: $("input").data("identifier")   }));
});

$(document).on('click','.fa-circle-caret-down',function(){
    if( $("input").val() != 0) {
      $("input").val(parseInt($("input").val()) - 1);
      $.post("https://s4-reportsystem/repPoint", JSON.stringify({ point: $("input").val(), identifier: $("input").data("identifier")   }));
    }
});



$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: 
        __close__();
        break;
    }
});



durum_degis = (data) => {
    $.post("https://s4-reportsystem/prop", JSON.stringify({  unique: $(data).data("col"), value: $(data).val()}));
    $("#col_" + $(data).data("col")).css("color", $(data).val());
}