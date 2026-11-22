var php_path = "../php/browser/";

var page_idx = 1,
  total_data = 0,
  row = 10;

var cur_data = [],
  spc_data = {};

var search = false;
var search_query = {
  sth: "",
  aln: "",
  syn: "",
};

$(document).ready(function () {
  Get_tablespcData();
  Get_tableData(page_idx);

  $(document).on("mouseover", ".info", function () {
    var highlight_class = $(this)
      .attr("class")
      .match(/info-\w+/)[0];
    $("." + highlight_class).addClass("table-primary");
    if ($("." + highlight_class).hasClass("table-light")) {
      $("." + highlight_class).removeClass("table-light");
      $("." + highlight_class).addClass("table-light-bak");
    }
  });

  $(document).on("mouseout", ".info", function () {
    var highlight_class = $(this)
      .attr("class")
      .match(/info-\w+/)[0];
    $("." + highlight_class).removeClass("table-primary");
    if ($("." + highlight_class).hasClass("table-light-bak")) {
      $("." + highlight_class).addClass("table-light");
      $("." + highlight_class).removeClass("table-light-bak");
    }
  });

  $("#row_cnt").change(function () {
    page_idx = 1;
    row = parseInt($(this).val());

    if (search) {
      Search_data(search_query, page_idx);
    } else {
      Get_tableData(page_idx);
    }
  });

  $(document).on("click", "#first_page", function () {
    if (!$(this).hasClass("disabled")) {
      page_idx = 1;

      if (search) {
        Search_data(search_query, page_idx);
      } else {
        Get_tableData(page_idx);
      }
    }
  });

  $(document).on("click", "#prev_page", function () {
    if (!$(this).hasClass("disabled")) {
      page_idx = (parseInt(page_idx / 5) - 1) * 5 + 1;
      if (search) {
        Search_data(search_query, page_idx);
      } else {
        Get_tableData(page_idx);
      }
    }
  });

  $(document).on("click", ".page", function () {
    page_idx = parseInt($(this).attr("id").split("_")[1]);
    $(".page").removeClass("active");
    $(this).addClass("active", true);

    Make_table();
  });

  $(document).on("click", "#next_page", function () {
    if (!$(this).hasClass("disabled")) {
      page_idx = Math.ceil(page_idx / 5) * 5 + 1;
      if (search) {
        Search_data(search_query, page_idx);
      } else {
        Get_tableData(page_idx);
      }
    }
  });

  $(document).on("click", "#last_page", function () {
    if (!$(this).hasClass("disabled")) {
      page_idx = Math.ceil(total_data / row);
      if (search) {
        Search_data(search_query, page_idx);
      } else {
        Get_tableData(page_idx);
      }
    }
  });

  $("input:checkbox[name='col-flt']").change(function () {
    if ($(this).attr("id") == "target_genome") {
      $("input:checkbox[id^='target']").prop(
        "checked",
        $(this).prop("checked")
      );
    } else if ($(this).attr("id") == "compare_genome") {
      $("input:checkbox[id^='compare']").prop(
        "checked",
        $(this).prop("checked")
      );
    } else if ($(this).attr("id") == "program") {
      $("input:checkbox[id^='program']").prop(
        "checked",
        $(this).prop("checked")
      );
    } else if ($(this).attr("id").indexOf("target") != -1) {
      if (
        $("input:checkbox[id^='target']:checked").not("[id^='target_genome']")
          .length == 0
      ) {
        $("input:checkbox[id='target_genome']").prop("indeterminate", false);
        $("input:checkbox[id='target_genome']").prop("checked", false);
      } else if (
        $("input:checkbox[id^='target']:checked").not("[id^='target_genome']")
          .length ==
        $("input:checkbox[id^='target']").not("[id^='target_genome']").length
      ) {
        $("input:checkbox[id='target_genome']").prop("indeterminate", false);
        $("input:checkbox[id='target_genome']").prop("checked", true);
      } else {
        $("input:checkbox[id='target_genome']").prop("indeterminate", true);
      }
    } else if ($(this).attr("id").indexOf("compare") != -1) {
      if (
        $("input:checkbox[id^='compare']:checked").not("[id^='compare_genome']")
          .length == 0
      ) {
        $("input:checkbox[id='compare_genome']").prop("indeterminate", false);
        $("input:checkbox[id='compare_genome']").prop("checked", false);
      } else if (
        $("input:checkbox[id^='compare']:checked").not("[id^='compare_genome']")
          .length ==
        $("input:checkbox[id^='compare']").not("[id^='compare_genome']").length
      ) {
        $("input:checkbox[id='compare_genome']").prop("indeterminate", false);
        $("input:checkbox[id='compare_genome']").prop("checked", true);
      } else {
        $("input:checkbox[id='compare_genome']").prop("indeterminate", true);
      }
    } else if ($(this).attr("id").indexOf("program") != -1) {
      if (
        $("input:checkbox[id^='program']:checked").not("[id='program']")
          .length == 0
      ) {
        $("input:checkbox[id='program']").prop("indeterminate", false);
        $("input:checkbox[id='program']").prop("checked", false);
      } else if (
        $("input:checkbox[id^='program']:checked").not("[id='program']")
          .length ==
        $("input:checkbox[id^='program']").not("[id='program']").length
      ) {
        $("input:checkbox[id='program']").prop("indeterminate", false);
        $("input:checkbox[id='program']").prop("checked", true);
      } else {
        $("input:checkbox[id='program']").prop("indeterminate", true);
      }
    }

    $("input:checkbox").each(function () {
      Make_table();
    });
  });

  $("#search").click(function () {
    if ($("#search_tar").val().trim().length != 0) {
      search = true;
      page_idx = 1;

      search_query["sth"] = $("#search_tar").val().trim().replaceAll(" ", "_");
      Search_data(search_query, page_idx);
    }
  });

  $(document).on("change", ".filter-col", function () {
    search = true;
    page_idx = 1;

    var select_alns = [],
      select_syns = [];
    $("input:checkbox[name='aln-flt']:checked").each(function () {
      select_alns.push($(this).attr("id"));
    });
    $("input:checkbox[name='syn-flt']:checked").each(function () {
      select_syns.push($(this).attr("id"));
    });

    search_query["aln"] = select_alns.join(",");
    search_query["syn"] = select_syns.join(",");

    Search_data(search_query, page_idx);
  });

  $("#reset").click(function () {
    search = false;

    $("#div_reset").addClass("hidden");

    var select_alns = [],
      select_syns = [];
    $("input:checkbox[name='aln-flt']").each(function () {
      select_alns.push($(this).attr("id"));
    });
    $("input:checkbox[name='syn-flt']").each(function () {
      select_syns.push($(this).attr("id"));
    });

    search_query["aln"] = select_alns.join(",");
    search_query["syn"] = select_syns.join(",");
    search_query["sth"] = "";

    $(".filter-col").prop("checked", true);

    page_idx = 1;
    Get_tableData(page_idx);
  });
});

function Get_tableData(idx) {
  $.ajax({
    method: "get",
    url: php_path + "/get_syntenylist.php",
    data: {
      page_idx: parseInt((idx - 1) / 5) * 5,
      row_cnt: row,
    },
    success: function (dat) {
      var row = dat.split("\n");
      row.pop();

      total_data = parseInt(row.shift());
      if (row[0] !== undefined) {
        var filter_items = row[0].split(/\s+/);

        if ($(".filter-col").length == 0) {
          filter_items[1].split(",").forEach(function (item) {
            $("#syn_li").append(
              '<p class="m-0"> <input class="form-check-input ms-2 filter-col" type="checkbox" name="syn-flt" id="' +
                item +
                '" checked> ' +
                item +
                "</p>"
            );
          });

          /*
        var select_alns = [],
        $("input:checkbox[name='aln-flt']").each(function () {
          select_alns.push($(this).attr("id"));
        });
        search_query["aln"] = select_alns.join(",");
*/
          var select_syns = [];
          $("input:checkbox[name='syn-flt']").each(function () {
            select_syns.push($(this).attr("id"));
          });

          search_query["syn"] = select_syns.join(",");
        }

        cur_data = row;

        Make_fagination();
        Make_table();
      }
    },
  });
}

function Get_tablespcData() {
  $.ajax({
    method: "get",
    data: {
      type: "table",
    },
    url: php_path + "/get_spclist.php",
    success: function (dat) {
      var json = $.parseJSON(dat);
      json.forEach(function (spc) {
        spc_data[spc.Scientific_name.toLowerCase()] = spc.class;
      });
      $(".load_spc").addClass("hidden");
      $("#main_table").removeClass("hidden");
    },
  });
}

function Make_table() {
  var data_idx = page_idx % 5;
  if (data_idx == 0) {
    data_idx = 5;
  }

  var table_data = cur_data.slice((data_idx - 1) * row, data_idx * row);
  var table_col = [
    "Accession ID",
    "Scientific name",
    "Assembly ID",
    "No. of targets",
    "Scientific name",
    "Assembly ID",
    "Evolutionary distance (MYA)",
    "Whole genome <br> alignment",
    "Synteny <br> generation",
    "Resolution (bp)",
    "Synteny <br> download",
  ];
  var table_ln = [1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1];

  var th_row = 0;
  var selected_col = [];
  $(".table-col:checked").each(function () {
    selected_col.push(parseInt($(this).val()));
    if (table_ln[parseInt($(this).val())] > th_row) {
      th_row = table_ln[parseInt($(this).val())];
    }
  });

  var th = "<thead><tr>";
  if (selected_col.indexOf(0) != -1) {
    th +=
      "<td rowspan=" +
      th_row +
      " class='border-bottom'>" +
      table_col[0] +
      "</th>";
  }

  var target_col_cnt = 0;
  if (selected_col.indexOf(1) != -1) {
    target_col_cnt++;
  }
  if (selected_col.indexOf(2) != -1) {
    target_col_cnt++;
  }

  if (target_col_cnt != 0) {
    th +=
      "<td colspan=" +
      target_col_cnt +
      " class='border-bottom'>Reference genome</th>";
  }

  var comp_col_cnt = 0;
  if (selected_col.indexOf(3) != -1) {
    comp_col_cnt++;
  }
  if (selected_col.indexOf(4) != -1) {
    comp_col_cnt++;
  }
  if (selected_col.indexOf(5) != -1) {
    comp_col_cnt++;
  }
  if (selected_col.indexOf(6) != -1) {
    comp_col_cnt++;
  }

  if (comp_col_cnt != 0) {
    th +=
      "<td colspan=" +
      comp_col_cnt +
      " class='border-bottom'>Target genome</th>";
  }

  var program_col_cnt = 0;
  if (selected_col.indexOf(7) != -1) {
    program_col_cnt++;
  }
  if (selected_col.indexOf(8) != -1) {
    program_col_cnt++;
  }

  if (program_col_cnt != 0) {
    th +=
      "<td colspan=" + program_col_cnt + " class='border-bottom'>Program</th>";
  }

  if (selected_col.indexOf(9) != -1) {
    th +=
      "<td rowspan=" +
      th_row +
      " class='border-bottom'>" +
      table_col[9] +
      "</th>";
  }

  if (selected_col.indexOf(10) != -1) {
    th +=
      "<td rowspan=" +
      th_row +
      " class='border-bottom'>" +
      table_col[10] +
      "</th>";
  }

  th += "</tr>";
  th += "<tr>";
  selected_col.forEach(function (i) {
    if (i != 0 && i != 9 && i != 10) {
      th += "<td>" + table_col[i] + "</th>";
    }
  });
  th += "</tr>";
  th += "</thead>";

  $("#synteny-table").html(th);

  var curln = 0;

  $("#synteny-table").append("<tbody>");
  table_data.forEach(function (r) {
    if (r != "") {
      var col = r.split("\t");

      var aid = col[0],
        refspc_str = col[1],
        compspc_str = col[2],
        res = col[3],
        aln = col[4],
        sf = col[5],
        path = col[6];

      var compspcs = compspc_str.split(/[,|\(]/);
      var refspc_info = refspc_str.split(/\(/);

      var tr_row = comp_col_cnt == 0 ? 3 : compspcs.length;

      var tr = "";
      var col_cnt = 0;
      for (var i = 0; i < tr_row; i += 3) {
        tr +=
          curln % 2
            ? "<tr class='table-light border-top info info-" + curln + "'>"
            : "<tr class='border-top info info-" + curln + "'>";

        if (i == 0) {
          selected_col.forEach(function (j) {
            if (j == 0) {
              col_cnt++;
              tr +=
                "<td nowrap rowspan=" +
                tr_row / 3 +
                "><a href='./genome.html?accession=" +
                aid +
                "'>" +
                aid +
                "</a></td>";
            }
            if (j == 1) {
              col_cnt++;
              tr +=
                "<td nowrap rowspan=" +
                tr_row / 3 +
                ">" +
                refspc_info[0].replaceAll("_", " ") +
                "</td>";
            }
            if (j == 2) {
              col_cnt++;
              tr +=
                "<td nowrap rowspan=" +
                tr_row / 3 +
                ">" +
                refspc_info[1].replace(")", "") +
                "</td>";
            }
            if (j == 3) {
              col_cnt++;
              tr +=
                "<td nowrap rowspan=" + tr_row / 3 + ">" + tr_row / 3 + "</td>";
            }
            if (j == 4) {
              col_cnt++;
              tr += "<td nowrap>" + compspcs[i].replaceAll("_", " ") + "</td>";
            }
            if (j == 5) {
              col_cnt++;
              tr += "<td nowrap>" + compspcs[i + 1] + "</td>";
            }
            if (j == 6) {
              col_cnt++;
              var dist = parseFloat(compspcs[i + 2].replace(")", " "));
              dist = dist.toFixed(2);
              tr += "<td nowrap>" + dist + "</td>";
              //tr += "<td nowrap>" + compspcs[i + 2].replace(")", " ") + "</td>";
            }
            if (j == 7) {
              col_cnt++;
              tr += "<td nowrap rowspan=" + tr_row / 3 + ">" + aln + "</td>";
            }
            if (j == 8) {
              col_cnt++;
              tr += "<td nowrap rowspan=" + tr_row / 3 + ">" + sf + "</td>";
            }
            if (j == 9) {
              col_cnt++;
              tr += "<td nowrap rowspan=" + tr_row / 3 + ">" + res + "</td>";
            }
            if (j == 10) {
              col_cnt++;
              tr +=
                "<td nowrap rowspan=" +
                tr_row / 3 +
                "><a href='" +
                path +
                "' target='_blank'>Link </a></td>";
            }
          });
        } else {
          selected_col.forEach(function (j) {
            if (j == 4) {
              tr += "<td nowrap>" + compspcs[i].replace("_", " ") + "</td>";
            }
            if (j == 5) {
              tr += "<td nowrap>" + compspcs[i + 1].replace(")", " ") + "</td>";
            }
            if (j == 6) {
              var dist = parseFloat(compspcs[i + 2].replace(")", " "));
              dist = dist.toFixed(2);
              tr += "<td nowrap>" + dist + "</td>";
              //tr += "<td nowrap>" + compspcs[i + 2].replace(")", " ") + "</td>";
            }
          });
        }

        if (i == tr_row - 3) {
          var name_reg = /(\S+)\(\S+\)/;
          var comb = "comb-" + name_reg.exec(refspc_str)[1];
          compspc_str.split(",").forEach(function (spc) {
            comb += "_&_" + name_reg.exec(spc)[1];
          });

          tr +=
            "</tr><tr class='border-top hidden' id='tree-" +
            curln +
            "' style='height:500px;'><td colspan=" +
            col_cnt +
            " class='tree-" +
            curln +
            "-canvas' id='" +
            comb +
            "'></td>";
        }

        tr += "</tr>";
      }
      $("#synteny-table").append(tr);
      curln++;
    }
  });
  $("#synteny-table").append("</tbody>");
}

function Make_fagination() {
  var last_page = Math.ceil(total_data / row);

  var cur_beg_page = parseInt((page_idx - 1) / 5) * 5 + 1,
    cur_last_page = Math.min(cur_beg_page + 4, last_page);

  var fagi =
    parseInt(page_idx / 5) == 0
      ? '<li class="page-item disabled" id="first_page">'
      : '<li class="page-item" id="first_page">';
  fagi +=
    '<a class="page-link link-dark" aria-label="First"> \
    <span class="material-icons align-middle" style="font-size:.9rem"> first_page </span> \
    </a> \
  </li>';

  fagi +=
    parseInt(page_idx / 5) == 0
      ? '<li class="page-item disabled" id="prev_page">'
      : '<li class="page-item" id="prev_page">';
  fagi +=
    '<a class="page-link link-dark" aria-label="Previous"> \
      <span class="material-icons align-middle" style="font-size:.9rem"> chevron_left </span> \
    </a> \
  </li>';

  for (var i = cur_beg_page; i <= cur_last_page; ++i) {
    if (i == page_idx) {
      fagi +=
        '<li class="page-item page active" style="height: 1.5rem" id="page_' +
        i +
        '"><a class="page-link link-dark active">' +
        i +
        "</a></li>";
    } else {
      fagi +=
        '<li class="page-item page" style="height: 1.5rem" id="page_' +
        i +
        '"><a class="page-link link-dark active">' +
        i +
        "</a></li>";
    }
  }

  fagi +=
    parseInt((page_idx - 1) / 5) == parseInt(total_data / (5 * row))
      ? '<li class="page-item disabled" id="next_page">'
      : '<li class="page-item" id="next_page">';

  fagi +=
    '<a class="page-link link-dark" aria-label="Next"> \
      <span class="material-icons align-middle" style="font-size:0.9rem"> chevron_right </span> \
    </a> \
  </li>';

  fagi +=
    parseInt((page_idx - 1) / 5) == parseInt(total_data / (5 * row))
      ? '<li class="page-item disabled" id="last_page">'
      : '<li class="page-item" id="last_page">';
  fagi +=
    '<a class="page-link link-dark" aria-label="Last"> \
      <span class="material-icons align-middle" style="font-size:0.9rem" id="next_pages"> last_page </span> \
    </a> \
  </li>';

  $(".pagination").html(fagi);
}

function Search_data(query, idx) {
  $.ajax({
    method: "get",
    data: {
      page_idx: idx - 1,
      sth_query: "s" + query["sth"],
      row_cnt: row,
    },
    url: php_path + "/search_tabledata.php",
    success: function (dat) {
      var row = dat.split("\n");
      row.pop();

      total_data = row.shift();
      cur_data = row;

      $("#div_reset").removeClass("hidden");

      Make_fagination();
      Make_table();
    },
  });
}
