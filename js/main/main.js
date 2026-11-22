var php_path = "./php/main/";

$(document).ready(function () {
  $.ajax({
    method: "get",
    url: php_path + "/get_stats.php",
    success: function (data) {
      var stats = data.replaceAll("\n", " ").split(/[ |\t]+/);
      for (var i = 0; i < stats.length; i += 2) {
        $("#stats-" + stats[i]).html("<h1> <b> " + stats[i + 1] + "</b> </h1>");
      }
    },
  });
  $.ajaxSettings.async = true;
});
