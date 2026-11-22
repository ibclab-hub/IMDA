var php_path = "../php/compare/";
var timer;

var job_datum = [];
var select_data_j = [];
var select_option_j = {};
var filtered = {};

$(document).ready(function () {
  var newURL = window.location.href;

  if (sid == "") {
    $("#time_header").html("This session does not exist.");
    $("#time_header").css("text-align", "center");
    $("#job_table").html("");
  } else {
    timer_function();
  }

  $("#textArea").html(newURL);

  var clipboard = new ClipboardJS(".btn");
  clipboard.on("success", function (e) {
    alert("The page address of the job id has been copied");
  });

  $("#statusFilter, #statusFilter2").on("change", function () {
    filterRows();
    updateSelectBoxBackground();
  });

  $("#up_sort").on("click", function () {
    $("#down_sort").css("background-color", "gray");
    sortTable("asc");
    $(this).css("background-color", "green");
  });

  $("#down_sort").on("click", function () {
    $("#up_sort").css("background-color", "gray");
    sortTable("desc");
    $(this).css("background-color", "green");
  });

  $(document).on("change", ".filter", function () {
    var feature_list = ["Status", "Main"];
    var type = "job";
    feature_list.forEach(function (ft) {
      filtered[ft] = [];

      $(".filter_" + type + ".filter_" + ft + ":checked").each(function () {
        filtered[ft].push($(this).val());
      });

      if (
        $(".filter_" + type + ".filter_" + ft).length != filtered[ft].length
      ) {
        $("#dropdown_" + ft + "_" + type).addClass("btn-dark");
        $("#dropdown_" + ft + "_" + type).removeClass("btn-outline-dark");
      } else {
        $("#dropdown_" + ft + "_" + type).removeClass("btn-dark");
        $("#dropdown_" + ft + "_" + type).addClass("btn-outline-dark");
      }
    });

    select_data_j = job_datum.filter(function (data) {
      for (var i = 0; i < feature_list.length; ++i) {
        var ft = feature_list[i];
        if (filtered[ft].indexOf(data[ft]) == -1) {
          return false;
        }
      }
      return true;
    });

    select_option_j["analysis"] = filtered["Main"];
    select_option_j["status"] = filtered["Status"];

    Make_job_table(select_data_j);
  });

  function timer_function() {
    Get_job_status(sid);
  }

  function filterRows() {
    var selectedStatus = $("#statusFilter").val();
    var selectedStatus2 = $("#statusFilter2").val();

    // Show or hide rows based on the select values
    $("#tbody tr").each(function () {
      var status = $(this).find("td:eq(1)").text(); // Get the text of the second td (index 1)
      var status2 = $(this).find("td:eq(2)").text(); // Get the text of the third td (index 2)

      // Check if the row matches the selected values in both filters
      if (
        (selectedStatus === "All" || status === selectedStatus) &&
        (selectedStatus2 === "All" || status2 === selectedStatus2)
      ) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  }

  function updateSelectBoxBackground() {
    var selectedStatus = $("#statusFilter").val();
    var selectedStatus2 = $("#statusFilter2").val();

    $("#statusFilter, #statusFilter2").css("background-color", "");

    if (selectedStatus !== "All") {
      $("#statusFilter").css("background-color", "#d3f9d3");
    }

    if (selectedStatus2 !== "All") {
      $("#statusFilter2").css("background-color", "#d3f9d3");
    }
  }

  function sortTable(order) {
    var $tbody = $("#tbody");
    var rows = $tbody.find("tr").toArray();

    rows.sort(function (a, b) {
      var aValue = parseInt($(a).find("td:eq(0)").text(), 10); // Assuming Job ID is numeric
      var bValue = parseInt($(b).find("td:eq(0)").text(), 10);

      if (order === "asc") {
        return aValue - bValue;
      } else {
        return bValue - aValue;
      }
    });

    $tbody.empty().append(rows);
  }
});

function Get_job_status(sid) {
  var times = 1000;
  clearInterval(timer);

  var works = function () {
    times -= 1000;
    $("#time").html(times / 1000);

    if (times == 0) {
      clearInterval(timer);
      times = 31000;

      $.ajax({
        method: "get",
        dataType: "json",
        url: php_path + "/get_jobstatus.php",
        data: {
          session: sid,
          type: "comparative_genomes",
        },
        success: function (data) {
          if (data.length) {
            data.forEach(function (d) {
              d.Status = "Ongoing";
              if (d.Done == "true") {
                d.Status = "Finished";
              }
              if (d.Error == "true") {
                d.Status = "Errors occurred";
              }
              if (d.Cancel == "true") {
                d.Status = "Canceled";
              }
            });
            job_datum = data;
            select_data_j = data;

            if (Object.keys(select_option_j).length == 0) {
              var main_l = $.unique(job_datum.map((d) => d.Main).sort());
              var status_l = $.unique(job_datum.map((d) => d.Status).sort());

              select_option_j["analysis"] = main_l;
              select_option_j["status"] = status_l;
            }

            select_data_j = job_datum.filter(function (data) {
              if (
                select_option_j["analysis"].indexOf(data.Main) == -1 ||
                select_option_j["status"].indexOf(data.Status) == -1
              ) {
                return false;
              }
              return true;
            });

            Make_job_table(select_data_j);
          } else {
            $("#job_table").html(
              "No job has been submitted under this session."
            );
            $("#job_timer").hide();
            clearInterval(timer);
          }
        },
      });

      timer = setInterval(works, 1000);
    }
  };
  timer = setInterval(works, 1000);
}

function Make_job_table(data) {
  var main_l = $.unique(job_datum.map((d) => d.Main).sort());
  var status_l = $.unique(
    job_datum
      .sort()
      .map((d) => d.Status)
      .sort()
  );

  var table =
    "<table class='table table-sm text-center align-middle mb-0' style='font-size: 0.875rem; table-layout:fixed'><thead><tr><td style='width:7%; vertical-align:middle;'>Job ID</td>";
  table +=
    "<td><div class='btn-group d-grid gap-2'><button style='font-size: 1rem;' class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_type_analysis' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>Analysis</button>";
  table += "<div class='dropdown-menu p-4 text-muted' id='view_list_anlaysis'>";

  main_l.forEach(function (m) {
    var checked = select_option_j["analysis"].indexOf(m) != -1 ? "checked" : "";

    table +=
      "<div class='form-check'><input class='form-check-input filter filter_job filter_Main' type='checkbox' value='" +
      m +
      "' id='filter_" +
      m +
      "_analysis'" +
      checked +
      ">";
    table +=
      "<label class='form-check-label' for='filter_" +
      m +
      "_Main'>" +
      m +
      "</label></div>";
  });
  table += "</div></div></td>";
  table +=
    "<td><div class='btn-group d-grid gap-2'><button style='font-size: 1rem;' class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_type_status' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>Status</button>";
  table += "<div class='dropdown-menu p-4 text-muted' id='view_list_status'>";
  status_l.forEach(function (m) {
    var checked = select_option_j["status"].indexOf(m) != -1 ? "checked" : "";

    table +=
      "<div class='form-check'><input class='form-check-input filter filter_job filter_Status' type='checkbox' value='" +
      m +
      "' id='filter_" +
      m +
      "_status' " +
      checked +
      ">";
    table +=
      "<label class='form-check-label' for='filter_" +
      m +
      "_Status'>" +
      m +
      "</label></div>";
  });
  table += "<div class='dropdown-menu p-4 text-muted' id='view_list_status'>";
  table += "<td style='vertical-align:middle;'>Running process</td></tr></thead>";

  data.forEach(function (d) {
    var status = "Ongoing";

    if (d.Done == "true") {
      status = "Finished";
    }
    if (d.Error == "true") {
      status = "Errors occurred";
    }
    if (d.Cancel == "true") {
      status = "Canceled";
    }

    var job =
      //status == "Finished" || status == "Canceled"
      status == "Canceled"
        ? "-"
        : d.Middle
        ? d.Middle
        : "Preparing submitted job";
    var cancel_btn_show =
      status == "Finished" ||
      status == "Canceled" ||
      status == "Errors occurred"
        ? "none"
        : "block";

    table +=
      "<tr><td>" +
      d.ID +
      "</td><td>" +
      d.Main +
      "</td><td id='status_" +
      d.ID +
      "'><div>" +
      status +
      "</div><div class='d-grid'><button type='button' style='display:" +
      cancel_btn_show +
      "' class='btn btn-link btn-sm text-center' onclick='Quit_job(" +
      d.PID +
      ',"' +
      sid +
      '",' +
      d.ID +
      ")'>Quit job</button></div>" +
      "</td><td id='process_" +
      d.ID +
      "'>" +
      job +
      "</td></tr>";
  });

  table += "</table>";
  $("#job_table").html(table);
}

function Quit_job(pid, sid, job) {
  if (pid) {
    $.ajax({
      method: "get",
      url: php_path + "/quit_synteny_job.php",
      data: {
        pid: pid,
        jobid: job,
        session: sid,
      },
      success: function () {
        $("#status_" + job).html("Canceled");
        $("#process_" + job).html("-");
      },
    });
  }
}
