var php_path = "../php/browser/";
var syntenyInfo = {};
var multiomics_datum = [];
var highlight_datum = [];
var genomics_datum = [];
var job_datum = [];
var select_data_g = [];
var select_data_m = [];
var select_data_h = [];
var select_data_j = [];
var select_option_j = {};
var downsample_method = {};
var available_analyses = [];
var features = {};
var vis_tracks = [];
var ranges = {};
var track_id = 1;
var timer;
var track_data, highlight_data;
var available_data;

$(document).ready(function () {
  var omics_set = document.getElementById("omics-setting");
  var genomics_set = document.getElementById("genomics-setting");
  var highlight_set = document.getElementById("highlight-setting");

  new Sortable(omics_set, {
    handle: ".drag_indicator",
    animation: 150,
    onEnd: function () {
      var orders = [];
      $("#omics-setting")
        .children("div")
        .each(function () {
          var id = this.id;
          var track_name = multiomics_datum.filter(function (d) {
            return d._id == Number(id.replace("opt-", ""));
          })[0].name;

          orders.push(track_name);
        });

      LIBNAME.Change_order(orders);
    },
  });

  new Sortable(genomics_set, {
    handle: ".drag_indicator",
    animation: 150,
    onEnd: function () {
      var orders = [];
      $("#genomics-setting")
        .children("div")
        .each(function () {
          var id = this.id;
          var track_name = genomics_datum.filter(function (d) {
            return d._id == Number(id.replace("opt-", ""));
          })[0].name;

          orders.push(track_name);
        });

      LIBNAME.Change_order(orders);
    },
  });

  new Sortable(highlight_set, {
    handle: ".drag_indicator",
    animation: 150,
    onEnd: function () {
      var orders = [];
      $("#highlight-setting")
        .children("div")
        .each(function () {
          var id = this.id;

          var track = multiomics_datum.filter(function (d) {
            return d._id == Number(id.replace("opt-", ""));
          })[0];
          if (!track) {
            track = highlight_datum.filter(function (d) {
              return d._id == Number(id.replace("opt-", ""));
            })[0];
          }

          var track_name = track.name;

          orders.push(track_name);
        });
      LIBNAME.Change_order(orders);
    },
  });

  Get_job_status(session_id);

  // Fill data information
  $.ajaxSettings.async = false;
  $.ajax({
    method: "get",
    url: php_path + "/get_available_omicsdata.php",
    data: {
      accession: prj,
    },
    success: function (data) {
      track_data = JSON.parse(data);

      track_data.data.forEach(function (gr) {
        if (
          gr.data_type.indexOf("Genome") == -1 &&
          gr.data_type != "Gene annotation" &&
          gr.data_type != "Synteny"
        ) {
          gr.info.forEach(function (tis) {
            tis.sample_info.forEach(function (dat) {
              dat.name = dat.data_id;
              dat._id = dat.data_id;
              dat.tissue = tis.tissue;
              dat.type = gr.data_type;

              if (dat.type.indexOf("interaction") != -1) {
                dat.vis = ["interact-ribbon", "interact-line", "heatmap"];
              } else if (dat.type == "Gene annotation") {
                dat.vis = ["gene"];
              } else {
                dat.vis = ["bar", "line", "area", "point"];
              }

              multiomics_datum.push(dat);
            });
          });
        } else {
          if (gr.data_type != "Synteny") {
            gr.info.forEach(function (tis) {
              tis.sample_info.forEach(function (dat) {
                dat.name = dat.data_id;
                dat._id = dat.data_id;
                dat.tissue = tis.tissue;
                dat.type = gr.data_type;

                if (dat.type.indexOf("interaction") != -1) {
                  dat.vis = ["interact-ribbon", "interact-line", "heatmap"];
                } else if (dat.type == "Gene annotation") {
                  dat.vis = ["gene"];
                } else {
                  dat.vis = ["bar", "line", "area", "point"];
                }

                genomics_datum.push(dat);
              });
            });
          }
        }
      });
    },
  });

  $.ajax({
    method: "get",
    url: php_path + "/get_available_highlight.php",
    data: {
      accession: prj,
    },
    success: function (dat) {
      highlight_data = JSON.parse(dat);

      highlight_data.data.forEach(function (dat) {
        if (dat.type.indexOf("interaction") != -1) {
          dat.vis = ["interact-ribbon", "interact-line", "heatmap"];
        } else if (dat.type == "Gene annotation") {
          dat.vis = ["gene"];
        } else {
          dat.vis = ["point"];
        }
        highlight_datum.push(dat);
      });
    },
  });

  $.ajax({
    method: "get",
    url: php_path + "/get_available_analysis.php",
    data: {
      accession: prj,
    },
    success: function (data) {
      available_data = JSON.parse(data);

      available_data["data"].forEach(function (data) {
        if (available_analyses.indexOf(data.type) == -1) {
          available_analyses.push(data.type);
        }
      });
      available_analyses.sort();

      var def_opt = "<option selected disabled>Choose an analysis</option>";
      $("#available_analyses").html(def_opt);
      available_analyses.forEach(function (opt) {
        var val = "";
        switch (opt) {
          case "HIC":
            val = "Chromatin interaction profile";
            break;
          case "CHIP":
            val = "Histone modification profile";
            break;
          case "METH":
            val = "Methylation profile";
            break;
          case "RNA":
            val = "Gene expression profile";
            break;
        }

        var new_opt = "<option id='" + opt + "_prof'>" + val + "</option>";
        $("#available_analyses").append(new_opt);
      });

      var types = multiomics_datum.map((d) => d.project + "." + d.spcs);
      var type_cnt = {};
      types.forEach(function (t) {
        if (t + "" in type_cnt) {
          type_cnt[t]++;
        } else {
          type_cnt[t] = 1;
        }
      });

      var available_opts = {};
      for (var opt in type_cnt) {
        if (type_cnt[opt] >= 2) {
          var [type, spc] = opt.split(".");
          available_opts[type] = 1;
        }
      }

      for (var opt in available_opts) {
        var val = "";
        var comp_type = "";
        switch (opt) {
          case "Epigenome_chip":
            val = "Histone modification comparison";
            comp_type = "CHIP";
            break;
          case "Epigenome_meth":
            val = "Methylation comparison";
            comp_type = "METH";
            break;
          case "Epigenome_hic":
            val = "Chromatin interaction comparison";
            comp_type = "HIC";
            break;
          case "Transcriptome":
            val = "Gene expression comparison";
            comp_type = "RNA";
            break;
        }
        var new_opt =
          "<option id='" + comp_type + "_comp'>" + val + "</option>";
        $("#available_analyses").append(new_opt);
      }

      Make_genomics_tracks(genomics_datum, "#gtable");
      Make_omics_tracks(multiomics_datum, "#mtable");
      Make_highlight_tracks(highlight_datum, "#htable");
    },
  });

  $.ajaxSettings.async = true;

  $("#aid").html(prj);
  Get_syntenyInfo(prj);

  if ("Minimum resolution (bp)" in syntenyInfo) {
    var min_resol = syntenyInfo["Minimum resolution (bp)"];
    $("#input_resol").attr("min", min_resol);
    $("#tick_resol").attr("min", min_resol);

    $("#input_resol").value = min_resol;
    $("#tick_resol").val(min_resol);
  }
  Fill_dataInfo(syntenyInfo, ".descript");

  // Draw data
  var data = syntenyInfo["path"];
  var sf_config = {
    canvas: "main_canvas",
    layout: "linear",
    synteny_data: data,
  };

  var resol = min_resol;
  LIBNAME.Draw_synteny(sf_config, resol);

  var spcs = LIBNAME.Get_species();
  spcs.forEach(function (spc, i) {
    $("#vis_spc").append("<option value=" + i + ">" + spc + "</option>");
  });

  var newconfig = {zoom: "true", phpscr_path: php_path};
  LIBNAME.Update_params(newconfig, "mo");

  // User Interface
  $("#vis_circ").click(function () {
    var config = {
      layout: "circular",
    };
    $(".btn-layout").removeClass("btn-dark");
    $("#vis_linear").addClass("btn-light");
    $("#vis_circ").addClass("btn-dark");
    LIBNAME.Update_params(config, "sf");
  });

  $("#vis_linear").click(function () {
    var config = {
      layout: "linear",
    };

    $(".btn-layout").removeClass("btn-dark");
    $("#vis_linear").addClass("btn-dark");
    $("#vis_circ").addClass("btn-light");
    LIBNAME.Update_params(config, "sf");
  });

  $("#vis_detail").click(function () {
    var spc = $("#vis_spc").val();
    var pos = $("#vis_reg").val().replaceAll(",", "");

    if (!pos) {
        alert("Please enter a chromosome region or gene name.");
        return;
    }

    if (pos.includes(":")) {
        var reg = /^(.+):(\d+)(?:-(\d+))?$/;
        var match = pos.match(reg);

        if (!match) {
            alert("Invalid chromosome region.");
            return;
        }

        if (match[3] !== undefined &&
            Number(match[3]) < Number(match[2])) {
            alert("End position should be larger than start position.");
            return;
        }

        LIBNAME.Show_region([spc, pos]);
        return;
    }

    LIBNAME.Search_gene(spc, pos);

  });

  $("#zoomin").click(function () {
    $("#zoomin_checker").modal("hide");

    var target = $("#alert_newcoord");
    var region = [
      target.attr("spc"),
      target.attr("chr1"),
      target.attr("pos1"),
      target.attr("chr2"),
      target.attr("pos2"),
    ];

    LIBNAME.Move_to(region);
  });

  $("#input_resol").on("mousemove", function () {
    var resol = $(this).val();
    $("#tick_resol").val(resol);
  });

  $("#tick_resol, #input_resol").on("change", function () {
    var resol = parseInt($(this).val());
    if ($(this).attr("id") == "tick_resol") {
      $("#input_resol").val(resol);
    } else {
      $("#tick_resol").val(resol);
    }
    LIBNAME.Update_synteny(resol);
  });

  $(document).on("change", ".filter", function () {
    var filtered = {};
    var type = $(this).hasClass("filter_multi")
      ? "multi"
      : $(this).hasClass("filter_geno")
      ? "geno"
      : $(this).hasClass("filter_hl")
      ? "hl"
      : $(this).hasClass("filter_job")
      ? "job"
      : "Unknown";

    filtered["checked"] = [];
    $(".filter_" + type + ".filter_checked:checked").each(function () {
      filtered["checked"].push($(this).val());
    });

    if (
      $(".filter_" + type + ".filter_checked").length !=
      filtered["checked"].length
    ) {
      $("#dropdown_view_" + type).addClass("btn-dark");
      $("#dropdown_view_" + type).removeClass("btn-outline-dark");
    } else {
      $("#dropdown_view_" + type).removeClass("btn-dark");
      $("#dropdown_view_" + type).addClass("btn-outline-dark");
    }

    if (type == "multi") {
      var feature_list = ["type", "spcs", "tissue", "cell_type", "sample_id"];
    } else if (type == "geno") {
      var feature_list = ["type", "spcs", "sample_id"];
    } else if (type == "hl") {
      var feature_list = ["type"];
    } else if (type == "job") {
      var feature_list = ["Status", "Main"];
    }

    feature_list.forEach(function (ft) {
      if (ft != "name" && ft != "vis" && ft != "id" && ft != "path") {
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
      }
    });

    if (type == "multi") {
      select_data_m = multiomics_datum.filter(function (data) {
        if (
          filtered["checked"].indexOf("check") != -1 &&
          filtered["checked"].indexOf("uncheck") == -1 &&
          vis_tracks.indexOf(data._id) == -1
        ) {
          return false;
        }
        if (
          filtered["checked"].indexOf("check") == -1 &&
          filtered["checked"].indexOf("uncheck") != -1 &&
          vis_tracks.indexOf(data._id) != -1
        ) {
          return false;
        }
        if (
          filtered["checked"].indexOf("check") == -1 &&
          filtered["checked"].indexOf("uncheck") == -1
        ) {
          return false;
        }

        for (var i = 0; i < feature_list.length; ++i) {
          var ft = feature_list[i];
          if (
            ft != "name" &&
            ft != "vis" &&
            ft != "id" &&
            ft != "path" &&
            filtered[ft].indexOf(data[ft]) == -1
          ) {
            return false;
          }
        }

        return true;
      });

      Make_pagination(select_data_m.length, type);
    } else if (type == "geno") {
      select_data_g = genomics_datum.filter(function (data) {
        if (
          filtered["checked"].indexOf("check") != -1 &&
          filtered["checked"].indexOf("uncheck") == -1 &&
          vis_tracks.indexOf(data._id) == -1
        ) {
          return false;
        }
        if (
          filtered["checked"].indexOf("check") == -1 &&
          filtered["checked"].indexOf("uncheck") != -1 &&
          vis_tracks.indexOf(data._id) != -1
        ) {
          return false;
        }
        if (
          filtered["checked"].indexOf("check") == -1 &&
          filtered["checked"].indexOf("uncheck") == -1
        ) {
          return false;
        }

        for (var i = 0; i < feature_list.length; ++i) {
          var ft = feature_list[i];
          if (
            ft != "name" &&
            ft != "vis" &&
            ft != "id" &&
            ft != "path" &&
            filtered[ft].indexOf(data[ft]) == -1
          ) {
            return false;
          }
        }

        return true;
      });

      Make_pagination(select_data_g.length, type);
    } else if (type == "hl") {
      select_data_h = highlight_datum.filter(function (data) {
        if (
          filtered["checked"].indexOf("check") != -1 &&
          filtered["checked"].indexOf("uncheck") == -1 &&
          vis_tracks.indexOf(data._id) == -1
        ) {
          return false;
        }
        if (
          filtered["checked"].indexOf("check") == -1 &&
          filtered["checked"].indexOf("uncheck") != -1 &&
          vis_tracks.indexOf(data._id) != -1
        ) {
          return false;
        }
        if (
          filtered["checked"].indexOf("check") == -1 &&
          filtered["checked"].indexOf("uncheck") == -1
        ) {
          return false;
        }


        for (var i = 0; i < feature_list.length; ++i) {
          var ft = feature_list[i];
          if (
            ft != "name" &&
            ft != "vis" &&
            ft != "id" &&
            ft != "path" &&
            filtered[ft].indexOf(data[ft]) == -1
          ) {
            return false;
          }
        }

        return true;
      });

      Make_pagination(select_data_h.length, type);
    } else if (type == "job") {
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
    }
  });

  $(document).on("change", ".track-show", function () {
    var id = parseInt(this.value);
    var type = "multi";
    var cur_data = multiomics_datum.filter(function (d) {
      return d._id == id;
    })[0];

    if (cur_data === undefined) {
      type = "geno";
      cur_data = genomics_datum.filter(function (d) {
        return d._id == id;
      })[0];
    }

    if (cur_data === undefined) {
      type = "hl";
      cur_data = highlight_datum.filter(function (d) {
        return d._id == id;
      })[0];
    }

    if ($(this).is(":checked")) {
      vis_tracks.push(id);

      if (type == "multi") {
        Show_option(cur_data, "#omics-setting");
      } else if (type == "geno") {
        Show_option(cur_data, "#genomics-setting");
      } else if (type == "hl") {
        Show_option(cur_data, "#highlight-setting");
        var highlight_path = cur_data.data_path;

        $.ajaxSettings.async = false;
        $.ajax({
          url: php_path + "/get_highlight.php",
          type: "get",
          data: {
            path: highlight_path,
          },
        }).done(function (result) {
          var dat = jQuery.parseJSON(result);
          var color = $("#pincolor-" + id).val();

          var curdat = highlight_datum.filter(function (d) {
            return d._id == id;
          })[0];

          if (curdat) {
            curdat["data"] = dat;
            if (dat.value.length && "spc1" in dat.value[0]) {
              var parse_dat = [];
              var save_pos = {};
              dat.value.forEach(function (d) {
                var dat1 = {
                  spc: d.spc1,
                  chr: d.chr1,
                  start: Number(d.start1),
                  end: Number(d.end1),
                  max: d.max,
                  min: d.min,
                  avg: d.avg,
                  pval: d.pval,
                  qval: d.qval,
                };

                var dat2 = {
                  spc: d.spc2,
                  chr: d.chr2,
                  start: Number(d.start2),
                  end: Number(d.end2),
                  max: d.max,
                  min: d.min,
                  avg: d.avg,
                  pval: d.pval,
                  qval: d.qval,
                };

                var pos1_str =
                  d.spc1 + "_" + d.chr1 + "_" + d.start1 + "_" + d.end1;
                var pos2_str =
                  d.spc1 + "_" + d.chr1 + "_" + d.start1 + "_" + d.end1;

                var newpos = [];
                if (!(pos1_str in save_pos)) {
                  newpos.push(dat1);
                  save_pos[pos1_str] = 1;
                }
                if (!(pos2_str in save_pos)) {
                  newpos.push(dat2);
                  save_pos[pos2_str] = 1;
                }

                parse_dat = $.merge(parse_dat, newpos);
              });

              curdat["data"].value = parse_dat;
            }
          }

          var cutoff;
          var visdata;
          if (Object.keys(dat.cutoff).length != 0) {
            cutoff = curdat["data"].cutoff[10]["avg"];
            visdata = curdat.data.value.filter(function (d) {
              return parseFloat(d["avg"]) > cutoff;
            });
          } else {
            cutoff = 0.05;
            visdata = curdat.data.value.filter(function (d) {
              return parseFloat(d["qval"]) < cutoff;
            });
          }

          LIBNAME.Add_highlihgt_regions(id, visdata, color);
        });
        $.ajaxSettings.async = true;
      }

      Make_omicsconfig(cur_data);

      downsample_method[id] = $(
        "#method_downsample-" + id + " option:selected"
      ).val();
    } else {
      vis_tracks = vis_tracks.filter(function (ft) {
        return ft != id;
      });

      $("#opt-" + id).remove();
      LIBNAME.Delete_track(cur_data.name);
      if (type == "hl") {
        LIBNAME.Remove_highlihgt_regions(id);
      }
    }
  });

  // Activate the first track of each table
  $('#gtrackdata tr:first td:first input').prop("checked", true);
  $('#gtrackdata tr:first td:first input').trigger("change");
  $('#mtrackdata tr:first td:first input').prop("checked", true);
  $('#mtrackdata tr:first td:first input').trigger("change");
    //$('#htrackdata tr:first td:first input').prop("checked", true);
    //$('#htrackdata tr:first td:first input').trigger("change");

  $(document).on("change", ".type", function () {
    var id = $(this).attr("id").replace("type-", "");

    var data = multiomics_datum.filter(function (d) {
      return d._id == id;
    })[0];

    if (data === undefined) {
      data = genomics_datum.filter(function (d) {
        return d._id == id;
      })[0];
    }

    if (data === undefined) {
      data = highlight_datum.filter(function (d) {
        return d._id == id;
      })[0];
    }

    var type = $(this).val();
    if (type === undefined) {
      type = "gene";
    }

    var new_config = {
      name: data.name,
      type: type,
    };

    LIBNAME.Update_params_omics(new_config);
  });

  $(document).on("change", ".method_downsample, .minlen", function () {
    var id = $(this)
      .attr("id")
      .replace("method_downsample-", "")
      .replace("minlen-", "");

    var datumlist = [genomics_datum, multiomics_datum, highlight_datum];
    var data;
    var _d = 0;
    while (data === undefined) {
      data = datumlist[_d].filter(function (d) {
        return d._id == id;
      })[0];
      _d++;
    }

    var method = $(this).val();
    $("#downsample_alert_target").attr("target", data._id);

    if (method == "na") {
      $("#downsample_alert").modal("show");
      if (data.type == "Gene annotation") {
        $("#minlen-" + id).attr("disabled", true);
      }
    } else {
      if (data.type == "Gene annotation") {
        $("#minlen-" + id).attr("disabled", false);
      }
      Change_dowmsample_method(data._id, method);
    }
  });

  $(document).on("change", ".method_diff_analysis", function () {
    var id = $(this).attr("id").replace("method_diff_analysis-", "");
    var method = $(this).val();

    var data = highlight_datum.filter(function (d) {
      return d._id == id;
    })[0];

    var conf = {
      name: data.name,
      downsample: method,
    };

    var color = $("#pincolor-" + id).val();

    var cutoff = 0;
    var method = $("#method_diff_analysis-" + id + " option:selected").val();
    var cutoff_type = $("#cutofftype-" + id).val();
    var cutoff_value = parseFloat($("#cutoffvalue-" + id).val());

    var curdat = highlight_datum.filter(function (d) {
      return d._id == id;
    })[0];

    if (cutoff_type == "value") {
      cutoff = cutoff_value;
    } else {
      cutoff = curdat["data"].cutoff[cutoff_value][method];
    }

    var visdata = curdat.data.value.filter(function (d) {
      return parseFloat(d[method]) > cutoff;
    });

    LIBNAME.Update_params_omics(conf);
    LIBNAME.Update_highlight_regions(id, visdata, color);
  });

  $(document).on("change", ".cutoffvalue, .cutofftype, .pincolor", function () {
    var id = $(this)
      .attr("id")
      .replace("cutofftype-", "")
      .replace("cutoffvalue-", "")
      .replace("pincolor-", "");

    var color = $("#pincolor-" + id).val();

    var cutoff = 0;
    var method = $("#method_diff_analysis-" + id + " option:selected").val();
    var cutoff_type = $("#cutofftype-" + id).val();
    var cutoff_value = parseFloat($("#cutoffvalue-" + id).val());

    var curdat = highlight_datum.filter(function (d) {
      return d._id == id;
    })[0];

    if (
      cutoff_type == "value" ||
      cutoff_type == "pval" ||
      cutoff_type == "qval"
    ) {
      cutoff = cutoff_value;
    } else {
      cutoff = curdat["data"].cutoff[cutoff_value][method];
    }

    var visdata = [];
    if (cutoff_type == "pval" || cutoff_type == "qval") {
      visdata = curdat.data.value.filter(function (d) {
        return parseFloat(d[cutoff_type]) < cutoff;
      });
    } else {
      visdata = curdat.data.value.filter(function (d) {
        return parseFloat(d[method]) > cutoff;
      });
    }
    LIBNAME.Update_highlight_regions(id, visdata, color);
  });

  $(document).on("change", ".yauto", function () {
    var id = $(this).attr("id").replace("auto-", "");

    var datumlist = [genomics_datum, multiomics_datum, highlight_datum];
    var data;
    var _d = 0;
    while (data === undefined) {
      data = datumlist[_d].filter(function (d) {
        return d._id == id;
      })[0];
      _d++;
    }

    var type = $("#type-" + id).val();
    if (type === undefined) {
      type = "gene";
    }

    var range = ["auto", "auto"];
    if ($(this).is(":checked")) {
      $("#ymin-" + id).prop("disabled", true);
      $("#ymax-" + id).prop("disabled", true);
    } else {
      $("#ymin-" + id).prop("disabled", false);
      $("#ymax-" + id).prop("disabled", false);

      var [min, max] = LIBNAME.Get_range(data.name);
      $("#ymin-" + id).val(min);
      $("#ymax-" + id).val(max);
      range = [min, max];

      ranges[id] = [$("#ymin-" + id).val(), $("#ymax-" + id).val()];
    }

    var new_config = {
      name: data.name,
      range: range,
    };

    LIBNAME.Update_params_omics(new_config);
  });

  $(document).on("change", ".yrange", function () {
    var id = $(this).attr("id").replace("ymin-", "").replace("ymax-", "");

    if (
      parseFloat($("#ymax-" + id).val()) < parseFloat($("#ymin-" + id).val())
    ) {
      $("#ymin-" + id).val(ranges[id][0]);
      $("#ymax-" + id).val(ranges[id][1]);

      alert("Minimum value should be smaller than Maximum value.");
      return;
    }

    ranges[id] = [$("#ymin-" + id).val(), $("#ymax-" + id).val()];

    var datumlist = [genomics_datum, multiomics_datum, highlight_datum];
    var data;
    var _d = 0;
    while (data === undefined) {
      data = datumlist[_d].filter(function (d) {
        return d._id == id;
      })[0];
      _d++;
    }

    var new_config = {
      name: data.name,
      range: [
        parseFloat($("#ymin-" + id).val()),
        parseFloat($("#ymax-" + id).val()),
      ],
    };

    LIBNAME.Update_params_omics(new_config);
  });

  // Run jobs
  $(document).on("change", "#available_analyses", function () {
    $(".dataset_data").html("<option disabled>Available data</option>");

    var analysis = $(this).children(":selected").attr("id");
    var [data, type] = analysis.split("_");

    var def_opt = "<option selected disabled>Species</option>";
    $(".dataset_species").html(def_opt);

    if (type == "prof") {
      $("#comp_col").hide();
      $("#prof_col").show();
      $("#comp_datalist").removeClass("is-invalid");

      var available_spc = available_data["data"]
        .filter(function (dat) {
          return dat.type == data;
        })
        .map((d) => d.spcs)[0];

      available_spc = [...new Set(available_spc)];
      available_spc = available_spc.sort();

      available_spc.forEach(function (spc) {
        var new_opt =
          "<option id='" + spc + "'>" + spc.replaceAll("_", " ") + "</option>";
        $(".dataset_species").append(new_opt);
      });
    } else {
      var available_spc = multiomics_datum
        .filter(function (d) {
          if (analysis == "CHIP_comp") {
            return d.project == "Epigenome_chip";
          } else if (analysis == "HIC_comp") {
            return d.project == "Epigenome_hic";
          } else if (analysis == "METH_comp") {
            return d.project == "Epigenome_meth";
          } else if (analysis == "RNA_comp") {
            return d.project == "Transcriptome";
          } else {
            console.log("Error: Unknown analysis type: " + analysis);
          }
        })
        .map((d) => d.spcs);
      available_spc = [...new Set(available_spc)];
      available_spc = available_spc.sort();

      available_spc.forEach(function (spc) {
        var new_opt =
          "<option id='" + spc + "'>" + spc.replaceAll("_", " ") + "</option>";
        $(".dataset_species").append(new_opt);
      });

      $("#dataset_datalist").removeClass("is-invalid");
      $("#comp_datalist").empty();
      $("#comp_col").show();
      $("#prof_col").hide();
    }

    $(".params").hide();
    $("#" + analysis + "_param").show();
  });

  $(document).on("change", ".dataset_species", function () {
    var select_id = $(this).attr("id");
    var dataset_id = select_id.split("_")[0];
    var data_list_id = select_id.replace("species", "datalist");

    var species = $(this).children(":selected").attr("id");
    var [data, type] = $("#available_analyses")
      .children(":selected")
      .attr("id")
      .split("_");

    if (type == "prof") {
      $.ajaxSettings.async = false;
      $.ajax({
        method: "get",
        url: php_path + "/get_sampledatalist.php",
        data: {
          accession: prj,
          species: species,
          datatype: data,
        },
        success: function (data) {
          data = JSON.parse(data);

          $("#" + data_list_id).html("");
          data["samples"].forEach(function (d) {
            var new_opt =
              '<option disabled style="background-color:#212529; color:white;">' +
              d.sample +
              "</option>";
            $("#" + data_list_id).append(new_opt);

            d.ids.forEach(function (id) {
              var new_opt =
                '<option id="' +
                id +
                "_" +
                dataset_id +
                '" value="' +
                id +
                '">' +
                id +
                "</option>";
              $("#" + data_list_id).append(new_opt);
            });
          });
        },
      });
      $.ajaxSettings.async = true;
    } else {
      var spc_data = multiomics_datum.filter(function (d) {
        return d.spcs == species;
      });

      var spc_type_data = [];
      if (data == "CHIP") {
        spc_type_data = spc_data.filter(function (d) {
          return d.project == "Epigenome_chip";
        });
      } else if (data == "HIC") {
        spc_type_data = spc_data.filter(function (d) {
          return d.project == "Epigenome_hic";
        });
      } else if (data == "METH") {
        spc_type_data = spc_data.filter(function (d) {
          return d.project == "Epigenome_meth";
        });
      } else if (data == "RNA") {
        spc_type_data = spc_data.filter(function (d) {
          return d.project == "Transcriptome";
        });
      }

      if (spc_type_data.length) {
        var selected_ids = [];
        $("#comp_datalist option").each(function () {
          selected_ids.push($(this).val());
        });

        $("#" + data_list_id).html("");
        spc_type_data.forEach(function (d) {
          var disabled =
            selected_ids.indexOf(d.data_id.toString()) == -1 ? "" : "disabled";

          var new_opt =
            '<option id=prof-"' +
            d.data_id +
            '" value="' +
            d.data_id +
            '" ' +
            disabled +
            ">" +
            d.data_id +
            " (" +
            d.type +
            "; " +
            d.tissue +
            "; " +
            d.sample_id +
            " )</option>";
          $("#" + data_list_id).append(new_opt);
        });
      } else {
        $("#" + data_list_id).html("<option disabled>Available data</option>");
      }
    }
  });

  $(document).on("change", ".dataset_data", function () {
    var [data, type] = $("#available_analyses")
      .children(":selected")
      //.attr("id")
      .val()
      .split("_");

    var select_id = $(this).attr("id");
  });

  $("#use_data").on("click", function () {
    var selected_ids = [];
    $("#comp_datalist option").each(function () {
      selected_ids.push($(this).val());
    });

    var selected_data = multiomics_datum.filter(function (d) {
      return selected_ids.indexOf(d.data_id.toString()) != -1;
    });

    var selecting_data = multiomics_datum.filter(function (d) {
      return $("#dataset_datalist").val().indexOf(d.data_id.toString()) != -1;
    });

    var selected_type = selected_data.map((d) => d.project);
    var selecting_type = selecting_data.map((d) => d.project);

    var unique_type = $.unique($.merge(selected_type, selecting_type));
    if (unique_type.length != 1) {
      alert("Different omics types!");
    } else {
      selecting_data.forEach(function (d) {
        var new_opt =
          '<option id=prof-"' +
          d.data_id +
          '" value="' +
          d.data_id +
          '">' +
          d.data_id +
          " (" +
          d.spcs +
          "; " +
          d.type +
          "; " +
          d.tissue +
          "; " +
          d.sample_id +
          " )</option>";
        $("#comp_datalist").append(new_opt);
      });
    }

    $("#dataset_datalist option").each(function () {
      if ($("#dataset_datalist").val().indexOf($(this).attr("value")) != -1) {
        $(this).prop("disabled", true);
      }
    });
  });

  $("#unuse_data").on("click", function () {
    var removing_data = $("#comp_datalist").val();

    $("#dataset_datalist option").each(function () {
      if (removing_data.indexOf($(this).attr("value")) != -1) {
        $(this).prop("disabled", false);
      }
    });

    $("#comp_datalist option").each(function () {
      if (removing_data.indexOf($(this).attr("value")) != -1) {
        $(this).remove();
      }
    });
  });

  $("#submit").on("click", function () {
    var analysis = $("#available_analyses").children(":selected").attr("id");

    if (analysis === undefined) {
      $("#available_analyses").addClass("is-invalid");
      $("#invalid-feedback_analyses").show();

      return false;
    } else {
      $("#available_analyses").removeClass("is-invalid");
      $("#invalid-feedback_analyses").hide();
    }

    var [data, type] = analysis.split("_");

    var email = ($("#email").val() === "") ? "nomail" : $("#email").val();

    var opts = {};
    var ids_ar = [];
    var ids = "";
    if (type == "prof") {
      $("#" + analysis + "_param input").each(function (opt) {
        opts[$(this).attr("id")] = $(this).val();
      });

      $("#dataset_datalist")
        .children(":selected")
        .each(function () {
          ids_ar.push($(this).val().split("(")[0]);
        });
    } else {
      $("#comp_datalist option").each(function () {
        ids_ar.push($(this).val());
      });
    }
    ids = ids_ar.join(" ");

    var pass = Check_form(type, ids);
    if (!pass) {
      return false;
    }

    analysis = data;

    var message = "Job is succesfully submitted!";
    if (type == "prof") {
      $.ajax({
        method: "get",
        url: php_path + "/check_prof_data.php",
        data: {
          syntenyid: prj,
          analysis: analysis,
          session: session_id,
          sampleids: ids,
          email: email,
          opts: JSON.stringify(opts),
        },
        success: function (data) {
          if (data == "exist") {
            message =
              "The analysis result using the selected sample(s) already exists or the same analysis is already running!";
          } else {
            $.ajax({
              method: "get",
              url: php_path + "/run_multiomics_pipeline.php",
              data: {
                syntenyid: prj,
                analysis: analysis,
                session: session_id,
                sampleids: ids,
                email: email,
                opts: JSON.stringify(opts),
              },
            });
          }
          alert(message);
        },
      });
    } else {
      $.ajax({
        method: "get",
        url: php_path + "/check_diff_data.php",
        data: {
          syntenyid: prj,
          analysis: analysis,
          session: session_id,
          sampleids: ids,
          email: email,
        },
        success: function (data) {
          if (data == "exist") {
            message =
              "The differential analysis result using these samples already exists!";
          } else if (data == "unavailable") {
            message =
              "The requested analysis is currently not available.\n(Cross-species differential analysis using Hi-C data.)";
          } else if (data == "unavailable_") {
            message =
              "The requested analysis is currently not available.\n(Cross-species differential analysis using transcriptome data.)";
          } else if (data == "unavailable2") {
            message =
              "More than three samples for at least one species is needed for the cross-species differential analysis.";
          } else if (data == "unavailable3") {
            message =
              "The requested analysis is currently not available.\n(There is no base-level matching information.)";
          } else if (data == "unavailable4") {
            message = "The requested analysis is currently not available.\n";
          } else {
            $.ajax({
              method: "get",
              url: php_path + "/run_diff_pipeline.php",
              data: {
                syntenyid: prj,
                analysis: analysis,
                session: session_id,
                sampleids: ids,
                email: email,
              },
            });
          }
          alert(message);
        },
      });
    }

    $("#analysis_form").each(function () {
      this.reset();
      $(".dataset_data").html("<option disabled>Available data</option>");
      $("#comp_datalist").empty();
    });

    $(".params").hide();
    $(".accordion-button").addClass("collapsed");
    $("#collapseOne").removeClass("show");

    Get_job_status(session_id);
  });
});

function Make_genomics_tracks(data, selector) {
  select_data_g = data;

  // Make table header
  features = {};
  select_data_g.forEach(function (d, i) {
    for (var ft in d) {
      if (!(ft in features)) {
        features[ft] = [];
      }
    }
    d._id = track_id++;
  });

  select_data_g.forEach(function (d) {
    for (var ft in features) {
      if (!(ft in d) || d[ft] == "") {
        //d[ft] = "undefined";
        d[ft] = "-";
      }
      features[ft].push(d[ft]);
    }
  });

  var thead =
    "<tr> \
      <td class='col-1'> \
        <div class='btn-group d-grid gap-2'> \
          <button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_view_geno' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>View</button> \
          <div class='dropdown-menu p-4 text-muted' id='view_list_geno'> \
            <div class='form-check'> \
              <input class='form-check-input filter filter_geno filter_checked' type='checkbox' value='check' id='filter_check_geno' checked><label class='form-check-label' for='filter_check'> Checked </label> \
            </div> \
            <div class='form-check'> \
              <input class='form-check-input filter filter_geno filter_checked' type='checkbox' value='uncheck' id='filter_uncheck_geno' checked><label class='form-check-label' for='filter_uncheck'> Unchecked </label> \
            <div> \
          </div> \
        <div> \
      </td> \
      <td><div class='py-1'>ID</div></td>";

  var feature_list = ["type", "spcs", "sample_id"];
  feature_list.forEach(function (ft) {
    features[ft] = [...new Set(features[ft])];
    if (
      ft != "name" &&
      ft != "vis" &&
      ft != "id" &&
      ft != "path" &&
      ft != "params" &&
      ft != "data_id" &&
      ft != "data_path" &&
      ft != "project"
    ) {
      var colname = ft;
      if (ft == "spcs") {
        colname = "Species";
      } else if (ft == "sample_id") {
        colname = "Source assembly";
      } else if (ft == "type") {
        colname = "Type";
      }

      thead +=
        "<td> \
        <div class='btn-group d-grid gap-2'> \
        <button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_" +
        ft +
        "_geno' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>" +
        colname +
        "</button> \
        <div class='dropdown-menu p-4 text-muted' id='" +
        ft +
        "_list_geno'> ";

      features[ft].forEach(function (val) {
        thead +=
          "<div class='form-check'> \
          <input class='form-check-input filter filter_geno filter_" +
          ft +
          "' type='checkbox' value='" +
          val +
          "' id='filter_" +
          val +
          "_geno' checked><label class='form-check-label' for='filter_" +
          val +
          "_geno'> " +
          val +
          " </label> \
        </div>";
      });

      thead +=
        "</div> \
      </div> \
    </td>";
    }
  });

  thead += "</tr>";
  $(selector).html(thead);

  // Make table pagination
  Make_pagination(data.length, "geno");
  $("#page1_geno").trigger("click");
}

function Make_omics_tracks(data, selector) {
  select_data_m = data;

  // Make table header
  features = {};
  select_data_m.forEach(function (d, i) {
    for (var ft in d) {
      if (!(ft in features)) {
        features[ft] = [];
      }
    }
    d._id = track_id++;
  });

  select_data_m.forEach(function (d) {
    for (var ft in features) {
      if (!(ft in d) || d[ft] == "") {
        //d[ft] = "undefined";
        d[ft] = "-";
      }
      features[ft].push(d[ft]);
    }
  });

  var thead =
    "<tr> \
      <td class='col-1'> \
        <div class='btn-group d-grid gap-2'> \
          <button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_view_multi' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>View</button> \
          <div class='dropdown-menu p-4 text-muted' id='view_list_multi'> \
            <div class='form-check'> \
              <input class='form-check-input filter filter_multi filter_checked' type='checkbox' value='check' id='filter_check_multi' checked><label class='form-check-label' for='filter_check'> Checked </label> \
            </div> \
            <div class='form-check'> \
              <input class='form-check-input filter filter_multi filter_checked' type='checkbox' value='uncheck' id='filter_uncheck_multi' checked><label class='form-check-label' for='filter_uncheck'> Unchecked </label> \
            <div> \
          </div> \
        <div> \
      </td> \
      <td><div class='py-1'>ID</div></td>";

  var feature_list = [
    "type",
    "spcs",
    "tissue",
    "cell_type",
    "sample_id",
    "param_path",
  ];
  feature_list.forEach(function (ft) {
    features[ft] = [...new Set(features[ft])];
    if (
      ft != "name" &&
      ft != "vis" &&
      ft != "id" &&
      ft != "path" &&
      ft != "params" &&
      ft != "data_id" &&
      ft != "data_path" &&
      ft != "project"
    ) {
      var colname = ft;
      if (ft == "spcs") {
        colname = "Species";
      } else if (ft == "cell_type") {
        colname = "Cell type";
      } else if (ft == "sample_id") {
        colname = "Input sample(s)";
      } else if (ft == "type") {
        colname = "Type";
      } else if (ft == "tissue") {
        colname = "Tissue";
      } else if (ft == "param_path") {
        colname = "Parameters";
      }

      if (ft != "param_path") {
        thead +=
          "<td> \
          <div class='btn-group d-grid gap-2'> \
          <button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_" +
          ft +
          "_multi' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>" +
          colname +
          "</button> \
          <div class='dropdown-menu p-4 text-muted' id='" +
          ft +
          "_list_multi'> ";

        features[ft].forEach(function (val) {
          thead +=
            "<div class='form-check'> \
            <input class='form-check-input filter filter_multi filter_" +
            ft +
            "' type='checkbox' value='" +
            val +
            "' id='filter_" +
            val +
            "_multi' checked><label class='form-check-label' for='filter_" +
            val +
            "_multi'> " +
            val.replaceAll("_", " ") +
            " </label> \
          </div>";
        });
      } else {
        thead += "<td><div class='py-1'>Parameters</div></td>";
      }

      thead +=
        "</div> \
      </div> \
    </td>";
    }
  });

  thead += "</tr>";
  $(selector).html(thead);

  // Make table pagination
  Make_pagination(data.length, "multi");
  $("#page1_multi").trigger("click");
}

function Make_highlight_tracks(data, selector) {
  select_data_h = data;

  // Make table header
  features = {};
  select_data_h.forEach(function (d, i) {
    for (var ft in d) {
      if (!(ft in features)) {
        features[ft] = [];
      }
    }
    d._id = track_id++;
    d.name = d.data_id;
  });

  select_data_h.forEach(function (d) {
    for (var ft in features) {
      if (!(ft in d) || d[ft] == "") {
        //d[ft] = "undefined";
        d[ft] = "-";
      }
      features[ft].push(d[ft]);
    }
  });

  var thead =
    "<tr> \
      <td class='col-1' style='width:15%;' colspan=2> \
        <div class='btn-group d-grid gap-2'> \
          <button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_view_hl' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>View</button> \
          <div class='dropdown-menu p-4 text-muted' id='view_list_hl'> \
            <div class='form-check'> \
              <input class='form-check-input filter filter_hl filter_checked' type='checkbox' value='check' id='filter_check_hl' checked><label class='form-check-label' for='filter_check'> Checked </label> \
            </div> \
            <div class='form-check'> \
              <input class='form-check-input filter filter_hl filter_checked' type='checkbox' value='uncheck' id='filter_uncheck_hl' checked><label class='form-check-label' for='filter_uncheck'> Unchecked </label> \
            <div> \
          </div> \
        <div> \
      </td> \
      <td style='width:8%;'><div class='py-1'>ID</div></td>";

  var feature_list = ["type", "spcs"];
  feature_list.forEach(function (ft) {
    features[ft] = [...new Set(features[ft])];
    if (
      ft != "name" &&
      ft != "vis" &&
      ft != "id" &&
      ft != "path" &&
      ft != "params" &&
      ft != "data_id" &&
      ft != "data_path" &&
      ft != "project" &&
      ft != "spcs"
    ) {
      var colname = ft;
      var colspan = 1;
      var colwidth = "";
      if (ft == "spcs") {
        colname = "Species";
      } else if (ft == "type") {
        colname = "Type";
      } else if (ft == "result_type") {
        colname = "Analysis type";
      }

      thead +=
        "<td colspan='" +
        colspan +
        "'> \
        <div class='btn-group d-grid gap-2'> \
        <button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_" +
        ft +
        "_hl' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>" +
        colname +
        "</button> \
        <div class='dropdown-menu p-4 text-muted' id='" +
        ft +
        "_list_hl'> ";

      features[ft].forEach(function (val) {
        thead +=
          "<div class='form-check'> \
          <input class='form-check-input filter filter_hl filter_" +
          ft +
          "' type='checkbox' value='" +
          val +
          "' id='filter_" +
          val +
          "_hl' checked><label class='form-check-label' for='filter_" +
          val +
          "_hl'> " +
          val.replaceAll("_", " ") +
          " </label> \
        </div>";
      });

      thead +=
        "</div> \
      </div> \
    </td>";
    }
  });
  thead +=
    "<td colspan='2' style='width:55%'><div class='py-1'>Input profiles</div></td>";

  thead += "</tr>";
  $(selector).html(thead);

  // Make table pagination
  Make_pagination(select_data_h.length, "hl");
  $("#page1_hl").trigger("click");
}

// Function for pagination
var entries = 10,
  page_count = 5,
  page_num = 5,
  current_page = 1;

function Make_pagination(total_count, type) {
  if (type == "multi") {
    $("#mtrackdata").empty();
  } else if (type == "geno") {
    $("#gtrackdata").empty();
  } else if (type == "hl") {
    $("#htrackdata").empty();
  }

  $("#pages_" + type).empty();
  var total_page = Math.ceil(total_count / entries);
  var block = Math.ceil(current_page / page_count);
  var page1 = (block - 1) * page_count + 1;
  var page10 = page1 + page_count - 1;
  if (page10 > total_page) {
    page10 = total_page;
  }

  // Pagination
  var pagination =
    '<ul class="pagination pagination-sm justify-content-center">';
  pagination +=
    '<li class="page-item_' +
    type +
    '" +><a class="page-link" id="first-page_' +
    type +
    '" onclick="Update_pages(this, ' +
    total_count +
    ');">&laquo;</a></li>'; // First page
  pagination +=
    '<li class="page-item page-item_' +
    type +
    '"><a class="page-link" id="previous-page_' +
    type +
    '" onclick="Update_pages(this, ' +
    total_count +
    ');">&lsaquo;</a></li>'; // Previous page
  for (var i = page1; i <= page10; i++) {
    // Current page & Other pages
    pagination +=
      '<li class="page-item page-item_' +
      type +
      '"><a class="page-link" id="page' +
      i +
      "_" +
      type +
      '" onclick="Go_page(this, \'' +
      type +
      "')\">" +
      i +
      "</a></li>";
  }
  pagination +=
    '<li class="page-item page-item_' +
    type +
    '"><a class="page-link" id="next-page_' +
    type +
    '" onclick="Update_pages(this, ' +
    total_count +
    ');">&rsaquo;</a></li>'; // Next page
  pagination +=
    '<li class="page-item page-item_' +
    type +
    '"><a class="page-link" id="last-page_' +
    type +
    '" onclick="Update_pages(this, ' +
    total_count +
    ');">&raquo;</a></li>'; // Last page
  pagination += "</ul>";

  $("#pages_" + type).html(pagination);
  $("#page" + current_page + "_" + type).trigger("click");
}

function Go_page(e, type) {
  var select_data;

  if (type == "multi") {
    select_data = select_data_m;
  } else if (type == "geno") {
    select_data = select_data_g;
  } else if (type == "hl") {
    select_data = select_data_h;
  }

  var page_number = Number(e.id.replace("page", "").replace("_" + type, ""));
  var table = "";

  if (type == "multi") {
    table = "mtrackdata";
  } else if (type == "geno") {
    table = "gtrackdata";
  } else if (type == "hl") {
    table = "htrackdata";
  }

  $("#" + table).empty();

  var limit_from = (page_number - 1) * entries;
  var limit_to = limit_from + entries;

  var show_data = select_data.slice(limit_from, limit_to);
  show_data
    .sort((a, b) => {
      return a._id - b._id;
    })
    .forEach(function (d) {
      var checked = vis_tracks.indexOf(d._id) != -1 ? "checked" : "";
      //checked = d.type == "Gene annotation" ? "checked" : "";

      if (type == "multi") {
        var feature_list = [
          "type",
          "spcs",
          "tissue",
          "cell_type",
          "sample_id",
          "param_path",
        ];
      } else {
        var feature_list = ["type", "spcs", "sample_id"];
      }

      if (type == "hl") {
        var sample_spcs = d["sample_spcs"];
        var sample_spcs_n = sample_spcs.length;
        var [mainID, subID] = d.data_id.split(/\./);
        var new_id = subID == undefined ? d.data_id : mainID;
        var new_tr =
          "<tr>" +
          '<td style="text-align:center;"><input class="form-check-input track-show" type="checkbox" value="' +
          d._id +
          '" ' +
          checked +
          "></td>" +
          '<td style="text-align:left;"><label style="vertical-align:2px;">' +
          d.spcs.replace("_", " ") +
          "</label></td>";
        if ($("#htrackdata ." + new_id).length > 0) {
          new_tr += "";
        } else {
          new_tr +=
            '<td class="' +
            new_id +
            '"style="vertical-align:middle;" rowspan=' +
            sample_spcs_n +
            ">" +
            new_id +
            "</td>";
          new_tr +=
            '<td style="vertical-align:middle;" rowspan=' +
            sample_spcs_n +
            ">" +
            d.type +
            "</td>";
        }
        new_tr += "<td>" + d.spcs.replace("_", " ") + "</td>";
        new_tr +=
          '<td style="text-align:left;">' + d.sample_id[d.spcs] + "</td>";
        new_tr += "</tr>";
      } else {
        var new_tr =
          '<tr><td><input class="form-check-input track-show" type="checkbox" value="' +
          d._id +
          '" ' +
          checked +
          " " +
          "></td><td>" +
          d.data_id +
          "</td>";

        feature_list.forEach(function (ft) {
          if (ft != "name" && ft != "vis" && ft != "_id" && ft != "path") {
            var ft_val = d[ft];
            if (ft == "spcs" || ft == "tissue" || ft == "cell_type") {
              new_tr += "<td>" + ft_val.replaceAll("_", " ") + "</td>";
            } else if (ft == "param_path") {
              if (d["type"] == "Gene expression") {
                new_tr += "<td>-</td>";
              } else {
                new_tr +=
                  "<td><a href='" + ft_val + "' target='_blank'>Link</a></td>";
              }
            } else {
              new_tr += "<td>" + ft_val + "</td>";
            }
          }
        });
        new_tr += "</tr>";
      }

      $("#" + table).append(new_tr);
    });

  $(".page-item_" + type).removeClass("active");
  $(e).parent().addClass("active");
}

function Update_pages(e, total_count) {
  var total_page = Math.ceil(total_count / entries);

  var element_id = $(e).attr("id");
  current_page = parseInt(
    $(".page-item.active .page-link").attr("id").split("page")[1]
  );

  var [move_type, data_type] = element_id.split("_");

  var block = Math.ceil(current_page / page_count);
  var page1 = (block - 1) * page_count + 1;
  var page10 =
    page1 + page_count - 1 > total_page ? total_page : page1 + page_count - 1;

  switch (move_type) {
    case "first-page":
      current_page = 1;
      break;
    case "previous-page":
      current_page = page1 - 1;
      break;
    case "next-page":
      current_page = page10 + 1;
      break;
    case "last-page":
      current_page = total_page;
      break;
    default:
  }

  if (current_page < 1) {
    current_page = 1;
  }
  if (current_page > total_page) {
    current_page = total_page;
  }

  if (current_page) {
    Make_pagination(total_count, data_type);
  }
}

//function Check_form(type, ids, email) {
//  var pass = true;
//
//  if (email === undefined || email == "") {
//    $("#email").addClass("is-invalid");
//    pass = false;
//  } else {
//    $("#email").removeClass("is-invalid");
//  }
//
//  if (type == "prof") {
//    if (ids === "") {
//      $("#dataset_datalist").addClass("is-invalid");
//      $("#invalid-feedback_dataset1").show();
//      pass = false;
//    } else {
//      $("#dataset_datalist").removeClass("is-invalid");
//      $("#invalid-feedback_dataset1").hide();
//    }
//  } else {
//    if (ids == "" || ids.split(" ").length < 2) {
//      $("#comp_datalist").addClass("is-invalid");
//      pass = false;
//    } else {
//      $("#comp_datalist").removeClass("is-invalid");
//    }
//  }
//
//  return pass;
//}

function Check_form(type, ids) {
  var pass = true;

  if (type == "prof") {
    if (ids === "") {
      $("#dataset_datalist").addClass("is-invalid");
      $("#invalid-feedback_dataset1").show();
      pass = false;
    } else {
      $("#dataset_datalist").removeClass("is-invalid");
      $("#invalid-feedback_dataset1").hide();
    }
  } else {
    if (ids == "" || ids.split(" ").length < 2) {
      $("#comp_datalist").addClass("is-invalid");
      pass = false;
    } else {
      $("#comp_datalist").removeClass("is-invalid");
    }
  }

  return pass;
}

function Get_syntenyInfo(acc) {
  $.ajaxSettings.async = false;
  $.ajax({
    method: "get",
    url: php_path + "/get_syntenyinfo.php",
    data: {
      accession: acc,
    },
    success: function (dat) {
      var cols = dat.split(/\n|\t/);

      syntenyInfo["path"] = cols[6] + "/" + cols[3] + "_synteny.json";
      if (cols.length >= 8 && cols[7] != "") {
        LIBNAME.Set_alignment_path(cols[7]);
      }

      const ref_reg = new RegExp(/^(.+)\(([0-9]+)\|(.+)\)$/);
      if (ref_reg.test(cols[1])) {
        var refparse = cols[1].match(ref_reg);
        syntenyInfo["Reference genome"] =
          refparse[1].replaceAll("_", " ") + "(" + refparse[3] + ")";
      }

      var tar_info = cols[2].split(",");

      syntenyInfo["Minimum resolution (bp)"] = Number(
        cols[3].replace("k", "000")
      );
      (syntenyInfo["Whole genome alignment program"] = cols[4]),
        (syntenyInfo["Synteny generation program"] = cols[5]);

      var tars = [];
      tar_info.forEach(function (tar) {
        const tar_reg = new RegExp(/^(.+)\(([0-9]+)\|(.+)\|(.+)\)$/);
        if (tar_reg.test(tar)) {
          var tarparse = tar.match(tar_reg);
        }

        tars.push(tarparse[1].replaceAll("_", " ") + " (" + tarparse[3] + ")");
      });
      syntenyInfo["Target genome(s)"] = tars.join(", ");
    },
  });
  $.ajaxSettings.async = true;
}

function Make_job_table(data) {
  var main_l = $.unique(job_datum.map((d) => d.Main).sort());
  var status_l = $.unique(job_datum.map((d) => d.Status).sort());

  var table =
    "<table class='table table-sm text-center align-middle mb-0' style='font-size: 0.875rem; table-layout:fixed'><thead><tr><td style='width:7%'>Job ID</td>";
  table +=
    "<td><div class='btn-group d-grid gap-2'><button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_type_analysis' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>Analysis</button>";
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
    "<td><div class='btn-group d-grid gap-2'><button class='btn btn-outline-dark btn-sm dropdown-toggle track-header' id='dropdown_type_status' type ='button' data-bs-toggle='dropdown' aria-expaned='false'>Status</button>";
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
  table +=
    "<td>Accession ID</td><td style='width:20%'>Sample/Profile IDs</td><td>Running process</td></tr></thead>";

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
        : "";

    table +=
      "<tr><td>" +
      d.ID +
      "</td><td>" +
      d.Main +
      "</td><td id='status_" +
      d.ID +
      "'>" +
      status +
      "<div><button type='button' class='btn btn-link btn-sm' style='display:" +
      cancel_btn_show +
      "' onclick='Quit_job(" +
      d.PID +
      ',"' +
      session_id +
      '",' +
      d.ID +
      ")'>Quit job</button></div>" +
      "</td><td>" +
      d.Accession +
      "</td><td>" +
      d.Sample +
      "</td><td>" +
      job +
      "</td></tr>";
  });

  table += "</table>";
  $("#job_table").html(table);
}

function Get_job_status(sid) {
  var times = 1000;
  clearInterval(timer);

  var works = function () {
    times -= 1000;
    $("#job_timer").html(
      "The status will be updated after " + times / 1000 + "s."
    );

    if (times == 0) {
      clearInterval(timer);
      times = 31000;

      $.ajax({
        method: "get",
        dataType: "json",
        url: php_path + "/get_jobstatus.php",
        data: {
          session: sid,
          type: "multiomics",
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
              var main_l = $.unique(job_datum.map((d) => d.Main));
              var status_l = $.unique(job_datum.map((d) => d.Status));
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

function Quit_job(pid, sid, job) {
  if (pid) {
    $.ajax({
      method: "get",
      url: php_path + "/quit_job.php",
      data: {
        pid: pid,
        jobid: job,
        session: sid,
      },
      success: function () {
        $("#status_" + job).html("Canceled");
        alert("Succesfully quit your job");
      },
    });
  }
}

function Change_dowmsample_method(id, method) {
  $("#downsample_alert").modal("hide");

  var datumlist = [genomics_datum, multiomics_datum, highlight_datum];
  var data;
  var _d = 0;
  while (data === undefined) {
    data = datumlist[_d].filter(function (d) {
      return d._id == id;
    })[0];
    _d++;
  }
  var name = data.name;

  var new_config = {
    species: data.spcs,
    name: name,
    downsample: method,
  };

  downsample_method[id] = method;
  LIBNAME.Update_params_omics(new_config);
}

function Return_downsample_method(id) {
  $("#downsample_alert").modal("hide");

  $("#method_downsample-" + id)
    .val(downsample_method[id])
    .prop("selected", true);

  if (downsample_method[id] == "gene") {
    $("#minlen-" + id).prop("disabled", false);
  }
}
