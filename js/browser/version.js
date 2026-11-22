var LIBNAME = (function () {
  "use strict";

  var _data = {
    all: {},
    vis: {},
  };

  var tr_id = 1;

  var _utils = {
    phpscr_path: undefined,

    zoom: {
      ing: false,
      func: undefined,
      brush: {
        ing: false,
        func: [],
        color: undefined,
        range: [],
      },
    },

    cursor: {
      job: undefined,
      show: false,
      stroke_color: "black",
      stroke_width: 1,
    },

    params: {
      canvas: undefined,
      layout: "linear",
      prelayout: undefined,
      color: d3.schemeSet2,
      height: undefined,
      width: undefined,
      padding: {
        yaxis: {
          l: 25,
          c: 0.08,
        },
        track: 30,
        return: {
          l: 20,
          c: 0.08,
        },
      },
      chr: {
        data: undefined,
        start: 0,
        end: 0.05,
        name_maxlen: 0,
        width: 15,
        padding: {
          l: 5,
          c: 0.01,
        },
        width_fig: {
          l: "100%",
          c: "50%",
        },
        height_fig: {
          //l: 300,
          l: 0,
          c: 800,
        },
        r: "38%",
        stroke: "none",
        stroke_width: 1,
        rate: 1,
      },
      sf: {
        show: true,
        data: undefined,
        fill: "#d0d1d2",
        stroke: "#8d8c86",
        stroke_width: 1,
      },
      bp: {
        show: false,
        data: undefined,
        fill: "grey",
        stroke: "black",
        stroke_width: 1,
      },
      omics: {
        data: undefined,
        type: undefined,
        resizable: false,
        border_color: "black",
        border_width: 1,
        stroke_color: "black",
        stroke_width: 1,
        start: 50,
        padding: 10,
        width: {
          l: "100%",
          c: "50%",
        },
        height: 100,
        range: ["auto", "auto"],
        legend: {
          gradient_color: ["white", "red"],
          position: "right-top",
          width: 20,
          height: 50,
        },
      },
      tracks: [],
    },
  };

  _utils.Draw_synteny = function (config, resol = -1) {
    Update_params(config, "sf");
    if (Check_params()) {
      Update_svg();
      Read_data("sf", this.params.sf.data);
      if (resol != -1) {
        Merge_synteny(resol);
        _data.vis.sfs = _data.all.merge_sfs;
      } else {
        _data.all.merge_sfs = _data.all.raw_sfs;
        _data.vis.sfs = _data.all.raw_sfs;
      }

      Draw_chromosomes(_data.all.spcs, _data.vis.chrs, _utils.params);
      Draw_synteny(
        _data.all.spcs,
        _data.vis.sfs,
        _data.vis.chrs,
        _utils.params
      );
      Find_breakpointregion();
    }
  };

  _utils.Update_params = function (config, type) {
    if (type == "sf") {
      _utils.params.prelayout = _utils.params.layout;
    }

    Update_params(config, type);

    if (Check_params()) {
      Update_svg();
      Draw_chromosomes(_data.all.spcs, _data.vis.chrs, _utils.params);
      Draw_synteny(
        _data.all.spcs,
        _data.vis.sfs,
        _data.vis.chrs,
        _utils.params
      );
      Find_breakpointregion();
      Pinpoint_region(_data.vis.pin_types);

      if (_utils.params.tracks.length) {
        Make_tracks();
        Update_trackcontent();

        if (d3.selectAll(".gchart").size() != _utils.params.tracks.length) {
          Draw_charts();
        }

        Mark_syntenies(_data.vis.sfs, _data.vis.chrs, _utils.params);
      }
    }
  };

  _utils.Update_params_omics = function (config) {
    var get_newdata = false;

    var spcidx = _data.all.spcs.indexOf(config.species);

    var track = _utils.params.tracks.filter(function (tr) {
      return tr.name == config.name;
    })[0];

    if (track !== undefined) {
      for (var key in config) {
        if (key == "type" && track[key] != config[key]) {
          d3.select("#g" + track._id)
            .select(".g_chart")
            .selectAll("*")
            .remove();
        }
        if (key == "downsample") {
          get_newdata = true;
        }
        track[key] = config[key];
      }
    } else {
      get_newdata = true;
      track = Parse_track_config(config);
      if (track) {
        _utils.params.tracks.push(track);
        if (track.type == "gene") {
          track.oheight = 150;
          track.height = 150;
        }
      }
    }

    if (track) {
      $("#loading" + track._id).removeClass("hidden");
      Update_svg();
      Make_tracks();

      if (get_newdata) {
        if (!("match" in _data.all)) {
          Get_alndata();
        }
        Get_trackdata(track);
        Mark_syntenies(_data.vis.sfs, _data.vis.chrs, _utils.params);
      } else {
        Update_chart(track);
      }

      setTimeout(function () {
        $("#loading" + track._id).addClass("hidden");
      }, 1000);
    }
  };

  _utils.Get_range = function (name) {
    var track = _utils.params.tracks.filter(function (tr) {
      return tr.name == name;
    })[0];

    return track._range;
  };

  _utils.Add_track = function (config) {
    if (Check_params()) {
      Update_svg();
      Make_tracks();
      Update_trackcontent();
      Mark_syntenies(_data.vis.sfs, _data.vis.chrs, _utils.params);

      Draw_charts();
    }

    //Add_cursor();
  };

  _utils.Delete_track = function (name) {
    _utils.params.tracks = _utils.params.tracks.filter(function (tr) {
      return tr.name != name;
    });

    Make_tracks();
    Update_svg();
  };

  _utils.Get_species = function () {
    return _data.all.spcs;
  };

  _utils.Update_synteny = function (resol) {
    Merge_synteny(resol);
    _data.vis.sfs = _data.all.merge_sfs;

    Draw_synteny(_data.all.spcs, _data.vis.sfs, _data.vis.chrs, _utils.params);
    if (_utils.params.tracks.length) {
      Mark_syntenies(_data.vis.sfs, _data.vis.chrs, _utils.params);
    }
    Find_breakpointregion();
  };

  _utils.Search_gene = function (spc,query) {
      var species = LIBNAME.Get_species()[Number(spc)];
      var annotation = genomics_datum.find(function (d) {
        return d.type === "Gene annotation" && d.spcs === species;
      });

      var dataPath = annotation && (annotation.data_path || annotation.path);

      if (!dataPath || dataPath === "-") {
        LIBNAME.Show_region([spc, query]);
        return;
      }

      var loading = $("[class*='loading-track-']");
      loading.removeClass("hidden");

      $.ajax({
          url: php_path + "/get_gene_position.php",
          type: "get",
          dataType: "json",
          data: {
              data: dataPath,
              gene: query
          }
      }).done( function (res) {
        if (res.error) {
            loading.addClass("hidden");
            alert(res.error);
            return;
        }

        var matches = res.matches || [];
        if (!matches.length) {
            loading.addClass("hidden");
            if (/^(chr)?([0-9]+|X|Y|M|MT)$/i.test(query)) {
                LIBNAME.Show_region([spc, query]);
            } else {
                alert('Cannot find the gene "' + query + '".');
            }
            return;
        }
            
        var hit = matches[0];
        if (matches.length > 1) {
            var options = matches.map(function (m, i) {
                return (i + 1) + ". " + (m.name || m.id || query) + " (" + m.chr + ":" + m.start + "-" + m.end + ")";
            });
            loading.addClass("hidden");

            var selection = window.prompt("Multiple genes matched. Choose a number:\n" + options.join("\n"), "1");
            if (selection === null) return;

            var idx = Number(selection) - 1;
            if (!Number.isInteger(idx) || idx < 0 || idx >= matches.length) { alert("Invalid selection."); return; }
            hit = matches[idx];
            loading.removeClass("hidden");
        }

        LIBNAME.Show_region([spc, hit.chr + ":" + hit.start + "-" + hit.end]);
        setTimeout(function() { loading.addClass("hidden"); }, 1000);
    }).fail(function() {
        loading.addClass("hidden");
        alert("Could not search gene annotation.");
    });
  }

  _utils.Show_region = function (pos) {
    var params = _utils.params;

    var [spc, coord] = pos;
    spc = _data.all.spcs[spc];

    var [chr, start, end] = coord.split(/:|-/);
    chr = _data.all.chrs.filter(function (ch) {
      return ch.spc == spc && ch.name.toLowerCase() == chr.toLowerCase();
    })[0];

    if (chr === undefined || chr.len < end) {
      alert('Cannot find the region "' + pos[1] + '".');
      console.error("FIX");
      return false;
    }

    if (start === undefined) {
      start = 1;
      end = chr.len;
    }
    if (end === undefined) {
      end = Number(start) + 1;
    }

    start = Number(start);
    end = Number(end);

    if (start <= 0) {
      alert('Cannot find the region "' + pos[1] + '".');
      console.error("FIX");
      return false;
    }

    Filter_sfdata([pos]);

    var spcidx = _data.all.spcs.indexOf(spc);
    _utils.zoom.brush.range[spcidx] = [0, chr, start, chr, end, 0];

    Draw_chromosomes(_data.all.spcs, _data.vis.chrs, _utils.params);
    Draw_synteny(_data.all.spcs, _data.vis.sfs, _data.vis.chrs, _utils.params);
    Find_breakpointregion();
    Pinpoint_region(_data.vis.pin_types);

  };

  _utils.Move_to = function (region) {
    var spcidx = _data.all.spcs.indexOf(region[0]);
    $(".loading-track-" + spcidx).removeClass("hidden");
    Move_to(region);
    $(".loading-track-" + spcidx).addClass("hidden");
  };

  _utils.Change_order = function (order) {
    var params = _utils.params;
    params.tracks.sort(function (a, b) {
      return order.indexOf(a.name) - order.indexOf(b.name);
    });

    var track_y = 30;
    if (params.layout == "linear") {
      params.tracks.forEach(function (tr) {
        if ("_id" in tr) {
          d3.select("#g" + tr._id).attr(
            "transform",
            "translate(0," + track_y + ")"
          );

          var pos = d3
            .select("#g" + tr._id)
            .select(".trackborder")
            .node()
            .getScreenCTM();

          tr._x = window.pageXOffset + pos.e;
          tr._y = window.pageYOffset + pos.f;

          d3.select("#loading" + tr._id)
            .style("left", window.pageXOffset + pos.e + "px")
            .style("top", window.pageYOffset + pos.f + "px");

          d3.select("#div_canvas_" + tr._id)
            .style(
              "left",
              window.pageXOffset + pos.e + params.omics.start + "px"
            )
            .style("top", window.pageYOffset + pos.f + "px");

          d3.select("#div_mcanvas_" + tr._id)
            .style(
              "left",
              window.pageXOffset + pos.e + params.omics.start + "px"
            )
            .style("top", window.pageYOffset + pos.f + tr.oheight - 2 + "px");
        }

        tr.width = params.omics.width.l;
        params.height += params.padding.track + tr.height;
        track_y += params.padding.track + tr.height;
      });
    } else {
      var track_height = 0;

      params.tracks.forEach(function (tr, i) {
        if ("_id" in tr) {
          d3.select("#g" + tr._id).attr(
            "transform",
            "translate(0," + track_y + ")"
          );

          var pos = d3
            .select("#g" + tr._id)
            .select(".trackborder")
            .node()
            .getScreenCTM();

          d3.select("#loading" + tr._id)
            .style("left", window.pageXOffset + pos.e + "px")
            .style("top", window.pageYOffset + pos.f + "px");

          d3.select("#div_canvas_" + tr._id)
            .style(
              "left",
              window.pageXOffset + pos.e + params.omics.start + "px"
            )
            .style("top", window.pageYOffset + pos.f + "px");

          d3.select("#div_mcanvas_" + tr._id)
            .style(
              "left",
              window.pageXOffset + pos.e + params.omics.start + "px"
            )
            .style("top", window.pageYOffset + pos.f + tr.oheight - 2 + "px");
        }

        tr.width = params.omics.width.c;
        track_height += tr.height;
        if (i) {
          track_height += params.padding.track;
        }
        track_y += params.padding.track + tr.height;
      });

      params.height = Math.max(track_height + 50, params.chr.height_fig.c);
    }
  };

  _utils.Pinpoint_region = function (eles) {
    if (!("highlight" in _data.all)) {
      _data.all.highlight = {};
      _data.vis.highlight = {};
    }

    _data.vis.pin_types = eles;

    for (var ele in _data.vis.pin_types) {
      if (!(ele in _data.all.highlight)) {
        _data.all.highlight[ele] = [];
      }

      if (!(ele in _data.vis.highlight)) {
        _data.vis.highlight[ele] = [];
      }
    }

    for (var ele in _data.all.highlight) {
      if (!(ele in _data.vis.pin_types)) {
        _data.all.highlight[ele] = [];
      }
    }

    if ("breakpoint_regions" in _data.vis.pin_types) {
      _data.all.highlight.breakpoint_regions = $.extend(
        true,
        [],
        _data.all.bps
      );
    }

    for (var type in _data.vis.pin_types) {
      if (
        type != "breakpoint_regions" &&
        (!(type in _data.all.highlight) ||
          _data.all.highlight[type].length == 0)
      ) {
        $.ajaxSettings.async = false;
        $.ajax({
          url: _utils.phpscr_path + "/get_highlight.php",
          type: "get",
          data: {
            path: _data.vis.pin_types[type].path,
          },
        }).done(function (result) {
          _data.all.highlight[type] = jQuery.parseJSON(result);
        });
        $.ajaxSettings.async = true;
      }
    }

    Pinpoint_region(_data.vis.pin_types);
    Update_svg();
    Make_tracks();
    Update_trackcontent();

  };

  _utils.Set_alignment_path = function (path) {
    _data.all["alnpath"] = path;
  };

  _utils.Add_highlihgt_regions = function (id, data, color) {
    if (!("highlight" in _data.all)) {
      _data.all.highlight = {};
      _data.vis.highlight = {};
      _data.vis.pin_types = {};
    }

    if (!(id in _data.vis.highlight)) {
      _data.vis.highlight[id] = [];
    }

    _data.all.highlight[id] = data;
    _data.vis.pin_types[id] = {color: color, path: ""};

    Pinpoint_region(_data.vis.pin_types);
    Update_svg();
    Make_tracks();
    Update_trackcontent();
    Draw_charts();
  };

  _utils.Update_highlight_regions = function (id, data, color) {
    _data.all.highlight[id] = data;
    _data.vis.pin_types[id] = {color: color, path: ""};

    Pinpoint_region(_data.vis.pin_types);
    Update_svg();
    Make_tracks();
    Update_trackcontent();
    Draw_charts();
  };

  _utils.Remove_highlihgt_regions = function (id) {
    delete _data.vis.pin_types[id];

    Pinpoint_region(_data.vis.pin_types);
    Update_svg();
    Make_tracks();
    Update_trackcontent();
    Draw_charts();
  };

  return Initiate();

  /* Private functions */
  function Initiate() {
    return _utils;
  }

  function Update_params(config, type) {
    var params = _utils.params;

    if (type == "sf") {
      if ("layout" in config) {
        params.layout = config.layout;
      }

      for (var key in config) {
        var value = config[key];

        switch (key) {
          case "canvas":
            params.canvas = value;
            break;
          case "height":
            if (value.indexOf("px") != -1) {
              value = Number(value.replace("px", ""));
            }
            if (params.layout == "linear") {
              params.chr.height_fig.l = value;
            } else {
              params.chr.height_fig.c = value;
            }
            break;
          case "chr_data":
            params.chr.data = value;
            break;
          case "synteny_data":
            params.sf.data = value;
            break;
          default:
        }
      }
    } else if (type == "mo") {
      params.tracks = [];

      for (var key in config) {
        var value = config[key];

        if ("width" in config) {
          if (config["width"].indexOf("px") != -1) {
            config["width"] = Number(config["width"].replace("px", ""));
          }
          params.omics.width = config["width"];
          break;
        }

        switch (key) {
          case "zoom":
            if (value.toLowerCase() == "true") {
              _utils.zoom.func = true;
              Set_zoom();
            } else {
              d3.select(".g_brushs").remove();
            }
            break;
          case "phpscr_path":
            _utils.phpscr_path = value;
            break;
          case "track":
            value.forEach(function (tr) {
              var trackopt = Parse_track_config(tr);
              if (trackopt) {
                params.tracks.push(trackopt);
              }
            });
            break;
        }
      }
    } else {
      console.error("FIX");
    }
  }

  function Parse_track_config(tr) {
    var params = _utils.params;
    var trackopt = $.extend(true, {}, params.omics);

    for (var tkey in tr) {
      var tvalue = tr[tkey];

      switch (tkey) {
        case "name":
          trackopt.name = tvalue;
          break;
        case "height":
          if (tvalue.indexOf("px") != -1) {
            tvalue = Number(tvalue.replace("px", ""));
          }
          trackopt.height = tvalue;
          break;
        case "stroke_width":
          if (tvalue.indexOf("px") != -1) {
            tvalue = Number(tvalue.replace("px", ""));
          }
          trackopt.stroke_width = tvalue;
          break;
        default:
          trackopt[tkey] = tvalue;
      }
    }

    trackopt.oheight = trackopt.height;

    if (!("width" in tr)) {
      trackopt.width =
        params.layout == "linear" ? params.omics.width.l : params.omics.width.c;
    }
    if (!("stroke_color" in tr)) {
      trackopt.stroke_color = params.color_spc(trackopt.species);
    }
    if (!("fill" in tr)) {
      trackopt.fill = params.color_spc(trackopt.species);
    }
    if (!("type" in trackopt)) {
      trackopt.type = "point";
    }
    if (!("downsample" in trackopt)) {
      trackopt.downsample = "na";
    }

    return trackopt;
  }

  function Check_params() {
    var params = _utils.params;

    if (params.canvas === undefined) {
      console.error("FIX2");
      return 0;
    }
    if (params.layout != "linear" && params.layout != "circular") {
      console.error("FIX3");
      return 0;
    }
    if (params.sf.data === undefined) {
      console.error("FIX4");
      return 0;
    }

    return params;
  }

  function Update_svg() {
    var params = _utils.params;

    var pinlayers = 0;
    if ("pin_types" in _data.vis) {
      pinlayers = Object.keys(_data.vis.pin_types).length;
    }

    params.chr.width_fig.l =
      typeof params.chr.width_fig.l == "number" ||
      params.chr.width_fig.l.indexOf("%") == -1
        ? params.chr.width_fig.l
        : (($("#" + params.canvas).width() - params.chr.stroke_width * 2) *
            Number(params.chr.width_fig.l.replace("%", ""))) /
          100;

    params.chr.width_fig.c =
      typeof params.chr.width_fig.c == "number" ||
      params.chr.width_fig.c.indexOf("%") == -1
        ? params.chr.width_fig.c
        : (($("#" + params.canvas).width() - params.chr.stroke_width * 2) *
            Number(params.chr.width_fig.c.replace("%", ""))) /
          100;

    params.omics.width.c =
      typeof params.omics.width.c == "number" ||
      params.omics.width.c.indexOf("%") == -1
        ? params.omics.width.c
        : ($("#" + params.canvas).width() *
            Number(params.omics.width.c.replace("%", ""))) /
          100;

    if (params.layout == "linear") {
      params.width = params.chr.width_fig.l;
      params.omics.width.l =
        params.chr.width_fig.l - params.omics.border_width * 4;
      params.height =
        typeof params.chr.height_fig.l == "number" ||
        params.chr.height_fig.l.indexOf("%") == -1
          ? params.chr.height_fig.l
          : (($("#" + params.canvas).width() - params.chr.stroke_width * 2) *
              Number(params.chr.height_fig.l.replace("%", ""))) /
            100;

      params.height += pinlayers * 9;
    } else {
      params.width = params.chr.width_fig.c + params.omics.width.c - 1;
      params.height =
        typeof params.chr.height_fig.c == "number" ||
        params.chr.height_fig.c.indexOf("%") == -1
          ? params.chr.height_fig.c
          : (($("#" + params.canvas).height() - params.chr.stroke_width * 2) *
              Number(params.chr.height_fig.c.replace("%", ""))) /
            100;
      params.chr.r =
        typeof params.chr.r == "number" || params.chr.r.indexOf("%") == -1
          ? params.chr.r
          : (Math.min(params.height, params.width / 2) *
              Number(params.chr.r.replace("%", ""))) /
            100;
    }

    if (params.tracks.length) {
      var track_y = 30;
      var track_height = 0;

      params.tracks.forEach(function (tr, i) {
        if (
          "pin_types" in _data.vis &&
          Object.keys(_data.vis["pin_types"]).length
        ) {
          tr.height =
            tr.oheight + Object.keys(_data.vis["pin_types"]).length * 7 + 10;
        } else {
          tr.height = tr.oheight;
        }
        var chart_height = tr.oheight - 40;

        if ("_id" in tr) {
          var pos = d3
            .select("#g" + tr._id)
            .select(".trackborder")
            .node()
            .getScreenCTM();

          tr._x = window.pageXOffset + pos.e;
          tr._y = window.pageYOffset + pos.f;

          d3.select("#g" + tr._id).attr(
            "transform",
            "translate(0," + track_y + ")"
          );

          d3.select("#g" + tr._id)
            .select(".g_axes")
            .select("rect")
            .attr(
              "transform",
              "translate(" +
                _utils.params.omics.start +
                ", " +
                chart_height +
                ")"
            );

          d3.select("#g" + tr._id)
            .selectAll(".g_chr")
            .attr("transform", "translate(0, " + chart_height + ")");

          d3.select("#g" + tr._id)
            .selectAll(".bkg_sf")
            .attr("height", chart_height);

          d3.select("#loading" + tr._id)
            .style("left", window.pageXOffset + pos.e + "px")
            .style("top", window.pageYOffset + pos.f + "px")
            .style("height", tr.height + "px");

          d3.select("#div_canvas_" + tr._id)
            .style(
              "left",
              window.pageXOffset + pos.e + params.omics.start + "px"
            )
            .style("top", window.pageYOffset + pos.f + "px");

          d3.select("#div_mcanvas_" + tr._id)
            .style(
              "left",
              window.pageXOffset + pos.e + params.omics.start + "px"
            )
            .style("top", window.pageYOffset + pos.f + tr.oheight - 2 + "px");

          if (params.layout == "linear") {
            tr.width = params.omics.width.l;

            params.height += params.padding.track + tr.height;
            track_y += params.padding.track + tr.height;
          } else {
            tr.width = params.omics.width.c;
            track_height += tr.height;
            if (i) {
              track_height += params.padding.track;
            }
            params.height = Math.max(
              track_height + 50,
              params.chr.height_fig.c
            );
            track_y += params.padding.track + tr.height;
          }
        }
      });
    }

    if (
      d3
        .select("#" + params.canvas)
        .select("svg")
        .empty()
    ) {
      d3.select("#" + params.canvas)
        .append("div")
        .style("position", "relative")
        .style("z-index", 2)
        .append("svg");
    }

    d3.select("#" + params.canvas)
      .select("svg")
      .attr("width", params.width + params.chr.stroke_width * 2)
      .attr("height", params.height + params.chr.stroke_width * 2);
  }

  function Read_data(type, path) {
    $.ajaxSettings.async = false;
    $.get(path, function (dat) {
      switch (type) {
        case "sf":
          var chrs = [];
          var chr_id = 1;
          for (var spc in dat.chr) {
            var chrs_spc = dat.chr[spc];

            chrs_spc.forEach(function (chr) {
              chr.spc = spc;
              chr._id = chr_id++;

              chrs.push(chr);
            });
          }

          _data.all.spcs = dat.species;
          _data.vis.chrs = _data.all.chrs = chrs;
          _data.all.raw_sfs = dat.sf;
          _utils.params.color_spc = d3
            .scaleOrdinal(_utils.params.color)
            .domain(_data.all.spcs);

          break;
      }
    });
    $.ajaxSettings.async = true;
  }

  function Draw_x_axis(target) {
    var params = _utils.params;
    var brushrate = -1;

    var radius = 0;

    if (params.layout == "circular") {
      radius = params.chr.r - 20 + 3;
    }

    var canvas;
    if (target == "sf") {
      canvas = d3.select("#" + params.canvas).select("#g_chrs");
    } else {
      canvas = d3.select("#" + params.canvas).select("#g" + target);

      var tr = _utils.params.tracks.filter(function (tr) {
        return tr._id == target;
      })[0];
      var spcname = tr.species;
      var spcidx = _data.all.spcs.indexOf(spcname);
      var visrange = _utils.zoom.brush.range[spcidx];
      var vischrs = $.extend(true, [], _data.vis.chrs);

      var spc_chrs = vischrs
        .filter(function (chr) {
          return (
            chr.spc == spcname &&
            visrange[1]._index <= chr._index &&
            chr._index <= visrange[3]._index
          );
        })
        .sort(function (a, b) {
          return d3.ascending(a._id, b._id);
        });

      spc_chrs.forEach(function (chr) {
        if (chr.name == visrange[1].name) {
          chr._vstart = visrange[2];
        }
        if (chr.name == visrange[3].name) {
          chr._vend = visrange[4];
        }
      });

      var chart_height = tr.oheight - 40;

      var chrsg = canvas
        .select(".gchart")
        .select(".g_axes")
        .selectAll(".g_chr")
        .data(spc_chrs);

      chrsg.exit().remove();

      chrsg
        .enter()
        .append("g")
        .attr("class", (d) => "g_chr")
        .attr("transform", "translate(0," + chart_height + ")");

      canvas.select(".gchart").selectAll(".g_chr").select(".g_axis").remove();

      canvas
        .select(".gchart")
        .selectAll(".g_chr")
        .append("g")
        .attr("class", "g_axis");

      Mark_region(_data.vis.pin_types);
    }

    canvas.selectAll(".g_chr").select(".g_axis").selectAll(".g_xaxis").remove();

    canvas
      .selectAll(".g_chr")
      .select(".g_axis")
      .append("g")
      .attr("class", "g_xaxis")
      .style("pointer-events", target == "sf" ? "none" : "auto")
      .attr("transform", function (d) {
        if (params.layout == "linear" || target != "sf") {
          var spcidx = _data.all.spcs.indexOf(d.spc);
          var chrbegin =
            d._x + d._index * params.chr.padding.l + params.chr.start;

          if (target != "sf") {
            d.start = d._vstart;
            d.end = d._vend;
            d.chr = d.name;

            var vislen = 0;
            var [margin_f, chr1, begin, chr2, end, margin_b] =
              _utils.zoom.brush.range[spcidx];

            _data.vis.chrs
              .filter(function (chr) {
                return (
                  chr.spc == d.spc &&
                  chr1._index <= chr._index &&
                  chr._index <= chr2._index
                );
              })
              .forEach(function (chr) {
                vislen += chr._vend - chr._vstart + 1;
              });

            if (vislen) {
              vislen -= begin - 1 + (chr2._vend - end + 1);

              if (params.layout == "linear") {
                brushrate =
                  (params.omics.width.l - params.omics.start + 1) /
                  (vislen +
                    ((chr2._index - chr1._index) * params.chr.padding.l +
                      margin_f +
                      margin_b) /
                      params.chr.rate);
              } else {
                brushrate =
                  (params.omics.width.c - params.omics.start + 1) /
                  (vislen +
                    ((chr2._index - chr1._index) * params.chr.padding.l +
                      ((margin_f + margin_b) * params.chr.padding.l) /
                        (params.chr.padding.c * 1.5)) /
                      params.chr.rate);
              }
            }

            Set_coordinate(d, margin_f, chr1, begin, brushrate, params);
            d._tflen = d._vendpx - d._vstartpx + 1;
            chrbegin = d._vstartpx + params.omics.start;

            if (target != "sf") {
              d3.select(this).selectAll(".axis-chrname").remove();
              d3.select(this)
                .append("text")
                .attr("class", "axis-chrname")
                .attr("font-size", "0.7rem")
                .text(d.name)
                .attr("fill", "black")
                .attr("y", 29)
                .attr("x", function () {
                  if (params.layout == "linear") {
                    return (
                      (Math.min(d._vendpx, params.omics.width.l) -
                        Math.max(0, d._vstartpx)) /
                      2
                    );
                  } else {
                    return (
                      (Math.min(d._vendpx, params.omics.width.c) -
                        Math.max(0, d._vstartpx)) /
                      2
                    );
                  }
                });
            }

            var y = 0;
          } else {
            var y = d._y + params.chr.width;
          }

          return "translate(" + (chrbegin - 1) + "," + (y + 1) + ")";
        }

        return "translate(1, 1)";
      })
      .each(function (d) {
        var tickstart = d._vstartpx,
          tickend = d._vendpx,
          ticklength = d._tflen;

        if (target != "sf" && _utils.zoom.func !== undefined) {
          tickstart = d.start;
          tickend = d.end;
        }

        if (params.layout == "linear" || target != "sf") {
          var tick_interval =
            target == "sf"
              ? 0
              : (d._vendpx - d._vstartpx + 1) / (d._vend - d._vstart + 1);

          var count = Math.min(
            Math.round(ticklength / 100),
            d._vend - d._vstart + 1
          );
          var scale = d3
            .scaleLinear()
            .domain([d._vstart, d._vend])
            .range([tick_interval / 2, ticklength - tick_interval / 2 - 1]);

          d3.select(this)
            .call(d3.axisBottom(scale).ticks(count).tickFormat(Format_tick))
            .style("font-size", "0.6rem");

          if (d._vstart != 1 || d._vend != d.len) {
            var newd = d3.select(this).select("path.domain").attr("d");
            if (d._vstart != 1) {
              newd = newd.replace("6V", "");
            }
            if (d._vend != d.len) {
              newd = newd.replace("V6", "");
            }

            d3.select(this).select("path.domain").attr("d", newd);
          }

          if (target != "sf") {
            d3.select(this).select(".chrline").remove();
            d3.select(this).select(".gchrline_m").remove();

            d3.select(this)
              .append("path")
              .attr("class", "chrline")
              .attr("stroke", "black")
              .attr("d", function (d) {
                return d3.line()([
                  [0, 0],
                  [d._vendpx - d._vstartpx + 1, 0],
                ]);
              });

            if (
              "pin_types" in _data.vis &&
              Object.keys(_data.vis.pin_types).length
            ) {
              var gtick_m = d3
                .select(this)
                .append("g")
                .attr("class", "gchrline_m")
                .attr("transform", "translate(0, 35)");

              gtick_m
                .append("path")
                .attr("class", "chrline_m")
                .attr("stroke", "black")
                .attr("d", function (d) {
                  return d3.line()([
                    [0, 0],
                    [d._vendpx - d._vstartpx + 1, 0],
                  ]);
                });

              gtick_m
                .call(d3.axisTop(scale).ticks(count).tickFormat(Format_tick))
                .style("font-size", "0rem");
            }

            d3.select(this)
              .selectAll("text")
              .each(function (d) {
                if (d3.select(this).attr("class") == "axis-chrname") {
                  if (d._tflen < this.getComputedTextLength()) {
                    d3.select(this).classed("hidden", true);
                  } else {
                    d3.select(this).classed("hidden", false);
                  }
                } else {
                  if (
                    d3
                      .select("#g_tracks")
                      .select("rect")
                      .node()
                      .getBoundingClientRect().x >
                    this.getBoundingClientRect().x
                  ) {
                    //                    d3.select(this).remove();
                  }
                }
              });
          }
        } else {
          var scale = d3
            .scaleLinear()
            .domain([d._vstart, d._vend])
            .range([d.startAngle, d.endAngle]);

          d3.select(this)
            .append("path")
            .attr("class", "domain")
            .attr("stroke", "currentColor")
            .attr("d", Draw_arc(radius, radius, d.startAngle, d.endAngle));

          var angle = d.endAngle - d.startAngle;
          var ticks = scale.ticks(parseInt(angle / 0.1));
          var length = d._vend - d._vstart + 1;

          for (var i = 0; i < ticks.length; ++i) {
            var t = ticks[i];

            var tickangle =
              ((t - d._vstart + 1) * angle) / length + d.startAngle;
            var x1 = radius * Math.sin(tickangle),
              y1 = -1 * (radius * Math.cos(tickangle)),
              x2 = (radius + 6) * Math.sin(tickangle),
              y2 = -1 * ((radius + 6) * Math.cos(tickangle));

            d3.select(this)
              .append("path")
              .attr("stroke", "black")
              .attr("d", function () {
                return d3.line()([
                  [x1, y1],
                  [x2, y2],
                ]);
              });

            d3.select(this)
              .append("path")
              .attr("id", "chr" + d._id + "-tickpath" + i)
              .attr(
                "d",
                Draw_arc(
                  radius + 8,
                  radius + 8,
                  tickangle - 0.1,
                  tickangle + 0.1
                )
              );

            d3.select(this)
              .append("text")
              .append("textPath")
              .style("text-anchor", "middle")
              .style("font-size", "0.5rem")
              .attr("class", "track_name")
              .attr("startOffset", "25%")
              .attr("xlink:href", function (d) {
                return "#chr" + d._id + "-tickpath" + i;
              })
              .text(Format_tick(t));
          }
        }

        function Format_tick(x) {
          var t = d._vend - d._vstart + 1;

          if (t > 100000) {
            return d3.format("~s")(x);
          } else {
            if (t > 10000) {
              return d3.format(",")((x / 10000).toFixed(1)) + "K";
            } else if (t > 1000) {
              return d3.format(",")((x / 1000).toFixed(2)) + "K";
            } else {
              return d3.format(",")(x);
            }
          }
        }
      });
  }

  function Draw_y_axis(target, scale) {
    var chart_height = target.oheight - 40;
    var canvas = d3.select("#g" + target._id).select(".g_axes");

    var axisg = canvas.select(".g_yaxis");
    if (axisg.empty()) {
      axisg = canvas.append("g").attr("class", "g_yaxis");

      axisg
        .append("g")
        .attr("class", "g_ticks")
        .attr("transform", "translate(" + (target.start - 1) + ", 0)");
      axisg.append("g").attr("class", "g_grid");
    }

    var min =
      target.range[0] == "auto"
        ? d3.min(_data.vis[target._id], (d) => Number(d.value))
        : target.range[0];
    var max =
      target.range[1] == "auto"
        ? d3.max(_data.vis[target._id], (d) => Number(d.value))
        : target.range[1];
    /*
    var scale = d3
      .scaleLinear()
      .range([chart_height, 15])
      .domain([min, max])
      .nice();
*/
    if (max > 1) {
      var ticks = d3.axisLeft().ticks(5, "~s").scale(scale);
    } else {
      var ticks = d3.axisLeft().ticks(5).scale(scale);
    }

    var grids = scale.ticks(5);
    var gridline = axisg.select(".g_grid").selectAll(".gridline").data(grids);

    gridline.exit().remove();

    gridline.enter().append("path").attr("class", "gridline");

    axisg
      .select(".g_grid")
      .selectAll(".gridline")
      .attr("d", function (d) {
        return d3.line()([
          [target.start, scale(d)],
          [target.width, scale(d)],
        ]);
      })
      .attr("stroke", "black")
      .attr("stroke-width", "0.2px");

    axisg.select(".g_ticks").call(ticks).style("font-size", "0.6rem");
  }

  function Move_to(pos) {
    var params = _utils.params;

    var [spc, chr1, hgstart, chr2, hgend] = pos;

    var hgchr1 = _data.vis.chrs.filter(function (chr) {
      return chr.name == chr1 && chr.spc == spc;
    })[0];

    var hgchr2 = _data.vis.chrs.filter(function (chr) {
      return chr.name == chr2 && chr.spc == spc;
    })[0];

    var spcidx = _data.all.spcs.indexOf(spc);
    if (params.layout == "linear") {
      var brushx1 =
        hgchr1._index * params.chr.padding.l +
        hgchr1._x +
        (hgchr1._tflen / hgchr1.len) * hgstart;
      var brushx2 =
        hgchr2._index * params.chr.padding.l +
        hgchr2._x +
        (hgchr2._tflen / hgchr2.len) * hgend;

      d3.select(".gbrush_" + spcidx).call(_utils.zoom.brush.func[spcidx].move, [
        brushx1,
        brushx2,
      ]);
    } else {
      var brushx1 =
        hgchr1.startAngle +
        ((hgchr1.endAngle - hgchr1.startAngle) / hgchr1.len) * hgstart;
      var brushx2 =
        hgchr2.startAngle +
        ((hgchr2.endAngle - hgchr2.startAngle) / hgchr2.len) * hgend;

      d3.select(".gbrush_" + spcidx).call(
        _utils.zoom.brush.func[spcidx].move(
          [brushx1, brushx2],
          d3.select(".gbrush_" + spcidx)
        )
      );

    }
  }

  ///* Synteny *///
  function Merge_synteny(resol) {

    var ref_spc = _data.all.spcs[0];
    _data.all.merge_sfs = [];

    var network = {},
      rev_network = {};

    //* Filt syntenies by size  *//
    var idx_flt_sf = {};

    var flt_sf = _data.all.raw_sfs.filter(function (sf) {
      if (!("_minsize" in sf)) {
        var minsize = -1;
        for (var spc_in_sf in sf.pos)
          if (minsize == -1) {
            minsize = sf.pos[spc_in_sf]["end"] - sf.pos[spc_in_sf]["start"] + 1;
          } else {
            if (
              minsize >
              sf.pos[spc_in_sf]["end"] - sf.pos[spc_in_sf]["start"] + 1
            ) {
              minsize =
                sf.pos[spc_in_sf]["end"] - sf.pos[spc_in_sf]["start"] + 1;
            }
          }
        sf._minsize = minsize;
      }
      if (sf._minsize >= resol) {
        idx_flt_sf[sf.id] = sf;
      }
      return sf._minsize >= resol;
    });

    //* Build full network *//
    _data.all.spcs.forEach(function (spc) {
      network[spc] = {};
      rev_network[spc] = {};

      //* Build network using filtered syntenies *//
      var cur_spc_sf = Sort_synteny(flt_sf, spc);
      for (var i = 1; i < cur_spc_sf.length; ++i) {
        if (
          cur_spc_sf[i - 1].pos[spc].chr == cur_spc_sf[i].pos[spc].chr &&
          cur_spc_sf[i - 1].pos[spc].dir == cur_spc_sf[i].pos[spc].dir
        ) {
          network[spc][cur_spc_sf[i - 1].id] = cur_spc_sf[i].id;
          rev_network[spc][cur_spc_sf[i].id] = cur_spc_sf[i - 1].id;
        }
      }
    });

    //* Find conserved network *//
    var conserve_network = {};
    flt_sf.forEach(function (sf) {
      var nxt_sf = {};
      var spc_cnt = 0;

      _data.all.spcs.forEach(function (spc) {
        spc_cnt++;

        if (spc in sf.pos) {
          if (sf.pos[spc].dir == "+") {
            if (sf.id in network[spc]) {
              if (network[spc][sf.id] in nxt_sf) {
                nxt_sf[network[spc][sf.id]]++;
              } else {
                nxt_sf[network[spc][sf.id]] = 1;
              }
            }
          } else {
            if (sf.id in rev_network[spc]) {
              if (rev_network[spc][sf.id] in nxt_sf) {
                nxt_sf[rev_network[spc][sf.id]]++;
              } else {
                nxt_sf[rev_network[spc][sf.id]] = 1;
              }
            }
          }
        }
      });

      if (
        Object.keys(nxt_sf).length == 1 &&
        nxt_sf[Object.keys(nxt_sf)[0]] == spc_cnt
      ) {
        conserve_network[sf.id] = Object.keys(nxt_sf)[0];
      }
    });

    var paths = {},
      proc_sf = {};
    flt_sf.forEach(function (sf) {
      if (!(sf.id in proc_sf)) {
        paths[sf.id] = Find_path(sf.id, conserve_network, proc_sf, paths);
      }
    });

    $.each(paths, function (tmp, pt) {
      var new_syn = {
        pos: {},
      };

      $.each(idx_flt_sf[pt[0]].pos, function (spc, tmp) {
        var chr = idx_flt_sf[pt[0]].pos[spc].chr;
        var dir = idx_flt_sf[pt[0]].pos[spc].dir;
        var start =
          idx_flt_sf[pt[0]].pos[spc].start <
          idx_flt_sf[pt[pt.length - 1]].pos[spc].start
            ? idx_flt_sf[pt[0]].pos[spc].start
            : idx_flt_sf[pt[pt.length - 1]].pos[spc].start;
        var end =
          idx_flt_sf[pt[0]].pos[spc].end >
          idx_flt_sf[pt[pt.length - 1]].pos[spc].end
            ? idx_flt_sf[pt[0]].pos[spc].end
            : idx_flt_sf[pt[pt.length - 1]].pos[spc].end;

        new_syn.pos[spc] = {
          chr: chr,
          dir: dir,
          start: start,
          end: end,
        };
      });

      _data.all.merge_sfs.push(new_syn);
    });

    _data.all.merge_sfs = _data.all.merge_sfs.sort(function (a, b) {
      return ref_spc in a.pos && ref_spc in b.pos
        ? d3.ascending(a.pos[ref_spc].start, b.pos[ref_spc].start)
        : d3.descending(ref_spc in a.pos, ref_spc in b.pos);
    });

    var new_id = 1;
    _data.all.merge_sfs.forEach(function (d) {
      d.id = new_id.toString();
      new_id++;
    });

    function Sort_synteny(sfs, spc) {
      var spc_sfs = sfs.filter(function (d) {
        return spc in d["pos"];
      });

      spc_sfs.sort(function (a, b) {
        if (a["pos"][spc]["chr"] < b["pos"][spc]["chr"]) {
          return -1;
        } else if (a["pos"][spc]["chr"] > b["pos"][spc]["chr"]) {
          return 1;
        } else {
          return a["pos"][spc]["start"] - b["pos"][spc]["start"];
        }
      });

      return spc_sfs;
    }

    function Find_path(sf, net, proc, pat) {
      var path = [];

      if (sf in net) {
        if (net[sf] in pat) {
          path = pat[net[sf]];
          delete pat[net[sf]];
        } else {
          path = Find_path(net[sf], net, proc, pat);
        }
      }

      proc[sf] = net[sf];
      path.unshift(sf);

      return path;
    }
  }

  function Find_breakpointregion() {
    var bps = [];

    _data.all.spcs.forEach(function (spc) {
      var sort_sf = _data.vis.sfs.sort(function (a, b) {
        if (a.pos[spc].chr < b.pos[spc].chr) {
          return -1;
        } else if (a.pos[spc].chr > b.pos[spc].chr) {
          return 1;
        } else {
          return Number(a.pos[spc].start) - Number(b.pos[spc].start);
        }
      });

      for (var i = 1; i < sort_sf.length; ++i) {
        if (sort_sf[i - 1].pos[spc].chr == sort_sf[i].pos[spc].chr) {
          var chr = sort_sf[i - 1].pos[spc].chr;

          if (sort_sf[i - 1].pos[spc].end < sort_sf[i].pos[spc].start) {
            var beg = sort_sf[i - 1].pos[spc].end;
            var end = sort_sf[i].pos[spc].start;
          } else {
            var beg = sort_sf[i].pos[spc].start;
            var end = sort_sf[i - 1].pos[spc].end;
          }

          bps.push({
            chr: chr,
            start: beg,
            end: end,
            spc: spc,
          });
        }
      }
    });

    _data.all["bps"] = bps;

    if (
      "pin_types" in _data.vis &&
      "breakpoint_regions" in _data.vis.pin_types
    ) {
      _data.all.highlight.breakpoint_regions = $.extend(
        true,
        [],
        _data.all.bps
      );
      Pinpoint_region(_data.vis.pin_types);
    }
  }

  function Set_species_ypos(i, n, params) {
    if (
      params.chr.height_fig.l <
      10 + (params.chr.width + 100) * i + params.chr.width + 10
    ) {
      params.chr.height_fig.l =
        10 + (params.chr.width + 100) * i + params.chr.width + 20;
    }
    return 10 + (params.chr.width + 100) * i;
    /*
    return (
      params.chr.width +
      ((params.chr.height_fig.l - 20 - params.chr.width * (n + 1)) * i) /
        (n - 1) +
      10
    ); // 10 for tick label & 10 for chr name
*/
  }

  function Set_coordinate(data, margin, brush_chr, brush_start, rate, params) {
    if (params.layout == "circular") {
      margin = (margin / (params.chr.padding.c * 1.5)) * params.chr.padding.l;
    }

    var chr = _data.vis.chrs.filter(function (chr) {
      return chr.name == data.chr && chr.spc == data.spc;
    })[0];

    if (chr !== undefined) {
      if ("start" in data) {
        data._vstartpx =
          (chr._x / params.chr.rate +
            parseInt(data.start) -
            (brush_chr._x / params.chr.rate + brush_start) +
            (margin + params.chr.padding.l * (chr._index - brush_chr._index)) /
              params.chr.rate) *
          rate;
        data._vendpx =
          (chr._x / params.chr.rate +
            parseInt(data.end) -
            (brush_chr._x / params.chr.rate + brush_start) +
            (margin + params.chr.padding.l * (chr._index - brush_chr._index)) /
              params.chr.rate) *
          rate;
      } else if ("pos" in data) {
        data._vpospx =
          (chr._x / params.chr.rate +
            parseInt(data.pos) -
            (brush_chr._x / params.chr.rate + brush_start) +
            (margin + params.chr.padding.l * (chr._index - brush_chr._index)) /
              params.chr.rate) *
          rate;

        data._vstartpx =
          ((chr._x / params.chr.rate +
            parseInt(data.pos - 1) -
            (brush_chr._x / params.chr.rate + brush_start) +
            (margin + params.chr.padding.l * (chr._index - brush_chr._index)) /
              params.chr.rate) *
            rate +
            data._vpospx) /
          2;
        data._vendpx =
          ((chr._x / params.chr.rate +
            parseInt(data.pos) -
            (brush_chr._x / params.chr.rate + brush_start) +
            (margin + params.chr.padding.l * (chr._index - brush_chr._index)) /
              params.chr.rate) *
            rate +
            data._vpospx) /
          2;
      }
    }
  }

  function Draw_chromosomes(spcs, chrs, params, sfs = undefined) {
    const cc = cancelableClick({
      tolerance: 10,
      timeout: 300,
    });

    var svg = d3.select("#" + params.canvas).select("svg");

    if (svg.select("#g_sfs").empty()) {
      svg.append("g").attr("id", "g_sfs");
    }

    if (svg.select("#g_chrs").empty()) {
      svg.append("g").attr("id", "g_chrs");
    }

    if (svg.select("#g_opts").empty()) {
      svg
        .append("g")
        .attr("id", "g_opts")
        .on("click", function () {
          _data.vis.chrs = $.extend(true, [], _data.all.chrs);
          _data.vis.sfs = $.extend(true, [], _data.all.merge_sfs);

          Draw_chromosomes(_data.all.spcs, _data.vis.chrs, _utils.params);
          Draw_synteny(
            _data.all.spcs,
            _data.vis.sfs,
            _data.vis.chrs,
            _utils.params
          );

          Find_breakpointregion();
          Pinpoint_region(_data.vis.pin_types);
        });
    }

    if (svg.select("#g_pins").empty()) {
      svg.append("g").attr("id", "g_pins");
    }

    var canvas = svg.select("#g_chrs");

    var spcnames = canvas.selectAll(".g_spcname").data(_data.all.spcs);

    spcnames.exit().remove();

    var spcnameg = spcnames.enter().append("g").attr("class", "g_spcname");

    spcnameg.append("path").attr("class", "namepath").attr("fill", "none");

    if (params.layout == "linear") {
      var pinlayers = 0;
      if ("pin_types" in _data.vis) {
        pinlayers = Object.keys(_data.vis.pin_types).length;
      }

      canvas.attr("transform", "translate(1," + (1 + pinlayers * 9) + ")");
      d3.selectAll("#g_opts, #g_pins").attr(
        "transform",
        "translate(1," + (1 + pinlayers * 9) + ")"
      );

      canvas.selectAll(".g_spcname").select("text").remove();
      canvas
        .selectAll(".g_spcname")
        .append("text")
        .attr("class", "spcname")
        .attr("alignment-baseline", "middle")
        .text((d) => d.replaceAll("_", " "))
        .attr("transform", function (d, i) {
          var y = Set_species_ypos(i, spcs.length, params);
          return "translate(1, " + (y + params.chr.width / 2 + 1) + ")";
        });
    }

    Preprocess_chrData(chrs, spcs, params);

    if (params.layout == "circular") {
      var spc_angle = {};

      chrs.forEach(function (chr) {
        if (!(chr.spc in spc_angle)) {
          spc_angle[chr.spc] = {
            startAngle: -1,
            endAngle: -1,
          };
        }
        if (
          spc_angle[chr.spc].startAngle == -1 ||
          spc_angle[chr.spc].startAngle > chr.startAngle
        ) {
          spc_angle[chr.spc].startAngle = chr.startAngle;
        }
        if (
          spc_angle[chr.spc].endAngle == -1 ||
          spc_angle[chr.spc].endAngle < chr.endAngle
        ) {
          spc_angle[chr.spc].endAngle = chr.endAngle;
        }
      });

      var center = params.tracks.length
        ? params.chr.width_fig.c / 2 + 1
        : params.chr.width_fig.l / 2 + 1;

      canvas.attr(
        "transform",
        "translate(" + center + "," + (params.height / 2 + 1) + ")"
      );
      d3.selectAll("#g_opts, #g_pins").attr(
        "transform",
        "translate(" + center + "," + (params.height / 2 + 1) + ")"
      );

      canvas
        .selectAll(".namepath")
        .attr("d", (d) =>
          Draw_arc(
            params.chr.r + 40,
            params.chr.r + 40,
            spc_angle[d].startAngle,
            spc_angle[d].endAngle
          )
        )
        .attr("id", function (d, i) {
          return "namepath" + i;
        })
        .attr("fill", "none");

      canvas.selectAll(".g_spcname").select("text").remove();
      canvas
        .selectAll(".g_spcname")
        .append("text")
        .attr("class", "spcname")
        .style("text-anchor", "middle")
        .append("textPath")
        .attr("class", "pspcname")
        .attr("startOffset", "25%")
        .attr("xlink:href", function (d, i) {
          return "#namepath" + i;
        })
        .text((d) => d);
    }

    var canvas = d3
      .select("#" + params.canvas)
      .select("svg")
      .select("#g_chrs");

    var chrsg = canvas.selectAll("g.g_chr").data(chrs);

    chrsg.exit().remove();

    var chrg = chrsg
      .enter()
      .append("g")
      .attr("class", (d) => "g_chr")
      .on("mouseover", function (evt, d) {
        var svgpos = this.getScreenCTM();
        var pos = this.getBBox();

        var content =
          "<p style='margin:0'><span style='color:#ff369b'><b>" +
          d.name +
          "</b></span><i style='margin-left:8px'>" +
          d.spc +
          "</i></p>";

        for (var key in d) {
          if (
            key.indexOf("_") != 0 &&
            key != "startAngle" &&
            key != "endAngle" &&
            key != "name" &&
            key != "spc"
          ) {
            var val = d[key];
            if (key == "len") {
              key = "length";
            }

            if (typeof val == "number") {
              val = val.toLocaleString();
            }

            key = key.replace(/^[a-z]/, (char) => char.toUpperCase());
            content += "<p style='margin:0'>" + key + " : " + val + "</p>";
          }
        }

        Show_tooltip(
          window.pageXOffset + svgpos.e + pos.x + pos.width / 2 - 4,
          window.pageYOffset + svgpos.f + pos.y,
          content,
          "tooltip-" + d._id
        );

        if (!_utils.zoom.brush.ing) {
          d3.select(this).select(".chrname").classed("hidden", false);

          d3.select(this).select(".chr").attr("stroke", "black");
          d3.select(this).select(".chr").attr("stroke-width", 2);

          d3.select(this).select(".chrname").style("font-weight", "bold");
        }
      })
      .on("mouseout", function () {
        Remove_tooltip();

        d3.select(this).select(".chr").attr("stroke", params.chr.stroke);
        d3.select(this)
          .select(".chr")
          .attr("stroke-width", params.chr.stroke_width);

        d3.select(this).each(function (d) {
          if (params.layout == "linear") {
            if (
              d._tflen <=
              d3.select(this).select(".chrname").node().getComputedTextLength()
            ) {
              d3.select(this).select(".chrname").classed("hidden", true);
            }
          } else {
            if (d.endAngle - d.startAngle <= 0.1) {
              d3.select(this).select(".chrname").classed("hidden", true);
            }
          }
        });

        d3.select(this).select(".chrname").style("font-weight", "");
      })
      .call(cc);

    cc.on("click", function (event) {
      d3.select(event.target).each(function (d) {
        if (_utils.zoom.func !== undefined) {
          var spcidx = _data.all.spcs.indexOf(d.spc);
          if (params.layout == "linear") {
            var start = d._x + d._index * params.chr.padding.l;
            var newrange = [start, start + d._tflen];

            d3.select(".gbrush_" + spcidx).call(
              _utils.zoom.brush.func[spcidx].move,
              newrange
            );
          } else {
            var newrange = [d.startAngle, d.endAngle];
            d3.select(".gbrush_" + spcidx).call(
              _utils.zoom.brush.func[spcidx].move(
                newrange,
                d3.select(".gbrush_" + spcidx)
              )
            );
          }
        }
      });
    });
    cc.on("dblclick", function (event) {
      d3.select(event.target).each(function (d) {
        var region = d.name + ":";

        if (
          d._id == _utils.zoom.brush.range[_data.all.spcs.indexOf(d.spc)][1]._id
        ) {
          region += _utils.zoom.brush.range[_data.all.spcs.indexOf(d.spc)][2];
        } else {
          region += "1";
        }

        if (
          d._id == _utils.zoom.brush.range[_data.all.spcs.indexOf(d.spc)][3]._id
        ) {
          region +=
            "-" + _utils.zoom.brush.range[_data.all.spcs.indexOf(d.spc)][4];
        } else {
          region += "-" + d.len;
        }

        _utils.Show_region([_data.all.spcs.indexOf(d.spc), region]);
      });
    });

    var gaxis = chrg.append("g").attr("class", "g_axis");

    chrg.append("path").attr("class", "chr").attr("stroke", params.chr.color);

    canvas
      .selectAll("g.g_chr")
      .select("path.chr")
      .attr("fill", function (d) {
        return params.color_spc(d.spc);
      })
      .attr("d", function (d) {
        if (params.layout == "linear") {
          var path;
          var chrbegin =
              d._x + params.chr.padding.l * d._index + params.chr.start,
            chrend = chrbegin + d._tflen;

          path = d3.path();
          path.moveTo(chrbegin, d._y);
          path.lineTo(chrbegin, d._y + params.chr.width);
          path.lineTo(chrend, d._y + params.chr.width);
          path.lineTo(chrend, d._y);
          path.lineTo(chrbegin, d._y);

          return path;
        } else {
          var outer_radius = params.chr.r - 20;
          var inner_radius = outer_radius - params.chr.width;

          return Draw_arc(inner_radius, outer_radius, d.startAngle, d.endAngle);
        }
      });

    canvas.selectAll(".g_chr").selectAll(".chrpath").remove();

    if (params.layout == "linear") {
      canvas.selectAll(".g_chr").select(".chrname").remove();
      canvas
        .selectAll(".g_chr")
        .append("text")
        .attr("class", "chrname")
        .style("text-anchor", "middle")
        .style("cursor", "default")
        .attr(
          "x",
          (d) =>
            d._x +
            params.chr.padding.l * d._index +
            d._tflen / 2 +
            params.chr.start
        )
        .attr("y", (d) => d._y + params.chr.width / 2 + 2)
        .text((d) => d.name)
        .attr("alignment-baseline", "middle")
        .attr("font-weight", "bold")
        .style("font-size", "0.63rem");

      canvas
        .selectAll(".g_chr")
        .select(".chrname")
        .each(function (chr) {
          if (chr._tflen <= this.getComputedTextLength()) {
            d3.select(this).classed("hidden", true);
          }
        });
    } else {
      canvas
        .selectAll(".g_chr")
        .append("path")
        .attr("class", "chrpath")
        .attr("fill", "none")
        .attr("d", function (d) {
          return Draw_arc(
            params.chr.r - 20 - params.chr.width / 2 - 4,
            params.chr.r - 20 - params.chr.width / 2 - 4,
            d.startAngle - 0.1,
            d.endAngle + 0.1
          );
        })
        .attr("id", function (d) {
          return "chrpath" + d._id;
        });

      canvas.selectAll(".g_chr").select(".chrname").remove();
      canvas
        .selectAll(".g_chr")
        .append("text")
        .attr("font-weight", "bold")
        .attr("class", function (d) {
          if (d.endAngle - d.startAngle <= 0.1) {
            return "chrname hidden";
          }
          return "chrname";
        })
        .style("text-anchor", "middle")
        .append("textPath")
        .attr("class", "pchrname")
        .attr("startOffset", "25%")
        .attr("xlink:href", function (d) {
          return "#chrpath" + d._id;
        })
        .style("cursor", "default")
        .text(function (d) {
          return d.name;
        })
        .style("font-size", "0.63rem");
    }

    Draw_x_axis("sf");
    if (_utils.zoom.func !== undefined) {
      Set_zoom();
    } else {
      _data.all.spcs.forEach(function (d, i) {
        var spcchrs = _data.all.chrs.filter(function (chr) {
          return chr.spc == d;
        });
        _utils.zoom.brush.range[i] = [
          0,
          spcchrs[0],
          1,
          spcchrs[0],
          spcchrs[0].len,
          0,
        ];
      });
    }
  }

  function Draw_synteny(spcs, sfs, chrs, params) {
    var ribbon_data = [];
    var canvas = d3.select("#" + params.canvas).select("#g_sfs");

    if (params.layout == "linear") {
      var pinlayers = 0;
      if ("pin_types" in _data.vis) {
        pinlayers = Object.keys(_data.vis.pin_types).length;
      }
      canvas.attr("transform", "translate(1," + (1 + pinlayers * 9) + ")");
    } else {
      var center = params.tracks.length
        ? params.chr.width_fig.c / 2 + 1
        : params.chr.width_fig.l / 2 + 1;

      canvas.attr(
        "transform",
        "translate(" + center + "," + (params.height / 2 + 1) + ")"
      );
    }

    sfs.forEach(function (sf) {
      var sfspc = Object.keys(sf.pos).sort(function (a, b) {
        return spcs.indexOf(a) - spcs.indexOf(b);
      });

      for (var i = 0; i < sfspc.length - 1; ++i) {
        var rspc = sfspc[i],
          tspc = sfspc[i + 1];

        var rchr = chrs.filter(function (chr) {
          return chr.spc == rspc && chr.name == sf.pos[rspc].chr;
        })[0];

        var tchr = chrs.filter(function (chr) {
          return chr.spc == tspc && chr.name == sf.pos[tspc].chr;
        })[0];

        if (rchr && tchr) {
          if (params.layout == "linear") {
            var rchrlen = rchr._vstart - rchr._vend + 1;
            var rdir = sf.pos[rspc].dir;
            var rchrstart =
              rchr._x + rchr._index * params.chr.padding.l + params.chr.start;
            var vrstart =
              rchrstart + (sf.pos[rspc].start - rchr._vstart) * params.chr.rate;
            var vrend =
              rchrstart + (sf.pos[rspc].end - rchr._vstart) * params.chr.rate;

            var tchrlen = tchr._vstart - tchr._vend + 1;
            var tdir = sf.pos[tspc].dir;
            var tchrstart =
              tchr._x + tchr._index * params.chr.padding.l + params.chr.start;
            var vtstart =
              tchrstart + (sf.pos[tspc].start - tchr._vstart) * params.chr.rate;
            var vtend =
              tchrstart + (sf.pos[tspc].end - tchr._vstart) * params.chr.rate;
          } else {
            var rchrlen = rchr._vstart - rchr._vend + 1;
            var rdir = sf.pos[rspc].dir;
            var rchrstart = rchr.startAngle;
            var vrstart =
              rchrstart +
              ((sf.pos[rspc].start - rchr._vstart) /
                (rchr._vend - rchr._vstart)) *
                (rchr.endAngle - rchr.startAngle);
            var vrend =
              rchrstart +
              ((sf.pos[rspc].end - rchr._vstart) /
                (rchr._vend - rchr._vstart)) *
                (rchr.endAngle - rchr.startAngle);

            var tchrlen = tchr._vstart - tchr._vend + 1;
            var tdir = sf.pos[tspc].dir;
            var tchrstart = tchr.startAngle;
            var vtstart =
              tchrstart +
              ((sf.pos[tspc].start - tchr._vstart) /
                (tchr._vend - tchr._vstart)) *
                (tchr.endAngle - tchr.startAngle);
            var vtend =
              tchrstart +
              ((sf.pos[tspc].end - tchr._vstart) /
                (tchr._vend - tchr._vstart)) *
                (tchr.endAngle - tchr.startAngle);
          }

          var each_ribbon = {
            id: sf.id,
            source: {
              spc: rspc,
              spc_chr: rchr,
              _xstart: vrstart,
              _xend: vrend,
              _y: rchr._y,
              start: sf.pos[rspc].start,
              end: sf.pos[rspc].end,
            },
            target: {
              spc: tspc,
              spc_chr: tchr,
              _xstart: vtstart,
              _xend: vtend,
              _y: tchr._y,
              start: sf.pos[tspc].start,
              end: sf.pos[tspc].end,
            },
            orientation: rdir == tdir ? "+" : "-",
          };

          ribbon_data.push(each_ribbon);
        }
      }
    });

    ribbon_data = ribbon_data.sort(function (a, b) {
      var alen =
          a.source.end - a.source.start + 1 + a.target.end - a.target.start + 1,
        blen =
          b.source.end - b.source.start + 1 + b.target.end - b.target.start + 1;

      return blen - alen;
    });

    var gsf = canvas.selectAll("g.g_sf").data(ribbon_data);
    gsf.exit().remove();

    gsf
      .enter()
      .append("g")
      .attr("class", "g_sf")
      .append("path")
      .attr("fill", params.sf.fill)
      .attr("stroke", params.sf.stroke)
      .attr("opacity", 0.6);

    canvas
      .selectAll("g.g_sf")
      .select("path")
      .attr("class", (d) => "sf sf-" + d.id)
      .attr("d", function (d) {
        return params.layout == "linear"
          ? Make_ribbon(d)
          : Make_ribbon(
              d,
              params.chr.r - 20 - params.chr.width,
              params.chr.padding.c
            );
      })
      .on("mouseover", function (evt, d) {
        d3.selectAll(".bkg_sf").attr("fill", "grey");
        d3.selectAll(".sf-" + d.id)
          .attr("fill", "#00a779")
          .style("opacity", 0.6)

        var svgpos = this.getScreenCTM();
        var pos = this.getBBox();

        var sfinfo = _data.vis.sfs.filter(function (sf) {
          return sf.id == d.id;
        })[0];

        var content =
          "<p style='margin:0'><span style='color:#52dbc7'><b> Synteny " +
          sfinfo.id +
          "</b></p>";

        var link = "";
        for (var spc in sfinfo.pos) {
          var spcinfo = sfinfo.pos[spc];

          content +=
            "<p style='margin:0;'><i>" +
            link +
            spc +
            ".</i>" +
            spcinfo.chr +
            ":" +
            parseInt(spcinfo.start).toLocaleString() +
            "-" +
            parseInt(spcinfo.end).toLocaleString() +
            " " +
            spcinfo.dir +
            "</p>";

          link = " - ";
        }

        for (var key in sfinfo) {
          if (key.indexOf("_") != 0 && key != "pos" && key != "id") {
            var val = d[key];
            if (key == "len") {
              key = "length";
            }

            if (typeof val == "number") {
              val = val.toLocaleString();
            }

            if (typeof val == "object") {
              val = JSON.stringify(val);
            }

            if (Array.isArray(val)) {
              val = val.toString();
            }

            key = key.replace(/^[a-z]/, (char) => char.toUpperCase());
            content += "<p style='margin:0;'>" + key + " : " + val + "</p>";
          }
        }

        for (var key in d) {
          if (
            key.indexOf("_") != 0 &&
            key != "startAngle" &&
            key != "endAngle" &&
            key != "name" &&
            key != "spc" &&
            key != "source" &&
            key != "target" &&
            key != "orientation" &&
            key != "id"
          ) {
            var val = d[key];
            if (key == "len") {
              key = "length";
            }

            if (typeof val == "number") {
              val = val.toLocaleString();
            }

            key = key.replace(/^[a-z]/, (char) => char.toUpperCase());
            content += "<p style='margin:0'>" + key + " : " + val + "</p>";
          }
        }

        Show_tooltip(
          window.pageXOffset + svgpos.e + pos.x + pos.width + 4,
          window.pageYOffset + svgpos.f + pos.y + pos.height / 2,
          content,
          "tooltip-" + d.id,
          "left"
        );
      })
      .on("mouseout", function (evt, d) {
        Remove_tooltip();

        d3.selectAll(".sf-" + d.id).attr("fill", params.sf.fill);
        d3.selectAll(".bkg_sf")
          .attr("fill", function () {
            const reg = new RegExp(/gchart-[0-9]+/);
            var spcidx = Number(
              d3
                .select(this.parentNode.parentNode)
                .attr("class")
                .match(reg)[0]
                .replace("gchart-", "")
            );

            return params.color_spc(_data.all.spcs[spcidx]);
          })
          .style("opacity", 0.2);
      })
      .on("click", function (evt, d) {
        var sfinfo = {};
        var sfpos = {};
        d3.select("#" + params.canvas)
          .selectAll(".g_sf")
          .filter(function (sf) {
            return sf.id == d.id;
          })
          .each(function (sf) {
            sfpos[_data.all.spcs.indexOf(sf.source.spc)] = [
              sf.source.spc_chr,
              sf.source.start,
              sf.source.end,
            ];
            sfpos[_data.all.spcs.indexOf(sf.target.spc)] = [
              sf.target.spc_chr,
              sf.target.start,
              sf.target.end,
            ];

            sfinfo[sf.source.spc] = [sf.source._xstart, sf.source._xend];
            sfinfo[sf.target.spc] = [sf.target._xstart, sf.target._xend];
          });

        if (_utils.zoom.func !== undefined) {
          for (var spc in sfinfo) {
            var spcidx = _data.all.spcs.indexOf(spc);
            var newrange = sfinfo[spc];

            if (params.layout == "linear") {
              d3.select(".gbrush_" + spcidx).call(
                _utils.zoom.brush.func[spcidx].move,
                newrange
              );
            } else {
              d3.select(".gbrush_" + spcidx).call(
                _utils.zoom.brush.func[spcidx].move(
                  newrange,
                  d3.select(".gbrush_" + spcidx)
                )
              );
            }
          }
          for (var spcidx in sfpos) {
            _utils.zoom.brush.range[spcidx] = [
              0,
              sfpos[spcidx][0],
              sfpos[spcidx][1],
              sfpos[spcidx][0],
              sfpos[spcidx][2],
              0,
            ];
          }
        }

        d3.selectAll(".bkg_sf").attr("fill", "grey");
        d3.selectAll(".sf-" + d.id)
          .attr("fill", "#00a779")
          .style("opacity", 0.6)
          .each(function () {
            d3.select(this.parentNode).raise();
          });
      });

    function Make_ribbon(data, radius = undefined, padAngle = undefined) {
      if (radius === undefined) {
        var dots = [
          [
            [data["source"]._xstart, data["source"]._y],
            [data["source"]._xend, data["source"]._y],
          ],
          [
            [data["target"]._xstart, data["target"]._y],
            [data["target"]._xend, data["target"]._y],
          ],
        ];

        if (data.orientation == "-") {
          var dots = [
            [
              [data["source"]._xstart, data["source"]._y],
              [data["source"]._xend, data["source"]._y],
            ],
            [
              [data["target"]._xend, data["target"]._y],
              [data["target"]._xstart, data["target"]._y],
            ],
          ];
        }

        dots.sort(function (a, b) {
          return a[0][1] - b[0][1];
        });

        var interval = dots[1][0][1] - dots[0][0][1];
        dots.forEach(function (dot, i) {
          if (i == 0) {
            dot[0][1] += interval * 0.02;
            dot[1][1] += interval * 0.02;
          } else {
            dot[0][1] -= interval * 0.02;
            dot[1][1] -= interval * 0.02;
          }
        });

        var path = d3.path();
        path.moveTo(dots[0][0][0], dots[0][0][1]);

        for (var i = 0; i < dots.length; ++i) {
          if (i != 0) {
            path.lineTo(dots[i][1][0], dots[i][1][1] - 5);
          }

          path.lineTo(dots[i][1][0], dots[i][1][1]);
          path.lineTo(dots[i][1][0], dots[i][1][1] + 15);

          if (i != dots.length - 1) {
            path.lineTo(dots[i][1][0], dots[i][1][1] + 20);
          }
        }
        for (var i = dots.length - 1; i >= 0; --i) {
          if (i != dots.length - 1) {
            path.lineTo(dots[i][0][0], dots[i][0][1] + 20);
          }

          path.lineTo(dots[i][0][0], dots[i][0][1] + 15);
          path.lineTo(dots[i][0][0], dots[i][0][1]);

          if (i != 0) {
            path.lineTo(dots[i][0][0], dots[i][0][1] - 5);
          }
        }

        return path;
      } else {
        var source = data.source,
          target = data.target,
          sourceRadius = radius,
          targetRadius = radius;

        var p = d3.path();
        var halfPi = Math.PI / 2;
        var s = source,
          t = target,
          ap = padAngle / 2,
          sr = +sourceRadius,
          sa0 = source._xstart - halfPi,
          sa1 = source._xend - halfPi,
          tr = +targetRadius,
          ta0 = target._xstart - halfPi,
          ta1 = target._xend - halfPi;

        // add pading
        if (ap > Math.epsilon) {
          if (Math.abs(sa1 - sa0) > ap * 2 + Math.epsilon)
            sa1 > sa0 ? ((sa0 += ap), (sa1 -= ap)) : ((sa0 -= ap), (sa1 += ap));
          else sa0 = sa1 = (sa0 + sa1) / 2;
          if (Math.abs(ta1 - ta0) > ap * 2 + Math.epsilon)
            ta1 > ta0 ? ((ta0 += ap), (ta1 -= ap)) : ((ta0 -= ap), (ta1 += ap));
          else ta0 = ta1 = (ta0 + ta1) / 2;
        }

        p.moveTo(sr * Math.cos(sa0), sr * Math.sin(sa0));
        p.arc(0, 0, sr, sa0, sa1);
        if (sa0 !== ta0 || sa1 !== ta1) {
          p.quadraticCurveTo(0, 0, tr * Math.cos(ta0), tr * Math.sin(ta0));
          if (ta0 < ta1) {
            p.arc(0, 0, tr, ta0, ta1);
          } else {
            p.arc(0, 0, tr, ta0, ta1, true);
          }
        }
        p.quadraticCurveTo(0, 0, sr * Math.cos(sa0), sr * Math.sin(sa0));
        p.closePath();

        return p._;
      }
    }
  }

  function Draw_arc(iradius, oradius, startAngle, endAngle) {
    var arc = d3.arc();
    return arc({
      innerRadius: iradius,
      outerRadius: oradius,
      startAngle: startAngle,
      endAngle: endAngle,
    });
  }

  function Pinpoint_region(color) {
    var params = _utils.params;
    var chr_padding = params.chr.padding.l;
    var canvas = d3.select("#" + params.canvas).select("#g_pins");
    var downsample_size = 50000000;
    if (_data.vis.chrs.length < 10) {
      downsample_size = 5000000;
    }


    if (params.layout == "linear") {
      Update_svg();
      Make_tracks();

      var pinlayers = 0;
      if ("pin_types" in _data.vis) {
        pinlayers = Object.keys(_data.vis.pin_types).length;
      }

      d3.selectAll("#g_sfs, #g_chrs, #g_opts, #g_pins, .gbrush").attr(
        "transform",
        "translate(1," + (1 + pinlayers * 9) + ")"
      );
    }

    var id = 0;
    var layer = 0;

    for (var type in _data.all.highlight) {
      if (_data.all.highlight[type].length) {
        layer += 1;
      }

      var downsamples = {};
      _data.all.spcs.forEach(function (spc) {
        downsamples[spc] = {};

        var spcdat = _data.all.highlight[type].filter(function (bp, i) {
          return bp.spc == spc;
        });

        spcdat.forEach(function (bp) {
          bp._id = ++id;
          var chr = _data.vis.chrs.filter(function (chr) {
            return chr.spc == bp.spc && chr.name == bp.chr;
          })[0];

          if (chr) {
            var bpmed = (Number(bp.start) + Number(bp.end)) / 2;
            var downsample_bin = parseInt(bpmed / downsample_size);
            var downsample_bin_start =
              Number(downsample_bin) * downsample_size + 1;
            var downsample_bin_end =
              chr.len < (Number(downsample_bin) + 1) * downsample_size
                ? chr.len
                : (Number(downsample_bin) + 1) * downsample_size;

            var bininfo =
              chr.name +
              "&^&" +
              downsample_bin_start +
              "&^&" +
              downsample_bin_end;

            if (bininfo in downsamples[spc]) {
              downsamples[spc][bininfo].push(bp._id);
            } else {
              downsamples[spc][bininfo] = [bp._id];
            }
          }
        });
      });

      var downsample_dat = [];
      if (type in _data.vis.pin_types) {
        for (var spc in downsamples) {
          var size = d3
            .scaleLinear()
            .domain([
              d3.min(
                Object.keys(downsamples[spc]),
                (d) => downsamples[spc][d].length
              ),
              d3.max(
                Object.keys(downsamples[spc]),
                (d) => downsamples[spc][d].length
              ),
            ])
            .range([2.5, 5]);

          for (var chrbin in downsamples[spc]) {
            var cols = chrbin.split(/&\^&/);
            var chr = cols[0];
            var binstart = cols[1];
            var binend = cols[2];

            var newdata = {
              spc: spc,
              chr: chr,
              type: type,
              start: Number(binstart),
              end: Number(binend),
              raw: downsamples[spc][chrbin],
              _r: size(downsamples[spc][chrbin].length),
            };

            downsample_dat.push(newdata);
          }
        }

        _data.all.spcs.forEach(function (spc) {
          var spcdat = downsample_dat.filter(function (bp) {
            return bp.spc == spc;
          });

          spcdat
            .sort(function (a, b) {
              var achr = _data.vis.chrs.filter(function (chr) {
                return chr.spc == a.spc && chr.name == a.chr;
              })[0];

              var bchr = _data.vis.chrs.filter(function (chr) {
                return chr.spc == b.spc && chr.name == b.chr;
              })[0];

              return (
                achr._index - bchr._index || Number(a.start) - Number(b.start)
              );
            })
            .forEach(function (bp, i) {
              var chr = _data.vis.chrs.filter(function (chr) {
                return chr.spc == bp.spc && chr.name == bp.chr;
              })[0];

              var bpmed = (bp.start + bp.end) / 2;
              if (params.layout == "linear") {
                bp._y = chr._y - 12 - 9 * (layer - 1);

                var bpx =
                  chr._x +
                  chr._index * chr_padding +
                  (bpmed / chr.len) * chr._tflen;

                var original_bpx = bpx;
                if (bpx + 4 > params.width) {
                  bpx = params.width - 4;
                }

                if (i && bpx - spcdat[i - 1]._x < 6) {
                  bpx += 3;
                  spcdat[i - 1]._x = bpx - 6;

                  var j = i - 1;
                  while (j && spcdat[j]._x - spcdat[j - 1]._x < 6) {
                    spcdat[j - 1]._x = spcdat[j]._x - 6;
                    j--;
                  }
                }

                bp._x = bpx;
                bp._ox = original_bpx;
                //bp._oy = bp._y + 12 + 9 * (layer - 1);
                bp._oy = chr._y;
              } else {
                var bpangle =
                  chr.startAngle +
                  ((chr.endAngle - chr.startAngle) / chr.len) * bpmed;

                var original_bpangle = bpangle;

                if (i && bpangle - spcdat[i - 1]._angle < 0.02) {
                  bpangle += 0.01;
                  spcdat[i - 1]._angle = bpangle - 0.02;
                  spcdat[i - 1]._x =
                    ((params.chr.r +
                      40 -
                      params.chr.width +
                      params.chr.r -
                      10 +
                      15 * (layer - 1)) /
                      2) *
                    Math.sin(spcdat[i - 1]._angle);
                  spcdat[i - 1]._y =
                    -1 *
                    ((params.chr.r +
                      40 -
                      params.chr.width +
                      params.chr.r -
                      10 +
                      15 * (layer - 1)) /
                      2) *
                    Math.cos(spcdat[i - 1]._angle);

                  var j = i - 1;
                  while (j && spcdat[j]._angle - spcdat[j - 1]._angle < 0.02) {
                    spcdat[j - 1]._angle = spcdat[j]._angle - 0.02;
                    spcdat[j - 1]._x =
                      ((params.chr.r +
                        40 -
                        params.chr.width +
                        params.chr.r -
                        10 +
                        15 * (layer - 1)) /
                        2) *
                      Math.sin(spcdat[j - 1]._angle);
                    spcdat[j - 1]._y =
                      -1 *
                      ((params.chr.r +
                        40 -
                        params.chr.width +
                        params.chr.r -
                        10 +
                        15 * (layer - 1)) /
                        2) *
                      Math.cos(spcdat[j - 1]._angle);
                    j--;
                  }
                }

                bp._oangle = original_bpangle;
                bp._angle = bpangle;
                bp._x =
                  ((params.chr.r +
                    40 -
                    params.chr.width +
                    params.chr.r -
                    10 +
                    15 * (layer - 1)) /
                    2) *
                  Math.sin(bp._angle);
                bp._y =
                  -1 *
                  ((params.chr.r +
                    40 -
                    params.chr.width +
                    params.chr.r -
                    10 +
                    15 * (layer - 1)) /
                    2) *
                  Math.cos(bp._angle);
              }
            });
        });
      }

      var pins = canvas.selectAll(".pin_" + type).data(downsample_dat);
      pins.exit().remove();
      pins
        .enter()
        .append("g")
        .attr("class", "pin_" + type);

      d3.selectAll(".pin_" + type)
        .attr("chr", (d) => d.chr)
        .on("mouseover", function (evt, d) {
          d3.select(this).select("circle").style("fill", "grey");
          d3.select(this)
            .select("path")
            .style("stroke-width", "2px")
            .style("stroke-dasharray", "1, 0")
            .attr("d", function (d) {
              if (params.layout == "linear") {
                return d3.line()([
                  [d._x, d._y + 3],
                  [d._x, d._y + 5],
                  [d._ox, d._y + 7],
                  [d._ox, d._oy + params.chr.width],
                ]);
              } else {
                var cx1 = (params.chr.r - 20 + 3) * Math.sin(d._oangle);
                var cy1 = -1 * (params.chr.r - 20 + 3) * Math.cos(d._oangle);

                var cx2 = (params.chr.r - 20 + 8) * Math.sin(d._oangle);
                var cy2 = -1 * (params.chr.r - 20 + 8) * Math.cos(d._oangle);

                var cx3 =
                  (params.chr.r - 20 - params.chr.width) * Math.sin(d._oangle);
                var cy3 =
                  -1 *
                  (params.chr.r - 20 - params.chr.width) *
                  Math.cos(d._oangle);

                return d3.line()([
                  [cx1, cy1],
                  [cx2, cy2],
                  [d._x, d._y],
                  [cx3, cy3],
                ]);
              }
            });
        })
        .on("mouseout", function (evt, d) {
          d3.select(this)
            .select("circle")
            .style("fill", type in color ? color[d.type].color : "");
          d3.select(this)
            .select("path")
            .style("stroke-width", "1px")
            .style("stroke-dasharray", "1, 1")
            .attr("d", function (d) {
              if (params.layout == "linear") {
                return d3.line()([
                  [d._x, d._y + 3],
                  [d._x, d._y + 5],
                  [d._ox, d._y + 7],
                  [d._ox, d._oy],
                ]);
              } else {
                var cx1 = (params.chr.r - 20 + 3) * Math.sin(d._oangle);
                var cy1 = -1 * (params.chr.r - 20 + 3) * Math.cos(d._oangle);

                var cx2 = (params.chr.r - 20 + 8) * Math.sin(d._oangle);
                var cy2 = -1 * (params.chr.r - 20 + 8) * Math.cos(d._oangle);

                return d3.line()([
                  [cx1, cy1],
                  [cx2, cy2],
                  [d._x, d._y],
                ]);
              }
            });
        })
        .on("click", function (evt, d) {
          var pos = d3
            .select("#" + params.canvas)
            .select("svg")
            .node()
            .getScreenCTM();

          $("#pin_popup")
            .css(
              "height",
              params.layout == "linear"
                ? params.chr.height_fig.l
                : params.chr.height_fig.c
            )
            .css(
              "left",
              d._x > params.width / 2
                ? window.pageXOffset + pos.e + "px"
                : window.pageXOffset +
                    pos.e +
                    params.width -
                    $("#pin_popup").width() +
                    1 +
                    "px"
            )
            .css("top", window.pageYOffset + pos.f - 1 + "px");

          var pin_eles = _data.all.highlight[d.type].filter(function (e) {
            return d.raw.indexOf(e._id) != -1;
          });

          $("#pin_list").empty();
          pin_eles.forEach(function (e) {
            var pos = e.chr + ":" + e.start + "-" + e.end;
            if (e.start == e.end) {
              pos = e.chr + ":" + e.start + "-" + (Number(e.start) + 1);
            }

            var newlist =
              "<div class='px-2 py-1 pin_ele' spc=" +
              _data.all.spcs.indexOf(e.spc) +
              " pos=" +
              pos +
              ">" +
              e.spc +
              " " +
              e.chr +
              ":" +
              e.start +
              "-" +
              e.end +
              "</div>";

            $("#pin_list").append(newlist);
          });

          $(document).on("click", ".pin_ele", function () {
            _utils.Show_region([$(this).attr("spc"), $(this).attr("pos")]);
            $("#pin_popup").slideUp();
          });

          $("#pin_popup").slideDown();
          $("#pin_popup").scrollTop("0");

          var spcidx = _data.all.spcs.indexOf(d.spc);
          var chr = _data.vis.chrs.filter(function (chr) {
            return chr.spc == d.spc && chr.name == d.chr;
          })[0];

          var start = d.start;
          var end = d.end;

          _utils.zoom.brush.range[spcidx] = [0, chr, start, chr, end, 0];
          Set_zoom();

        });

      d3.selectAll(".pin_" + type)
        .selectAll("*")
        .remove();

      if (params.layout == "linear") {
        d3.selectAll(".pin_" + type)
          .append("path")
          .style("stroke", "black")
          .style("fill", "none")
          .style("stroke-dasharray", "2, 2")
          .attr("d", function (d) {
            return d3.line()([
              [d._x, d._y + 3],
              [d._x, d._y + 5],
              [d._ox, d._y + 7],
              [d._ox, d._oy],
            ]);
          });
      } else {
        d3.selectAll(".pin_" + type)
          .append("path")
          .style("stroke", "black")
          .style("fill", "none")
          .style("stroke-dasharray", "1, 1")
          .attr("d", function (d) {
            var cx1 = (params.chr.r - 20 + 3) * Math.sin(d._oangle);
            var cy1 = -1 * (params.chr.r - 20 + 3) * Math.cos(d._oangle);

            var cx2 = (params.chr.r - 20 + 8) * Math.sin(d._oangle);
            var cy2 = -1 * (params.chr.r - 20 + 8) * Math.cos(d._oangle);

            return d3.line()([
              [cx1, cy1],
              [cx2, cy2],
              [d._x, d._y],
            ]);
          });
      }

      d3.selectAll(".pin_" + type)
        .append("circle")
        .attr("cx", (d) => d._x)
        .attr("cy", (d) => d._y)
        .attr("r", (d) => d._r)
        .style("fill", type in color ? color[type].color : "")
        .style("stroke", "black");

      if ("highlight" in _data.vis) {
        _data.vis.highlight[type] = [];

        if (type in _data.all.highlight && type in _data.vis.pin_types) {
          _utils.zoom.brush.range.forEach(function (range) {
            var spc = range[1].spc;
            var chr1 = _data.all.chrs.filter(function (c) {
              return c._id == range[1]._id;
            })[0];
            var chr2 = _data.all.chrs.filter(function (c) {
              return c._id == range[3]._id;
            })[0];

            var fltdata = _data.all.highlight[type].filter(function (d) {
              var curchr = _data.all.chrs.filter(function (c) {
                return c.spc == d.spc && c.name == d.chr;
              })[0];

              return (
                d.spc == spc &&
                chr1._index <= curchr._index &&
                curchr._index <= chr2._index &&
                ((chr1._index == curchr._index &&
                  chr2._index == curchr._index &&
                  d.start + 0 <= range[4] &&
                  range[2] <= d.end + 0) ||
                  (chr1._index == curchr._index &&
                    chr2._index != curchr._index &&
                    range[2] <= d.end + 0) ||
                  (chr1._index != curchr._index &&
                    chr2._index == curchr._index &&
                    d.start + 0 <= range[4]) ||
                  (chr1._index < curchr._index && curchr._index < chr2._index))
              );
            });

            var new_dat = $.extend(true, [], fltdata);
            _data.vis.highlight[type] = $.merge(
              _data.vis.highlight[type],
              new_dat
            );
          });
        }
      }
    }
  }

  function Mark_region(color) {
    var params = _utils.params;
    var plot_width =
      params.layout == "linear" ? params.omics.width.l : params.omics.width.c;
    plot_width -= params.omics.start + 1;
    var dpr = window.devicePixelRatio;

    var visdata = {};

    _data.all.spcs.forEach(function (spc, i) {
      var vislen = 0;
      var brushrate = -1;
      var [margin_f, chr1, begin, chr2, end, margin_b] =
        _utils.zoom.brush.range[i];

      _data.vis.chrs
        .filter(function (chr) {
          return (
            chr.spc == spc &&
            chr1._index <= chr._index &&
            chr._index <= chr2._index
          );
        })
        .forEach(function (chr) {
          vislen += chr._vend - chr._vstart + 1;
        });

      if (vislen) {
        vislen -= begin - 1 + (chr2._vend - end + 1);
      }

      if (params.layout == "linear") {
        brushrate =
          (params.omics.width.l - params.omics.start + 1) /
          (vislen +
            ((chr2._index - chr1._index) * params.chr.padding.l +
              margin_f +
              margin_b) /
              params.chr.rate);
      } else {
        brushrate =
          (params.omics.width.c - params.omics.start + 1) /
          (vislen +
            ((chr2._index - chr1._index) * params.chr.padding.l +
              ((margin_f + margin_b) * params.chr.padding.l) /
                (params.chr.padding.c * 1.5)) /
              params.chr.rate);
      }

      var layer = 0;
      //for (var type in _data.vis.highlight) {
      for (var type in _data.vis.pin_types) {
        var spcdat = _data.vis.highlight[type].filter(function (d) {
          return d.spc == spc;
        });

        var dat = $.extend(true, [], spcdat);
        dat.forEach(function (d) {
          Set_coordinate(d, margin_f, chr1, begin, brushrate, params);
          d._y = layer * 7;
          d._color = type in color ? color[type].color : "";
        });

        if (spc in visdata) {
          visdata[spc] = $.merge(visdata[spc], dat);
        } else {
          visdata[spc] = dat;
        }

        layer += 1;
      }

    });

    _data.all.spcs.forEach(function (spc, i) {
      if (spc in visdata) {
        d3.selectAll(".g_marks-" + i).each(function () {
          var mark_canvas = $(this)[0];
          var marks_height = Object.keys(_data.all.highlight).length * 10;

          mark_canvas.width = plot_width * dpr;
          mark_canvas.height = marks_height * dpr;
          mark_canvas.style.width = `${plot_width}px`;
          mark_canvas.style.height = `${marks_height}px`;

          var mctx = mark_canvas.getContext("2d");
          mctx.scale(dpr, dpr);
          mctx.clearRect(0, 0, plot_width, marks_height);

          visdata[spc].forEach(function (d) {
            var dx = d._vstartpx;
            var dy = d._y;


            var width = d._vendpx - d._vstartpx + 1;
            var height = 5;

            mctx.fillStyle = d._color;
            mctx.strokeStyle = d._color;
            mctx.fillRect(dx, dy, width, height);
          });
        });
      }
    });
  }

  ///* Omics *///
  function Draw_arrow(context, x1, y1, x2, y2, color, t = 0.9) {
    const arrow = {
      dx: x2 - x1,
      dy: y2 - y1,
    };
    const middle = {
      x: arrow.dx * t + x1,
      y: arrow.dy * t + y1,
    };
    const tip = {
      dx: x2 - middle.x,
      dy: y2 - middle.y,
    };

    context.beginPath();
    context.moveTo(x1, y1);
    context.lineTo(middle.x, middle.y);
    context.moveTo(middle.x + 0.5 * tip.dy, middle.y - 0.5 * tip.dx);
    context.lineTo(middle.x - 0.5 * tip.dy, middle.y + 0.5 * tip.dx);
    context.lineTo(x2, y2);
    context.closePath();

    context.fillStyle = color;
    context.fill();
  }

  function Update_trackcontent(tspc = undefined) {
    Get_alndata();
    var spcs = tspc === undefined ? _data.all.spcs : [tspc];
    spcs.forEach(function (spc) {
      var spcidx = _data.all.spcs.indexOf(spc);
      var brushed = _utils.zoom.brush.range[spcidx];

      var vischrs = _data.vis.chrs.filter(function (chr) {
        return (
          chr.spc == spc &&
          brushed[1]._index <= chr._index &&
          chr._index <= brushed[3]._index
        );
      });

      var ranges = [];
      vischrs.forEach(function (chr) {
        var range = chr.name + ":";
        if (chr._id == brushed[1]._id) {
          range += brushed[2] + "-";
        } else {
          range += chr._vstart + "-";
        }

        if (chr._id == brushed[3]._id) {
          range += brushed[4];
        } else {
          range += chr._vend;
        }
        ranges.push(range);
      });

      var range_str = ranges.join(" ");
      if (spcs.indexOf(spc) != -1) {
        var tracks = _utils.params.tracks.filter(function (tr) {
          return tr.species == spc;
        });

        tracks.forEach((d) => Get_trackdata(d, range_str));
      }
    });
  }

  function Get_alndata() {
    if (_data.all["alnpath"] === undefined) {
      return false;
    }

    var aln_ranges = [];
    _data.all.spcs.forEach(function (spc) {
      var spcidx = _data.all.spcs.indexOf(spc);
      var brushed = _utils.zoom.brush.range[spcidx];

      var vischrs = _data.vis.chrs.filter(function (chr) {
        return (
          chr.spc == spc &&
          brushed[1]._index <= chr._index &&
          chr._index <= brushed[3]._index
        );
      });

      var ranges = [];
      vischrs.forEach(function (chr) {
        var range = spc + ":" + chr.name + ":";
        if (chr._id == brushed[1]._id) {
          range += brushed[2] + "-";
        } else {
          range += chr._vstart + "-";
        }

        if (chr._id == brushed[3]._id) {
          range += brushed[4];
        } else {
          range += chr._vend;
        }
        ranges.push(range);
      });

      var range_str = ranges.join(" ");
      aln_ranges.push(range_str);
    });

    var aln_ranges_str = aln_ranges.sort().join(" ");
    if (aln_ranges_str == _data.all["match_q"]) {
      return;
    }

    if (aln_ranges.length) {
      _data.all["match_q"] = aln_ranges_str;

      if (_utils.cursor.job) {
        _utils.cursor.job.abort();
        _utils.cursor.job = null;
      }
      $.ajaxSettings.async = false;
      _utils.cursor.job = $.ajax({
        url: _utils.phpscr_path + "/get_alnpos.php",
        type: "get",
        data: {
          alnpath: _data.all["alnpath"],
          refspc: _data.all.spcs[0],
          position: aln_ranges_str,
        },
      }).done(function (result) {
        if (result.indexOf("__ERROR__") == -1) {
          _data.all["match"] = jQuery.parseJSON(result);
        } else {
          console.error("FIX", result);
          _data.all["match"] = [];
        }
      });
      $.ajaxSettings.async = true;
      _utils.cursor.job = null;
    }
  }

  function Get_trackdata(tr, range_str = undefined) {
    var params = _utils.params;
    var spc = tr.species;
    var spcidx = _data.all.spcs.indexOf(spc);

    var vislen = 0;
    var brushrate = -1;
    var resolution = -1;

    var spc = _data.all.spcs[spcidx];
    var brushed = _utils.zoom.brush.range[spcidx];

    if (range_str === undefined) {
      var vischrs = _data.vis.chrs.filter(function (chr) {
        return (
          chr.spc == spc &&
          brushed[1]._index <= chr._index &&
          chr._index <= brushed[3]._index
        );
      });

      var ranges = [];
      vischrs.forEach(function (chr) {
        var range = chr.name + ":";
        if (chr._id == brushed[1]._id) {
          range += brushed[2] + "-";
        } else {
          range += chr._vstart + "-";
        }

        if (chr._id == brushed[3]._id) {
          range += brushed[4];
        } else {
          range += chr._vend;
        }
        ranges.push(range);
      });

      var range_str = ranges.join(" ");
    }

    range_str.split(/\s+/).forEach(function (range) {
      var [chr, start, end] = range.split(/[:-]+/);
      vislen += Number(end) - Number(start) + 1;
    });

    if (_utils.phpscr_path) {
      if (tr.type == "gene") {
        if (params.layout == "linear") {
          brushrate =
            (params.omics.width.l - params.omics.start + 1) /
            (vislen +
              ((brushed[3]._index - brushed[1]._index) * params.chr.padding.l +
                brushed[0] +
                brushed[5]) /
                params.chr.rate);
        } else {
          brushrate =
            (params.omics.width.c - params.omics.start + 1) /
            (vislen +
              ((brushed[3]._index - brushed[1]._index) * params.chr.padding.l +
                ((brushed[0] + brushed[5]) * params.chr.padding.l) /
                  (params.chr.padding.c * 1.5)) /
                params.chr.rate);
        }

        resolution = 1 / brushrate > 500000 ? 500000 : 1 / brushrate;
        if (tr.downsample != "na") {
          resolution = Number(tr.downsample);
        } else {
          resolution = tr.downsample;
        }
      }

      if (range_str != "") {
        $.ajax({
          url: _utils.phpscr_path + "/get_data.php",
          type: "get",
          data: {
            downsample: tr.type == "gene" ? resolution : tr.downsample,
            data: tr.path,
            position: range_str,
          },
        }).done(function (result) {
          if (result.indexOf("__ERROR__") == -1) {
            _data.vis[tr._id] = jQuery.parseJSON(result);
            //  _data.vis[tr._id] = _data.all[tr._id];
          } else {
            console.error("FIX", result);
            _data.vis[tr._id] = [];
          }

          Update_chart(tr);
        });
      } else {
        _data.vis[tr._id] = [];
      }
    } else if ("data" in tr) {
      if (!(tr.id in _data.all) || _data.all[tr.id].length == 0) {
        $.ajaxSettings.async = false;
        $.get(tr.data, function (data) {
          _data.vis[tr._id] = data;
          Update_chart(tr);
        });
        $.ajaxSettings.async = true;
      }
    }
  }

  function Make_tracks() {
    var params = _utils.params;
    var pinlayers = 0;
    if (params.layout == "linear" && "pin_types" in _data.vis) {
      pinlayers = Object.keys(_data.vis.pin_types).length;
    }

    var y =
      params.layout == "linear" ? params.chr.height_fig.l + pinlayers * 9 : 0;
    var tr_y = params.padding.track;

    var canvas = d3.select("#" + params.canvas).select("svg");
    if (params.layout == "circular") {
      var center = params.tracks.length
        ? params.chr.width_fig.c / 2 + 1
        : params.chr.width_fig.l / 2 + 1;

      canvas
        .selectAll("#g_sfs, #g_chrs, #g_opts, #g_pins")
        .attr(
          "transform",
          "translate(" + center + "," + (params.height / 2 + 1) + ")"
        );

      canvas
        .select(".g_brushs")
        .selectAll("g.gbrush")
        .attr(
          "transform",
          "translate(" + center + "," + (params.height / 2 + 1) + ")"
        );
    }

    if (canvas.select("#g_tracks").empty()) {
      canvas.append("g").attr("id", "g_tracks");
    }

    var tr_canvas = canvas.select("#g_tracks").attr("transform", function () {
      if (params.layout == "linear") {
        return "translate(" + params.omics.border_width + ", " + (y + 1) + ")";
      }
      return (
        "translate(" +
        (params.chr.width_fig.c +
          params.omics.border_width -
          1 -
          params.omics.border_width * 4) +
        "," +
        (y + 1) +
        ")"
      );
    });

    tr_canvas.selectAll(".gtrack").each(function (g) {
      var id = this.id.replace("g", "");
      var info = params.tracks.filter(function (tr) {
        return tr._id == id;
      });

      if (!info.length) {
        d3.select(this).remove();
        d3.select("#loading" + id).remove();
        d3.select("#div_canvas_" + id).remove();
        d3.select("#div_mcanvas_" + id).remove();
      }
    });

    params.tracks.forEach(function (tr) {
      var chart_height = tr.oheight - 40;
      if (!("_id" in tr)) {
        tr._id = "t" + tr_id++;
      }

      if (tr_canvas.select("#g" + tr._id).empty()) {
        var gtrack = tr_canvas
          .append("g")
          .attr("id", "g" + tr._id)
          .attr(
            "class",
            (d) => "gtrack gtrack-" + _data.all.spcs.indexOf(tr.species)
          )
          .on("mousemove", function (th) {
            Remove_tooltip();
            Update_cursor(th, tr._id);
          })
          .on("mouseout", function () {
            Remove_tooltip();
          });

        gtrack.append("text").attr("class", "trackname").attr("y", -5);

        gtrack
          .append("text")
          .attr("class", "trackcoord")
          .attr("font-size", "0.875rem")
          .attr("y", -5);

        var gchart = gtrack
          .append("g")
          .attr("class", "gchart gchart-" + _data.all.spcs.indexOf(tr.species))
          .attr("transform", "translate(" + params.omics.border_width + ", 0)")
          .on("dblclick.zoom", null)
          .on("wheel", (event) => event.preventDefault());

        if (_utils.zoom.func !== undefined) {
          gchart.call(_utils.zoom.func);
        }

        gchart
          .append("rect")
          .attr("class", "trackbg")
          .style("fill", "white")
          .style("opacity", 0);

        gchart.append("g").attr("class", "bkg_sfs");

        gchart.append("g").attr("class", "g_chart");

        var gaxes = gchart.append("g").attr("class", "g_axes");

        gaxes
          .append("rect")
          .attr("height", 40)
          .attr(
            "width",
            params.layout == "linear"
              ? params.omics.width.l -
                  params.omics.start +
                  1 -
                  params.omics.start +
                  1
              : params.omics.width.c -
                  params.omics.start +
                  1 -
                  params.omics.start +
                  1
          )
          .attr("fill", "white")
          .attr("opacity", 0)
          .style(
            "cursor",
            _utils.zoom.func !== undefined ? "crosshair" : "default"
          )
          .attr(
            "transform",
            "translate(" + params.omics.start + "," + chart_height + ")"
          );

        if (_utils.zoom.func !== undefined) {
          gchart
            .select(".g_axes")
            .select("rect")
            .call(
              d3
                .drag()
                .container(this)
                .on("start", function (evt) {
                  if (_utils.cursor.job) {
                    _utils.cursor.job.abort();
                    _utils.cursor.job = null;
                  }

                  var track = this.parentNode.parentNode;

                  var track_cls = d3
                    .select(track)
                    .attr("class")
                    .replaceAll(" ", ".");

                  d3.selectAll("." + track_cls)
                    .append("rect")
                    .attr("opacity", 0.3)
                    .attr("class", "select select_region")
                    .style("pointer-events", "none")
                    .attr("sx", d3.pointer(evt, track)[0])
                    .attr("height", function () {
                      var ctrack = this.parentNode.parentNode;
                      return (
                        d3
                          .select(ctrack)
                          .select(".trackborder")
                          .attr("height") + "px"
                      );
                    });
                })
                .on("drag", function (evt) {
                  var track = this.parentNode.parentNode;
                  var track_cls = d3
                    .select(track)
                    .attr("class")
                    .replaceAll(" ", ".");

                  var x = Number(d3.select(".select_region").attr("sx"));

                  if (d3.pointer(evt, track)[0] < x) {
                    d3.selectAll(".select_region")
                      .attr("x", d3.pointer(evt, track)[0])
                      .attr("width", Math.abs(x - d3.pointer(evt, track)[0]));
                  } else {
                    d3.selectAll(".select_region")
                      .attr("x", x)
                      .attr("width", Math.abs(x - d3.pointer(evt, track)[0]));
                  }
                })
                .on("end", function (evt) {
                  var track = this.parentNode.parentNode;
                  var x1 =
                    Number(d3.select(".select_region").attr("x")) -
                    params.omics.start +
                    1;
                  var x2 =
                    x1 + Number(d3.select(".select_region").attr("width"));

                  if (x1 < 0) {
                    x1 = 0;
                  }

                  var spc,
                    hgchr1,
                    hgstart,
                    hgchr2,
                    hgend,
                    prevend = -1;
                  d3.select(track)
                    .selectAll(".g_chr")
                    .each(function (d) {
                      var tick_interval =
                        (d._vendpx - d._vstartpx + 1) /
                        (d._vend - d._vstart + 1);

                      if (prevend <= x1 && x1 <= d._vstartpx) {
                        hgchr1 = d.chr;
                        spc = d.spc;
                        hgstart = d.start;
                      }

                      if (d._vstartpx <= x1 && x1 <= d._vendpx) {
                        hgchr1 = d.chr;
                        spc = d.spc;
                        hgstart = Math.floor(
                          ((x1 - d._vstartpx) /
                            (d._vendpx - d._vstartpx + 1 - tick_interval)) *
                            (d.end - d.start) +
                            d.start
                        );
                      }

                      if (x2 >= d._vendpx) {
                        hgchr2 = d.chr;
                        hgend = d.end;
                      }

                      if (d._vstartpx <= x2 && x2 <= d._vendpx) {
                        hgchr2 = d.chr;
                        hgend = Math.floor(
                          ((x2 - d._vstartpx) /
                            (d._vendpx - d._vstartpx + 1 - tick_interval)) *
                            (d.end - d.start) +
                            d.start
                        );
                      }

                      prevend = d._vendpx;
                    });

                  hgchr1 = _data.vis.chrs.filter(function (chr) {
                    return chr.name == hgchr1 && chr.spc == spc;
                  })[0];

                  hgchr2 = _data.vis.chrs.filter(function (chr) {
                    return chr.name == hgchr2 && chr.spc == spc;
                  })[0];

                  if (
                    (hgchr1 != hgchr2 || hgstart != hgend) &&
                    hgstart !== undefined &&
                    hgend !== undefined &&
                    hgchr1._index <= hgchr2._index
                  ) {
                    if (hgchr1 == hgchr2 && hgstart > hgend) {
                      var tmp = hgstart;
                      hgstart = hgend;
                      hgend = tmp;
                    }

                    $("#alert_newcoord")
                      .attr("spc", spc)
                      .attr("chr1", hgchr1.name)
                      .attr("pos1", hgstart)
                      .attr("chr2", hgchr2.name)
                      .attr("pos2", hgend);

                    if (d3.select("#zoomin_checker").empty()) {
                      var region = [
                        spc,
                        hgchr1.name,
                        hgstart,
                        hgchr2.name,
                        hgend,
                      ];

                      _utils.Move_to(region);
                    } else {
                      $("#alert_newcoord").html(
                        spc +
                          "." +
                          hgchr1.name +
                          ":" +
                          hgstart +
                          " - " +
                          spc +
                          "." +
                          hgchr2.name +
                          ":" +
                          hgend
                      );

                      $("#zoomin_checker").modal("show");
                    }
                  }

                  d3.selectAll(".select_region").remove();
                })
            );
        }

        gchart.append("g").attr("class", "g_bases");

        gtrack.append("rect").attr("class", "trackborder").attr("fill", "none");
      }

      tr_canvas
        .select("#g" + tr._id)
        .attr("transform", "translate(0, " + tr_y + ")");

      tr_canvas
        .select("#g" + tr._id)
        .select(".trackname")
        .text(tr.name);

      var spcidx = _data.all.spcs.indexOf(tr.species);
      var coord_x =
        tr_canvas
          .select("#g" + tr._id)
          .select(".trackname")
          .node()
          .getComputedTextLength() + 5;

      if (_utils.zoom.func !== undefined) {
        var range = _utils.zoom.brush.range[spcidx];

        var coord =
          range[1].name == range[3].name
            ? " | " +
              range[1].name +
              ":" +
              range[2].toLocaleString() +
              "-" +
              range[4].toLocaleString()
            : " | " +
              range[1].name +
              ":" +
              range[2].toLocaleString() +
              " - " +
              range[3].name +
              ":" +
              range[4].toLocaleString();
      }

      tr_canvas
        .select("#g" + tr._id)
        .select(".trackcoord")
        .text(coord)
        .attr("x", coord_x);

      tr_canvas
        .select("#g" + tr._id)
        .select(".trackbg")
        .attr("width", tr.width + params.omics.border_width * 4)
        .attr("height", tr.height);

      tr_canvas
        .select("#g" + tr._id)
        .select(".trackborder")
        .attr("width", tr.width + params.omics.border_width * 4)
        .attr("height", tr.height)
        .attr("stroke", tr.border_color)
        .attr("stroke-width", params.omics.border_width);

      if (tr.resizable) {
        if (
          tr_canvas
            .select("#g" + tr._id)
            .select(".trackdraghandle")
            .empty()
        ) {
          var svg = d3.select("#" + params.canvas).select("svg");

          var handle = tr_canvas
            .select("#g" + tr._id)
            .append("g")
            .attr("class", "trackdraghandle")
            .style("cursor", "ns-resize")
            .call(
              d3
                .drag()
                .on("start", function (event) {
                  d3.select(".cursor").remove();
                  Remove_tooltip();

                  d3.select(this).attr("py", d3.pointer(event, svg)[1]);
                  d3.select(this).attr("ph", tr.height);
                })
                .on("drag", function (event) {
                  var start = Number(d3.select(this).attr("py"));
                  var height = Number(d3.select(this).attr("ph"));
                  var new_height = d3.pointer(event, svg)[1] - start + height;
                  if (new_height < params.omics.height) {
                    new_height = params.omics.height;
                  }
                  tr.height = new_height;
                  if (
                    "pin_types" in _data.vis &&
                    Object.keys(_data.vis["pin_types"]).length
                  ) {
                    tr.oheight =
                      tr.height -
                      (Object.keys(_data.vis["pin_types"]).length * 7 + 10);
                  } else {
                    tr.oheight = tr.height;
                  }

                  Make_tracks();
                  Update_svg();
                  Update_chart(tr);
                })
            );

          handle
            .append("rect")
            .attr("class", "handle")
            .attr("x", 10)
            .attr("height", 5)
            .attr("rx", 3.5)
            .attr("ry", 3.5)
            .attr("width", tr.width + params.omics.border_width * 4 - 20);

          handle
            .append("rect")
            .attr("class", "padding")
            .attr("x", 10)
            .attr("y", 5)
            .attr("height", 1)
            .attr("width", tr.width + params.omics.border_width * 4 - 20)
            .attr("fill", "white");
        }

        tr_canvas
          .select("#g" + tr._id)
          .select(".trackdraghandle")
          .attr("transform", "translate(0," + (tr.height - 7) + ")");
      } else {
        tr_canvas
          .select("#g" + tr._id)
          .select(".trackdraghandle")
          .remove();
      }

      var pos = tr_canvas
        .select("#g" + tr._id)
        .select(".trackborder")
        .node()
        .getScreenCTM();

      if (
        d3
          .select("#" + params.canvas)
          .select("#loading" + tr._id)
          .empty()
      ) {
        d3.select("#" + params.canvas)
          .append("div")
          .attr(
            "class",
            "hidden loading d-flex justify-content-center loading-track-" +
              _data.all.spcs.indexOf(tr.species)
          )
          .attr("id", "loading" + tr._id)
          .style("z-index", 999)
          .style("position", "absolute")
          .style("background", "rgba(0,0,0,0.1)")
          .style("pointer-events", "none")
          .append("div")
          .attr("class", "spinner-border")
          .style("margin-top", tr.height / 3 + "px")
          .append("span")
          .attr("class", "visually-hidden align-middle")
          .text("Loading...");
      }

      var width =
        params.layout == "linear"
          ? params.chr.width_fig.l
          : params.chr.width_fig.c;

      d3.select("#" + params.canvas)
        .select("#loading" + tr._id)
        .style("left", window.pageXOffset + pos.e + "px")
        .style("top", window.pageYOffset + pos.f + "px")
        .style("width", width + "px")
        .style("height", params.omics.height + "px");

      var plot_width = width - params.omics.start + 1;
      var plot_height = tr.oheight - 40;

      if (
        d3
          .select("#" + params.canvas)
          .select("#div_canvas_" + tr._id)
          .empty()
      ) {
        var dpr = window.devicePixelRatio;

        d3.select("#" + params.canvas)
          .append("div")
          .attr("id", "div_canvas_" + tr._id)
          .attr("class", "div_canvas")
          .style("position", "absolute");

        d3.select("#div_canvas_" + tr._id)
          .append("canvas")
          .attr("id", "plot_canvas_" + tr._id)
          .attr("class", "plot_canvas");

        d3.select("#" + params.canvas)
          .append("div")
          .attr("id", "div_mcanvas_" + tr._id)
          .attr("class", "div_canvas")
          .style("position", "absolute");

        d3.select("#div_mcanvas_" + tr._id)
          .append("canvas")
          .attr("id", "mark_canvas_" + tr._id)
          .attr("class", "g_marks-" + _data.all.spcs.indexOf(tr.species))
          .style("position", "absolute");
        // .style("top", "0px");

        var plot_canvas = $("#plot_canvas_" + tr._id)[0];
        plot_canvas.width = plot_width * dpr;
        plot_canvas.height = plot_height * dpr;
        plot_canvas.style.width = `${plot_width}px`;
        plot_canvas.style.height = `${plot_height}px`;

        var ctx = plot_canvas.getContext("2d");
        ctx.scale(dpr, dpr);

        var mark_canvas = $("#mark_canvas_" + tr._id)[0];
        var marks_height =
          "pin_types" in _data.vis
            ? Object.keys(_data.vis.pin_types).length * 5
            : 0;
        mark_canvas.width = plot_width * dpr;
        mark_canvas.height = marks_height;
        mark_canvas.style.width = `${plot_width}px`;
        mark_canvas.style.height = `${marks_height}px`;

        var mctx = mark_canvas.getContext("2d");
        mctx.scale(dpr, dpr);
      }

      d3.select("#" + params.canvas)
        .select("#div_canvas_" + tr._id)
        .style("left", window.pageXOffset + pos.e + params.omics.start + "px")
        .style("top", window.pageYOffset + pos.f + "px")
        .style("width", plot_width + 20 + "px")
        .style("height", plot_height + "px");

      d3.select("#" + params.canvas)
        .select("#div_mcanvas_" + tr._id)
        .style("left", window.pageXOffset + pos.e + params.omics.start + "px")
        .style("top", window.pageYOffset + pos.f + tr.oheight - 2 + "px")
        .style("width", plot_width + 20 + "px")
        .style("height", marks_height + "px");

      tr_y += tr.height + params.padding.track;
    });
    Update_svg();
  }

  function Mark_syntenies(sfs, chrs, params, target_spc = undefined) {
    var canvas = d3.select("#" + params.canvas).select("#g_tracks");
    var brushrate = -1;

    if (!canvas.select(".gtrack").empty()) {
      _data.all.spcs.forEach(function (spc, spcidx) {
        if (target_spc === undefined || spcidx == target_spc) {
          var spc_brush = d3.select(".gbrush_" + spcidx);
          var [margin_f, chr1, begin, chr2, end, margin_b] =
            _utils.zoom.brush.range[spcidx];
          var vislen = 0;
          var spc_sfs = [];

          if (chr1 !== undefined && chr2 !== undefined) {
            _data.vis.chrs
              .filter(function (chr) {
                return (
                  chr.spc == spc &&
                  chr1._index <= chr._index &&
                  chr._index <= chr2._index
                );
              })
              .forEach(function (chr) {
                vislen += chr._vend - chr._vstart + 1;
              });

            if (vislen) {
              vislen -= begin - 1 + (chr2._vend - end + 1);
              if (params.layout == "linear") {
                brushrate =
                  (params.omics.width.l - params.omics.start + 1) /
                  (vislen +
                    ((chr2._index - chr1._index) * params.chr.padding.l +
                      margin_f +
                      margin_b) /
                      params.chr.rate);
              } else {
                brushrate =
                  (params.omics.width.c - params.omics.start + 1) /
                  (vislen +
                    ((chr2._index - chr1._index) * params.chr.padding.l +
                      ((margin_f + margin_b) * params.chr.padding.l) /
                        (params.chr.padding.c * 1.5)) /
                      params.chr.rate);
              }
            }

            spc_sfs = sfs.filter(function (sf) {
              if (spc in sf.pos) {
                var spc_chr = chrs.filter(function (chr) {
                  return spc == chr.spc && chr.name == sf.pos[spc].chr;
                })[0];
                if (spc_chr === undefined) {
                }

                return (
                  (chr1._index < spc_chr._index &&
                    spc_chr._index < chr2._index) ||
                  (chr1._index == spc_chr._index &&
                    chr2._index != spc_chr._index &&
                    begin <= sf.pos[spc].end) ||
                  (chr1._index != spc_chr._index &&
                    chr2._index == spc_chr._index &&
                    end >= sf.pos[spc].start) ||
                  (chr1._index == spc_chr._index &&
                    chr2._index == spc_chr._index &&
                    begin < sf.pos[spc].end &&
                    end > sf.pos[spc].start)
                );
              }
            });
          }

          var spc_tracks = canvas.selectAll(".gchart-" + spcidx);

          var bkg_sf = spc_tracks
            .selectAll(".bkg_sfs")
            .attr("transform", "translate(" + params.omics.start + ", 0)")
            .selectAll(".bkg_sf")
            .data(spc_sfs);

          bkg_sf.exit().remove();

          bkg_sf
            .enter()
            .append("rect")
            .attr("class", "bkg_sf")
            .style("opacity", 0.2)
            .attr("fill", params.color_spc(spc))
            .attr("stroke", "black");

          spc_tracks
            .selectAll(".bkg_sf")
            .attr("class", function (d) {
              return "bkg_sf sf-" + d.id;
            })
            .attr("x", function (d) {
              var s_pos = {
                spc: spc,
                chr: d.pos[spc].chr,
                start: d.pos[spc].start,
                end: d.pos[spc].end,
              };
              Set_coordinate(s_pos, margin_f, chr1, begin, brushrate, params);
              //return (s_pos._vstartpx < 0) ? -1 * params.omics.padding : s_pos._vstartpx;
              return s_pos._vstartpx < 0 ? 0 : s_pos._vstartpx;
            })
            .attr("y", 0)
            .attr("width", function (d) {
              var s_pos = {
                spc: spc,
                chr: d.pos[spc].chr,
                start: d.pos[spc].start,
                end: d.pos[spc].end,
              };
              Set_coordinate(s_pos, margin_f, chr1, begin, brushrate, params);

              var figwidth =
                params.layout == "linear"
                  ? params.omics.width.l
                  : params.omics.width.c;
              //figwidth -= params.omics.start + params.omics.padding;
              figwidth -= params.omics.start;

              var xstart = s_pos._vstartpx < 0 ? 0 : s_pos._vstartpx;
              var xend = s_pos._vendpx;
              return xend - xstart;
            })
            .attr("height", function () {
              if (d3.select(this).attr("height")) {
                return d3.select(this).attr("height");
              }
            });
        }
      });
    }
  }

  function Draw_charts(spc = -1) {
    var params = _utils.params;

    params.tracks.forEach(function (tr) {
      if (tr.species === undefined) {
        console.error("FIX");
        return;
      }

      var spcname = tr.species;
      var spcidx = _data.all.spcs.indexOf(spcname);

      if (spcidx == -1) {
        console.error("FIX");
        return;
      }

      if (spc != -1 && tr.species != _data.all.spcs[spc]) {
        return;
      }

      Draw_plot(tr, tr.type);
      Draw_x_axis(tr._id);
    });
  }

  function Update_chart(track) {
    if (track._id in _data.vis) {
      Draw_plot(track, track.type);
      Draw_x_axis(track._id);
    } else {
      d3.select("#g" + track._id)
        .select(".g_chart")
        .selectAll("*")
        .remove();
    }
  }

  function Show_base(spc, range) {
    if (range.length < 5) {
      return false;
    }
    var basedata = [];

    var params = _utils.params;
    var spc = range[1].spc;
    var spcidx = _data.all.spcs.indexOf(spc);

    var maxcnt =
      params.layout == "linear"
        ? params.omics.width.l / 5
        : params.omics.width.c / 5;

    var vislen = 0;
    _data.vis.chrs
      .filter(function (chr) {
        return (
          chr.spc == spc &&
          range[1]._index <= chr._index &&
          chr._index <= range[3]._index
        );
      })
      .forEach(function (chr) {
        vislen += chr._vend - chr._vstart + 1;
      });
    vislen -= range[2] - 1 + range[3]._vend - range[4];

    if (vislen <= maxcnt) {
      var ranges = [];
      _data.vis.chrs
        .filter(function (chr) {
          return (
            chr.spc == spc &&
            range[1]._index <= chr._index &&
            chr._index <= range[3]._index
          );
        })
        .forEach(function (chr) {
          var nrange = chr.name + ":";
          if (chr._id == range[1]._id) {
            if (chr._id == range[3]._id) {
              nrange += range[2] + "-" + range[4];
            } else {
              nrange += range[2] + "-" + range[1]._vend;
            }
          } else if (chr._id == range[3]._id) {
            nrange += range[3]._vstart + "-" + range[4];
          } else {
            nrange += chr._vstart + "-" + chr._vend;
          }

          ranges.push(nrange);
        });

      var range_str = ranges.join(" ");

      $.ajax({
        url: _utils.phpscr_path + "/get_seq.php",
        type: "get",
        data: {
          project: prj,
          species: spc,
          position: range_str,
        },
      }).done(function (result) {
        var seqdata = JSON.parse(result);

        for (var pos in seqdata) {
          var seq = seqdata[pos].split("");

          var cols = pos.split(/:|-/);
          var chr = cols[0];
          var start = Number(cols[1]);
          var end = Number(cols[2]);

          for (var i = 0; i < end - start + 1; ++i) {
            var newdata = {
              spc: spc,
              chr: chr,
              pos: i + start,
              base: seq[i],
            };
            basedata.push(newdata);
          }
        }

        var brushrate = -1;
        var [margin_f, chr1, begin, chr2, end, margin_b] =
          _utils.zoom.brush.range[spcidx];

        if (vislen) {
          var trackwidth =
            params.layout == "linear"
              ? params.omics.width.l
              : params.omics.width.c;

          var tick_interval =
            (trackwidth -
              params.omics.start +
              1 -
              ((chr2._index - chr1._index) * params.chr.padding.l +
                margin_f +
                margin_b) /
                params.chr.rate +
              1) /
            vislen;

          if (params.layout == "linear") {
            brushrate =
              (params.omics.width.l - params.omics.start + 1) /
              (vislen +
                ((chr2._index - chr1._index) * params.chr.padding.l +
                  margin_f +
                  margin_b) /
                  params.chr.rate);
          } else {
            brushrate =
              (params.omics.width.c - params.omics.start + 1) /
              (vislen +
                ((chr2._index - chr1._index) * params.chr.padding.l +
                  ((margin_f + margin_b) * params.chr.padding.l) /
                    (params.chr.padding.c * 1.5)) /
                  params.chr.rate);
          }
        }

        basedata.forEach(function (d) {
          Set_coordinate(d, margin_f, chr1, begin, brushrate, _utils.params);
        });

        var basesg = d3
          .selectAll(".gtrack-" + spcidx)
          .select(".g_bases")
          .attr(
            "transform",
            "translate(" + (params.omics.start + tick_interval / 2 - 1) + ", 0)"
          );

        var bases = basesg.selectAll(".base").data(basedata);

        bases.exit().remove();

        bases
          .enter()
          .append("text")
          .attr("class", "base")
          .attr("alignment-baseline", "before-edge")
          .attr("text-anchor", "middle")
          .attr("font-size", "0.6rem");

        d3.selectAll(".gtrack-" + spcidx)
          .select(".g_bases")
          .selectAll(".base")
          .attr("x", (d) => d._vpospx)
          .text(function (d) {
            if (d._vpospx != params.omics.start) return d.base;
          });
      });
    } else {
      var bases = d3
        .selectAll(".gtrack-" + spcidx)
        .select(".g_bases")
        .selectAll(".base")
        .data(basedata);

      bases.exit().remove();
    }
  }
  function Update_cursor(evt, track) {
    var params = _utils.params;
    var trackinfo = params.tracks.filter(function (tr) {
      return tr._id == track;
    })[0];

    var spc = trackinfo.species;
    var spcidx = _data.all.spcs.indexOf(spc);
    var evtx = evt.offsetX;

    if (params.layout == "circular") {
      evtx -=
        params.chr.width_fig.c +
        params.omics.border_width -
        1 -
        params.omics.border_width * 4;
    }

    evtx = evtx < params.omics.start ? params.omics.start : evtx;
    var alnresol = 1;
    var vislen = 0;
    var [margin_f, chr1, begin, chr2, end, margin_b] =
      _utils.zoom.brush.range[spcidx];

    var vischr = _data.vis.chrs.filter(function (chr) {
      return (
        chr.spc == spc && chr1._index <= chr._index && chr._index <= chr2._index
      );
    });

    vischr.forEach(function (chr) {
      vislen += chr._vend - chr._vstart + 1;
    });

    if (vislen) {
      vislen -= begin - 1 + (chr2._vend - end + 1);
    } else {
      return;
    }

    var spclen = 0;
    _data.all.chrs
      .filter(function (chr) {
        return chr.spc == spc;
      })
      .forEach(function (chr) {
        spclen += chr.len;
      });

    var max_alnresol = Math.ceil(spclen / 10000 / 10000) * 10000;
    while (vislen / alnresol >= 10000 && max_alnresol != alnresol) {
      alnresol *= 10000 / 200;
      if (alnresol == 50) {
        // alnresol *= 10000 / 200;
      }
      if (alnresol > max_alnresol) {
        alnresol = max_alnresol;
      }
    }

    var cursorx, cursorinfo, tick_interval;
    d3.select("#g" + track)
      .selectAll(".g_chr")
      .filter(function (d) {
        cursorx = evtx - params.omics.start;
        return d._vstartpx <= cursorx && cursorx <= d._vendpx;
      })
      .each(function (d) {
        tick_interval =
          (d._vendpx - d._vstartpx + 1) / (d._vend - d._vstart + 1);
        cursorx = evtx - params.omics.start;

        var pos = Math.floor(
          ((cursorx - d._vstartpx) /
            (d._vendpx - d._vstartpx + 1 - tick_interval)) *
            (d.end - d.start) +
            d.start
        );

        var start = Math.floor(pos / alnresol) * alnresol + 1;
        var end = Math.ceil(pos / alnresol) * alnresol;
        if (start > end) {
          start = end;
        }

        cursorinfo = {
          spc: spc,
          chr: d.chr,
          start: start,
          end: end,
        };
      });

    if (vischr.length != 1) {
      tick_interval = 0;
    }

    if (params.layout == "linear") {
      var brushrate =
        (params.omics.width.l - params.omics.start + 1 - tick_interval) /
        (vislen +
          ((chr2._index - chr1._index) * params.chr.padding.l +
            margin_f +
            margin_b) /
            params.chr.rate);
    } else {
      var brushrate =
        (params.omics.width.c - params.omics.start + -tick_interval) /
        (vislen +
          ((chr2._index - chr1._index) * params.chr.padding.l +
            ((margin_f + margin_b) * params.chr.padding.l) /
              (params.chr.padding.c * 1.5)) /
            params.chr.rate);
    }

    var cursordata = [];
    if (cursorinfo !== undefined) {
      cursordata = [cursorinfo];
    }

    var matches = [];
    if (
      cursorinfo !== undefined &&
      "match" in _data.all &&
      spc in _data.all.match
    ) {
      matches = _data.all.match[spc][spc].filter(function (d) {
        return (
          d.chr == cursorinfo.chr &&
          Number(d.start) <= cursorinfo.end &&
          cursorinfo.start <= Number(d.end)
        );
      });
    }

    d3.selectAll(".cursor").remove();

    d3.selectAll(".gchart-" + spcidx).each(function () {
      var height = d3.select(this).select(".trackbg").attr("height");

      var cursor = d3
        .select(this)
        .selectAll(".cursor_" + spcidx)
        .data(cursordata);

      cursor.exit().remove();

      cursor
        .enter()
        .append("path")
        .attr("class", "cursor cursor_" + spcidx)
        .attr("stroke-width", 1.5)
        .attr("pointer-events", "none");

      d3.select(this)
        .selectAll(".cursor_" + spcidx)
        .style("stroke", matches.length ? "green" : "red")
        .attr("d", function (d) {
          Set_coordinate(d, margin_f, chr1, begin, brushrate, params);
          if (d._vstartpx < 0) {
            d._vstartpx = 0;
          }

          var x =
            (d._vstartpx + d._vendpx) / 2 +
            params.omics.start +
            tick_interval / 2;
          var y = height;

          return d3.line()([
            [x, 0],
            [x, height],
          ]);
        });
    });
    if (matches.length) {
      var matchid_info = {};
      matches.forEach(function (d) {
        matchid_info[d.sub_id] = d.id;
      });

      var ref_spc = _data.all.spcs[0];
      var ref_cursors = [];
      if (ref_spc != spc) {
        _data.all.match[spc][spc]
          .filter(function (d) {
            return (
              Object.values(matchid_info).indexOf(d.id) != -1 &&
              Object.keys(matchid_info).indexOf(d.sub_id) != -1
            );
          })
          .forEach(function (d) {
            var ref_match = _data.all.match[spc][ref_spc].filter(function (rd) {
              return d.sub_id == rd.sub_id;
            })[0];

            if (ref_match !== undefined) {
              var mv_s = cursorinfo.start - Number(d.start);
              var mv_e = cursorinfo.end - Number(d.start);

              var ref_cursor = $.extend({}, ref_match);
              ref_cursor.start =
                d.dir == ref_match.dir
                  ? Number(ref_match.start) + mv_s
                  : Number(ref_match.end) - mv_s;
              ref_cursor.end =
                d.dir == ref_match.dir
                  ? Number(ref_match.start) + mv_e
                  : Number(ref_match.end) - mv_e;

              ref_cursors.push(ref_cursor);
            }
          });

        var ref_matches = _data.all.match[spc][ref_spc].filter(function (d) {
          var overlap = 0;
          ref_cursors.forEach(function (r) {
            if (
              d.chr == r.chr &&
              Number(d.start) <= r.end &&
              r.start <= Number(d.end)
            ) {
              overlap = 1;
            }
          });
          return overlap;
        });

        ref_matches.forEach(function (d) {
          matchid_info[d.sub_id] = d.id;
        });
      } else {
        ref_cursors.push(cursorinfo);
      }

      _data.all.spcs.forEach(function (cspc, ci) {
        if (cspc != spc) {
          var cmatches = [];
          if (spc in _data.all.match && cspc in _data.all.match[spc]) {
            _data.all.match[spc][cspc]
              .filter(function (d) {
                return (
                  Object.values(matchid_info).indexOf(d.id) != -1 &&
                  Object.keys(matchid_info).indexOf(d.sub_id) != -1
                  //Object.keys(matchid_info).indexOf(d.id) != -1
                );
              })
              .forEach(function (d) {
                var ref_match = _data.all.match[spc][ref_spc].filter(function (
                  rd
                ) {
                  return d.sub_id == rd.sub_id;
                })[0];

                var mv = 0;
                ref_cursors.forEach(function (c) {
                  if (
                    ref_match.chr == c.chr &&
                    ref_match.start <= c.end &&
                    c.start <= ref_match.end
                  ) {
                    var mv_s = c.start - Number(ref_match.start);
                    var mv_e = c.end - Number(ref_match.start);

                    var c_cursor = $.extend({}, d);
                    c_cursor.start =
                      d.dir == ref_match.dir
                        ? Number(d.start) + mv_s
                        : Number(d.end) - mv_s;
                    c_cursor.end =
                      d.dir == ref_match.dir
                        ? Number(d.start) + mv_e
                        : Number(d.end) - mv_e;

                    cmatches.push(c_cursor);
                  }
                });
              });
          }

          if (cmatches !== undefined && cmatches.length != 0) {
            var vislen = 0;
            var brushrate = -1;

            var [margin_f, chr1, begin, chr2, end, margin_b] =
              _utils.zoom.brush.range[ci];

            _data.vis.chrs
              .filter(function (chr) {
                return (
                  chr.spc == cspc &&
                  chr1._index <= chr._index &&
                  chr._index <= chr2._index
                );
              })
              .forEach(function (chr) {
                vislen += chr._vend - chr._vstart + 1;
              });

            if (vislen) {
              vislen -= begin - 1 + (chr2._vend - end + 1);

              if (params.layout == "linear") {
                brushrate =
                  (params.omics.width.l - params.omics.start + 1) /
                  (vislen +
                    ((chr2._index - chr1._index) * params.chr.padding.l +
                      margin_f +
                      margin_b) /
                      params.chr.rate);
              } else {
                brushrate =
                  (params.omics.width.c - params.omics.start + 1) /
                  (vislen +
                    ((chr2._index - chr1._index) * params.chr.padding.l +
                      ((margin_f + margin_b) * params.chr.padding.l) /
                        (params.chr.padding.c * 1.5)) /
                      params.chr.rate);
              }
            }

            var cmatchinfo = $.extend(true, [], cmatches);
            cmatchinfo = cmatchinfo.filter(function (d) {
              d["spc"] = cspc;
              Set_coordinate(d, margin_f, chr1, begin, brushrate, params);
              return d._vendpx > 0;
            });

            d3.selectAll(".gchart-" + ci).each(function () {
              var height = d3.select(this).select(".trackbg").attr("height");

              var ccursor = d3
                .select(this)
                .selectAll(".cursor_" + ci)
                .data(cmatchinfo);

              ccursor.exit().remove();
              ccursor
                .enter()
                .append("path")
                .attr("class", "cursor cursor_" + ci)
                .attr("stroke-width", 1.5)
                .attr("pointer-events", "none");

              d3.select(this)
                .selectAll(".cursor_" + ci)
                .style("stroke", "green")
                .attr("d", function (d) {
                  Set_coordinate(d, margin_f, chr1, begin, brushrate, params);

                  if (d._vstartpx < 0) {
                    d._vstartpx = 0;
                  }

                  var x =
                    (d._vstartpx + d._vendpx) / 2 +
                    params.omics.start +
                    tick_interval / 2;
                  var y = height;

                  return d3.line()([
                    [x, 0],
                    [x, height],
                  ]);
                });
            });
          } else {
            d3.selectAll(".cursor_" + ci).remove();
          }
        }
      });
    }

  }

  function Draw_plot(track, type = "point") {

    var params = _utils.params;
    var chart_width = track.width;
    var chart_height = track.oheight - 40;

    var spcidx = _data.all.spcs.indexOf(track.species);

    var brushrate = -1;
    var vislen = 0;
    var [margin_f, chr1, begin, chr2, end, margin_b] =
      _utils.zoom.brush.range[spcidx];

    var canvas = d3.select("#g" + track._id).select(".g_chart");

    var dpr = window.devicePixelRatio;
    var plot_width = chart_width - params.omics.start + 1;

    var plot_canvas = $("#plot_canvas_" + track._id)[0];
    plot_canvas.width = plot_width * dpr;
    plot_canvas.height = chart_height * dpr;
    plot_canvas.style.width = `${plot_width}px`;
    plot_canvas.style.height = `${chart_height}px`;

    var ctx = d3
      .select("#plot_canvas_" + track._id)
      .node()
      .getContext("2d");

    ctx.scale(dpr, dpr);
    ctx.clearRect(0, 0, chart_width, track.height);

    d3.select("#div_canvas_" + track._id).style("overflow", "visible");
    d3.select("#plot_canvas_" + track._id)
      .style("position", "relative")
      .style("top", "0px");

    if (_utils.zoom.brush.range[spcidx].length == 6) {
      _data.vis.chrs
        .filter(function (chr) {
          return (
            chr.spc == track.species &&
            chr1._index <= chr._index &&
            chr._index <= chr2._index
          );
        })
        .forEach(function (chr) {
          vislen += chr._vend - chr._vstart + 1;
        });
      vislen -= begin - 1 + chr2._vend - end;

      var trackwidth =
        params.layout == "linear" ? params.omics.width.l : params.omics.width.c;

      var tick_interval =
        (trackwidth -
          params.omics.start +
          1 -
          ((chr2._index - chr1._index) * params.chr.padding.l +
            margin_f +
            margin_b) /
            params.chr.rate +
          1) /
        vislen;

      if (params.layout == "linear") {
        brushrate =
          (params.omics.width.l - params.omics.start + 1) /
          (vislen +
            ((chr2._index - chr1._index) * params.chr.padding.l +
              margin_f +
              margin_b) /
              params.chr.rate);
      } else {
        brushrate =
          (params.omics.width.c - params.omics.start + 1) /
          (vislen +
            ((chr2._index - chr1._index) * params.chr.padding.l +
              ((margin_f + margin_b) * params.chr.padding.l) /
                (params.chr.padding.c * 1.5)) /
              params.chr.rate);
      }

      canvas.attr(
        "transform",
        "translate(" + (params.omics.start + tick_interval / 2 - 1) + ", 0)"
      );

      if (track._id in _data.vis) {
        _data.vis[track._id] = _data.vis[track._id]
          .filter(function (d) {
            var chr = _data.vis.chrs.filter(function (ch) {
              return (
                ch.spc == track.species &&
                ch.name.toLowerCase() == d.chr.toLowerCase()
              );
            })[0];

            return (
              chr !== undefined &&
              chr._index >= chr1._index &&
              chr._index <= chr2._index
            );
          })
          .sort((a, b) => {
            if (
              a.chr > b.chr ||
              (a.chr == b.chr && Number(a.start) > Number(b.start))
            )
              return 1;
            if (
              a.chr < b.chr ||
              (a.chr == b.chr && Number(a.start) < Number(b.start))
            )
              return -1;
          });

        var x = function (d) {
          d.spc = track.species;
          Set_coordinate(d, margin_f, chr1, begin, brushrate, params);

          var pos;
          if ("_vstartpx" in d) {
            pos = (d._vstartpx + d._vendpx) / 2;
          } else if ("_vpospx" in d) {
            pos = d._vpospx;
          }

          return pos;
        };

        var visdata = _data.vis[track._id].filter(function (d) {
          var chr = _data.vis.chrs.filter(function (ch) {
            return (
              ch.spc == track.species &&
              ch.name.toLowerCase() == d.chr.toLowerCase()
            );
          })[0];

          if ("pos" in d) {
            d.pos = Number(d.pos);

            return (
              (chr !== undefined &&
                chr._index > chr1._index &&
                chr._index < chr2._index) ||
              (chr1._index == chr2._index && end >= d.pos && begin <= d.pos) ||
              (chr1._index != chr2._index &&
                chr._index == chr1._index &&
                begin <= d.pos) ||
              (chr1._index != chr2._index &&
                chr._index == chr2._index &&
                end >= d.pos)
            );
          } else {
            return (
              (chr !== undefined &&
                chr._index > chr1._index &&
                chr._index < chr2._index) ||
              (chr1._index == chr2._index &&
                end >= d.start &&
                begin <= d.end) ||
              (chr1._index != chr2._index &&
                chr._index == chr1._index &&
                begin <= d.end) ||
              (chr1._index != chr2._index &&
                chr._index == chr2._index &&
                end >= d.start)
            );
          }
        });

        var min =
          track.range[0] == "auto"
            ? d3.min(visdata, (d) => Number(d.value))
            : track.range[0];
        var max =
          track.range[1] == "auto"
            ? d3.max(visdata, (d) => Number(d.value))
            : track.range[1];

        if (track.range[0] == "auto" && min > 0) {
          min = 0;
        }
        if (track.range[1] == "auto" && max < 0) {
          max = 0;
        }

        if (min === undefined && max == undefined) {
          min = 0;
          max = 0;
        }

        var scale = d3
          .scaleLinear()
          .range([chart_height, 15])
          .domain([min, max]);
        if (track.range[0] == "auto" && track.range[1] == "auto") {
          scale.nice();
        }
        track._range = scale.domain();

        function y(value) {
          if (value > max) {
            value = max;
          }
          if (value < min) {
            value = min;
          }
          return scale(value);
        }

        switch (type) {
          case "point":
            _data.vis[track._id].forEach(function (d) {
              var dot_radius = 2;

              d.spc = track.species;
              d._y = y(Number(d.value));
              Set_coordinate(d, margin_f, chr1, begin, brushrate, params);
              ctx.fillStyle = track.fill;

              ctx.beginPath();
              ctx.arc(x(d), d._y, dot_radius, 0, 2 * Math.PI);
              ctx.fill();
            });
            break;
          case "bar":
          case "rect":
            var rect_height = 10;

            if (_data.vis[track._id].length && type == "rect") {
              /*
              var grs = $.unique(
                _data.vis[track._id].map((d) => d.color).sort()
              );

              rect_height = (track.oheight - 40 - 30) / grs.length;
              */
              var dys = {};
              _data.vis[track._id].forEach(function (d) {
                d.spc = track.species;
                Set_coordinate(d, margin_f, chr1, begin, brushrate, params);

                var dy = 1;
                while (
                  dy in dys &&
                  dys[dy][0] == d.chr &&
                  dys[dy][1] >= Number(d.start)
                ) {
                  dy++;
                }
                dys[dy] = [d.chr, Number(d.end)];
                d._dy = dy;
              });

              var rect_track_cnt = Object.keys(dys).sort((a, b) => b - a)[0];
              if (!rect_track_cnt) {
                rect_track_cnt = 0;
              } else {
                rect_height = (track.oheight - 40 - 30) / rect_track_cnt;
              }

            }

            _data.vis[track._id].forEach(function (d) {
              if (type != "rect") {
                d.spc = track.species;
                Set_coordinate(d, margin_f, chr1, begin, brushrate, params);
              }

              var dx = d._vstartpx;
              d._y = type == "rect" ? 20 : y(Number(d.value));
              var dy = d._y;

              var width = d._vendpx - d._vstartpx + 1;
              var height = chart_height - d._y;

              if (type == "rect") {
                ctx.fillStyle = d.color;

                height = rect_height;
                dy = 15 + rect_height * d._dy - rect_height;
              } else {
                ctx.fillStyle = track.fill;
              }
              ctx.fillRect(dx, dy, width, height);
            });
            break;
          case "area":
          case "line":
            var chrdata = Array.from(
              d3.group(_data.vis[track._id], (d) => d.chr),
              ([chr, data]) => ({
                chr,
                data,
              })
            );

            chrdata.forEach(function (ds) {
              ctx.beginPath();
              ds.data.forEach(function (d, i) {
                d._y = y(Number(d.value));
                if (i) {
                  ctx.lineTo(x(d), d._y);
                } else {
                  if (type == "area") {
                    ctx.moveTo(x(d), chart_height);
                    ctx.lineTo(x(d), d._y);
                  } else {
                    ctx.moveTo(x(d), d._y);
                  }
                }
              });
              if (type == "area") {
                ctx.lineTo(x(ds.data[ds.data.length - 1]), chart_height);
              }

              ctx.strokeStyle = track.stroke_color;
              ctx.lineWidth = track.stroke_width;

              ctx.stroke();
              if (type == "area") {
                ctx.fillStyle = track.fill;
                ctx.fill();
              }
            });
            break;
          case "interact-ribbon":
          case "interact-line":
            var canvas = d3.select("#g" + track._id).select(".gchart");
            canvas.select(".legend").remove();

            if (!_data.vis[track._id].length) {
              return false;
            }

            var interact_data = Array.from(
              d3.group(_data.vis[track._id], (d) => d.id),
              ([id, data]) => ({
                id,
                data,
              })
            ).filter(function (d) {
              var range = track._range;
              if (range[0] != "auto") {
                if (range[1] != "auto") {
                  return (
                    parseFloat(d.data[0].value) >= range[0] &&
                    parseFloat(d.data[0].value) <= range[1] &&
                    d.data.length != 1
                  );
                } else {
                  return (
                    parseFloat(d.data[0].value) >= range[0] &&
                    d.data.length != 1
                  );
                }
              } else {
                if (range[1] != "auto") {
                  return (
                    parseFloat(d.data[0].value) <= range[1] &&
                    d.data.length != 1
                  );
                } else {
                  return d.data.length != 1;
                }
              }
            });

            var distmin = d3.min(interact_data, (d) =>
              Math.abs(
                (Number(d.data[1].start) + Number(d.data[1].end)) / 2 -
                  (Number(d.data[0].start) + Number(d.data[0].end)) / 2
              )
            );
            var distmax = d3.max(interact_data, (d) =>
              Math.abs(
                (Number(d.data[1].start) + Number(d.data[1].end)) / 2 -
                  (Number(d.data[0].start) + Number(d.data[0].end)) / 2
              )
            );


            var dist_scale = d3
              .scaleLinear()
              .domain([distmin + 1, distmax + 1])
              .range([chart_height / 3, -20]);

            var value_scale = d3
              .scaleLinear()
              .domain([
                d3.min(interact_data, (d) => Number(d.data[0].value)),
                d3.max(interact_data, (d) => Number(d.data[0].value)),
              ])
              .nice()
              .range([1, 3]);

            interact_data.forEach(function (d) {
              d.data[0].spc = track.species;
              d.data[1].spc = track.species;

              Set_coordinate(
                d.data[0],
                margin_f,
                chr1,
                begin,
                brushrate,
                params
              );
              Set_coordinate(
                d.data[1],
                margin_f,
                chr1,
                begin,
                brushrate,
                params
              );

              var arc_height = dist_scale(
                Math.abs(
                  (Number(d.data[1].start) + Number(d.data[1].end)) / 2 -
                    (Number(d.data[0].start) + Number(d.data[0].end)) / 2
                ) + 1
              );
              d.data[0].arc_h = arc_height;
              d.data[1].arc_h = arc_height;

              if (type == "interact-line") {
                ctx.fillStyle = params.color_spc(track.species);
                ctx.fillRect(
                  d.data[0]._vstartpx,
                  chart_height - 10,
                  d.data[0]._vendpx - d.data[0]._vstartpx + 1,
                  10
                );
                ctx.fillRect(
                  d.data[1]._vstartpx,
                  chart_height - 10,
                  d.data[1]._vendpx - d.data[1]._vstartpx + 1,
                  10
                );

                ctx.lineWidth = value_scale(Number(d.data[0].value));
                d.data[0].arc_w = ctx.lineWidth;
                d.data[1].arc_w = ctx.lineWidth;

                ctx.globalAlpha = 0.5;
                ctx.strokeStyle = track.stroke_color;
                ctx.lineWidth = track.stroke_width;
                var src_mid = (d.data[0]._vstartpx + d.data[0]._vendpx) / 2;
                var tar_mid = (d.data[1]._vstartpx + d.data[1]._vendpx) / 2;

                ctx.beginPath();
                ctx.moveTo(src_mid, chart_height - 10);
                ctx.quadraticCurveTo(
                  (src_mid + tar_mid) / 2,
                  arc_height,
                  tar_mid,
                  chart_height - 10
                );
                ctx.stroke();
                ctx.globalAlpha = 1;
              } else {
                ctx.globalAlpha = 0.5;
                ctx.fillStyle = track.fill;
                var src_mid = (d.data[0]._vstartpx + d.data[0]._vendpx) / 2;
                var tar_mid = (d.data[1]._vstartpx + d.data[1]._vendpx) / 2;

                ctx.beginPath();
                ctx.moveTo(d.data[0]._vstartpx, chart_height);
                ctx.lineTo(d.data[0]._vendpx, chart_height);
                ctx.quadraticCurveTo(
                  (src_mid + tar_mid) / 2,
                  arc_height,
                  d.data[1]._vstartpx,
                  chart_height
                );
                ctx.lineTo(d.data[1]._vendpx, chart_height);
                ctx.quadraticCurveTo(
                  (src_mid + tar_mid) / 2,
                  arc_height - 3,
                  d.data[0]._vstartpx,
                  chart_height
                );
                ctx.fill();
                ctx.globalAlpha = 1;
              }
            });
            break;
          case "heatmap":
            var binchrs = _data.vis.chrs.filter(function (ch) {
              return (
                ch.spc == track.species &&
                chr1._index <= ch._index &&
                ch._index <= chr2._index
              );
            });

            if (_data.vis[track._id].length) {
              var interact_data = Array.from(
                d3.group(_data.vis[track._id], (d) => d.id),
                ([id, data]) => ({
                  id,
                  data,
                })
              ).filter(function (d) {
                return d.data.length != 1;
              });

              var binsize =
                _data.vis[track._id][0].end - _data.vis[track._id][0].start + 1;

              var score_scale = d3
                .scaleLinear()
                .domain([min, max])
                .nice();

              var color = d3.scaleSequential(
                score_scale.domain(),
                //d3.interpolateReds
                d3.interpolateRgb("white", params.color_spc(track.species))
              ).clamp(true);

              var heatmap_col = [];
              for (
                var i = color.domain()[0];
                i <= color.domain()[1];
                i += (color.domain()[1] - color.domain()[0]) / 5
              ) {
                heatmap_col.push(color(i));
              }

              var canvas = d3.select("#g" + track._id).select(".gchart");

              canvas.select(".legend").remove();
              var label_canvas = canvas.append("g").attr("class", "legend");

              var grad = label_canvas
                .append("defs")
                .append("linearGradient")
                .attr("id", "grad" + track._id)
                .attr("x1", "0%")
                .attr("y1", "0%")
                .attr("x2", "100%")
                .attr("y2", "0%");

              grad
                .selectAll("stop")
                .data(heatmap_col)
                .enter()
                .append("stop")
                .style("stop-color", function (d) {
                  return d;
                })
                .attr("offset", function (d, i) {
                  return i / (heatmap_col.length - 1);
                });

              label_canvas
                .append("text")
                .attr("class", "color_s")
                .text(min)
                .attr("x", -999999)
                .attr("y", -10)
                .attr("font-size", "0.785rem")
                .attr("text-anchor", "end")
                .attr("alignment-baseline", "central");

              label_canvas
                .append("text")
                .attr("class", "color_e")
                .text(max)
                .attr("x", -999999)
                .attr("y", -10)
                .attr("font-size", "0.785rem")
                .attr("alignment-baseline", "central");

              label_canvas
                .append("rect")
                .attr("class", "color_rect")
                .attr("x", -999999)
                .attr("y", -15)
                .attr("width", 75)
                .attr("height", 10)
                .style("fill", "url('#grad" + track._id + "')");

              var txtlen = label_canvas
                .select(".color_e")
                .node()
                .getComputedTextLength();

              label_canvas
                .select(".color_s")
                .attr("x", trackwidth - txtlen - 80 - 5);
              label_canvas.select(".color_e").attr("x", trackwidth - txtlen);
              label_canvas
                .select(".color_rect")
                .attr("x", trackwidth - txtlen - 80);
            }

            d3.select("#div_canvas_" + track._id).style(
              "overflow",
              "hidden scroll"
            );

            d3.select("#div_canvas_" + track._id + "::-webkit-scrollbar").style(
              "-webkit-appearance",
              "none"
            );

            d3.select("#plot_canvas_" + track._id)
              .style("position", "relative")
              .style("top", "4px");

            var maxy = 0;
            var startbin = {
              chr: chr1.name,
              spc: track.species,
              start: Math.floor(begin / binsize) * binsize + 1,
              end: (Math.floor(begin / binsize) + 1) * binsize,
            };

            var endbin = {
              chr: chr2.name,
              spc: track.species,
              start: Math.floor(end / binsize) * binsize + 1,
              end: Math.floor(end / binsize) * binsize + 1,
            };

            Set_coordinate(startbin, margin_f, chr1, begin, brushrate, params);
            Set_coordinate(endbin, margin_f, chr1, begin, brushrate, params);

            var chr_height = (endbin._vendpx - startbin._vstartpx + 1) / 2;
            if (maxy < chr_height) {
              maxy = chr_height;
            }

            if (maxy + 40 + 20 > track.oheight) {
              var chart_height = maxy + 20;

              var dpr = window.devicePixelRatio;
              var plot_width = trackwidth - params.omics.start + 1;
              var plot_canvas = $("#plot_canvas_" + track._id)[0];
              plot_canvas.width = plot_width * dpr;
              plot_canvas.height = chart_height * dpr;
              plot_canvas.style.width = `${plot_width}px`;
              plot_canvas.style.height = `${chart_height}px`;

              var ctx = plot_canvas.getContext("2d");
              ctx.scale(dpr, dpr);
            }

            if (interact_data) {
              interact_data.forEach(function (d) {
                if (!("spc" in d.data[0])) {
                  d.data[0].spc = track.species;
                }

                Set_coordinate(
                  d.data[0],
                  margin_f,
                  chr1,
                  begin,
                  brushrate,
                  params
                );

                if (
                  d.data[0].chr == d.data[1].chr &&
                  parseInt(d.data[0].start) == parseInt(d.data[1].start) &&
                  parseInt(d.data[0].end) == parseInt(d.data[1].end)
                ) {
                  ctx.fillStyle = color(parseFloat(d.data[0].value));
                  ctx.strokeStyle = color(parseFloat(d.data[0].value));
                  ctx.beginPath();
                  ctx.moveTo(d.data[0]._vstartpx, chart_height);
                  ctx.lineTo(
                    (d.data[0]._vstartpx + d.data[0]._vendpx) / 2,
                    chart_height -
                      (d.data[0]._vendpx - d.data[0]._vstartpx + 1) / 2
                  );
                  ctx.lineTo(d.data[0]._vendpx, chart_height);
                  ctx.fill();
                  ctx.stroke();
                } else {
                  if (
                    d.data[0].chr > d.data[1].chr ||
                    (d.data[0].chr == d.data[1].chr &&
                      d.data[0].start > d.data[1].start)
                  ) {
                    var tmp = d.data[0];
                    d.data[0] = d.data[1];
                    d.data[1] = tmp;
                  }

                  if (!("spc" in d.data[1])) {
                    d.data[1].spc = track.species;
                  }

                  Set_coordinate(
                    d.data[1],
                    margin_f,
                    chr1,
                    begin,
                    brushrate,
                    params
                  );

                  var x1 = (d.data[0]._vstartpx + d.data[1]._vstartpx) / 2;
                  var x2 = (d.data[0]._vstartpx + d.data[1]._vendpx) / 2;
                  var x3 = (d.data[0]._vendpx + d.data[1]._vendpx) / 2;
                  var x4 = (d.data[0]._vendpx + d.data[1]._vstartpx) / 2;

                  if (
                    parseInt(d.data[0].start) < 40000000 &&
                    parseInt(d.data[1].start) > 100000000
                  ) {
                  }

                  var y1 =
                    chart_height -
                    (d.data[1]._vstartpx - d.data[0]._vstartpx + 1) / 2;
                  var y2 =
                    chart_height -
                    (d.data[1]._vendpx - d.data[0]._vstartpx + 1) / 2;
                  var y3 =
                    chart_height -
                    (d.data[1]._vendpx - d.data[0]._vendpx + 1) / 2;
                  var y4 =
                    chart_height -
                    (d.data[1]._vstartpx - d.data[0]._vendpx + 1) / 2;

                  ctx.fillStyle = color(parseFloat(d.data[0].value));
                  ctx.strokeStyle = color(parseFloat(d.data[0].value));
                  ctx.beginPath();
                  ctx.moveTo(x1, y1);
                  ctx.lineTo(x2, y2);
                  ctx.lineTo(x3, y3);
                  ctx.lineTo(x4, y4);

                  ctx.fill();
                  ctx.stroke();
                }
              });

              $("#div_canvas_" + track._id)
                .clearQueue()
                .stop()
                .animate({scrollTop: "0px"}, 0)
                .animate({scrollTop: chart_height + "px"}, 3000);
            }

            break;
          case "gene":
            var gene_height = 10;
            var label_height = 15;

            var dys = {};
            _data.vis[track._id].forEach(function (d) {
              d.spc = track.species;
              Set_coordinate(d, margin_f, chr1, begin, brushrate, params);

              var dy = 1;
              while (
                dy in dys &&
                dys[dy][0] == d.chr &&
                dys[dy][1] + 1 >= Number(d._vstartpx)
              ) {
                dy++;
              }
              dys[dy] = [d.chr, d._vendpx];

              d._dy = dy;
            });

            var gene_track_cnt = Object.keys(dys).sort((a, b) => b - a)[0];
            if (!gene_track_cnt) {
              gene_track_cnt = 0;
            } else {
              gene_height = (track.oheight - 40 - 30) / (2.5 * gene_track_cnt);
              label_height = 15 < 1.5 * gene_height ? 15 : 1.5 * gene_height;
            }

            _data.vis[track._id].forEach(function (d) {
              var dy = 15 + (gene_height + label_height) * d._dy - gene_height;
              d._ystartpx = dy;
              d._yendpx = d._ystartpx + gene_height;

              if (d._vstartpx < 0) {
                d._vstartpx = 0;
              }

              var plot_width = chart_width - params.omics.start + 1;
              if (d._vendpx > plot_width) {
                d._vendpx = plot_width;
              }

              var width = d._vendpx - d._vstartpx + 1;
              var txt_width = ctx.measureText(d.id).width;

              if (width > txt_width && label_height >= 12) {
                var fontArgs = ctx.font.split(" ");
                ctx.font =
                  label_height - 3 + "px" + " " + fontArgs[fontArgs.length - 1];

                ctx.textAlign = "center";
                ctx.fillStyle = track.fill;

                ctx.fillText(d.id, d._vstartpx + width / 2, dy - 3);
              }

              if (
                (vislen > 1000000 && track.downsample != "na") ||
                !("exon" in d) ||
                d.exon.length == 0
              ) {
                d.showExon = false;
                ctx.fillStyle = track.fill;
                ctx.fillRect(d._vstartpx, dy, width, gene_height);
              } else {
                d.showExon = true;

                var introns = [];
                if (d._vstartpx < 0) {
                  introns.push(0);
                } else {
                  introns.push(d._vstartpx);
                }

                d.exon.forEach(function (de) {
                  de.spc = track.species;
                  de.chr = d.chr;
                  Set_coordinate(de, margin_f, chr1, begin, brushrate, params);

                  ctx.fillStyle = track.fill;
                  ctx.fillRect(
                    de._vstartpx,
                    dy,
                    de._vendpx - de._vstartpx + 1,
                    gene_height
                  );
                });

                if (d._vendpx < plot_width) {
                  introns.push(d._vendpx);
                } else {
                  introns.push(plot_width);
                }

                ctx.strokeStyle = track.stroke_color;
                ctx.lineWidth = track.stroke_width;

                ctx.beginPath();
                ctx.moveTo(d._vstartpx, dy + gene_height / 2);
                ctx.lineTo(d._vendpx, dy + gene_height / 2);
                ctx.stroke();

                for (var i = 1; i < introns.length; i += 2) {
                  if (introns[i] - introns[i - 1] > 15) {
                    for (
                      var arrow_start = 4 + introns[i - 1];
                      arrow_start <= introns[i] - 10;
                      arrow_start += 15
                    ) {
                      if (d.direction == "+") {
                        Draw_arrow(
                          ctx,
                          arrow_start,
                          dy + gene_height / 2,
                          arrow_start + 10,
                          dy + gene_height / 2,
                          track.stroke_color,
                          0.4
                        );
                      } else {
                        Draw_arrow(
                          ctx,
                          arrow_start + 10,
                          dy + gene_height / 2,
                          arrow_start,
                          dy + gene_height / 2,
                          track.stroke_color,
                          0.4
                        );
                      }
                    }
                  }
                }
              }
            });

            break;
        }
      }
    } else {
      canvas.selectAll("*").remove();
    }

    if (
      type != "gene" &&
      type != "rect" &&
      type != "heatmap" &&
      type.indexOf("interact") == -1
    ) {
      Draw_y_axis(track, scale);
    }

    Update_svg();
    Make_tracks();

    setTimeout(function () {
      $("#loading" + track._id).addClass("hidden");
    }, 1000);
  }

  //* Process data *//
  function Preprocess_chrData(data, spcs, params, coords) {
    // circular track 그릴때 필요해서 항상 모두 계산하도록 함.

    d3.select("#g_opts").selectAll("*").remove();

    var padangle =
      params.layout == "linear" ? params.chr.padding.l : params.chr.padding.c;
    var rate = 1;

    var spcname_maxlen = 0;
    d3.selectAll(".spcname").each(function (d) {
      if (spcname_maxlen < this.getComputedTextLength()) {
        spcname_maxlen = this.getComputedTextLength();
      }
    });
    spcname_maxlen += 8;

    params.chr.name_maxlen = spcname_maxlen;

    if (_data.all.chrs.length != data.length) {
      var return_mark_tab_l = params.padding.return.l;
      var return_mark_tab_c = params.padding.return.c;

      if (params.layout == "linear") {
        spcs.forEach(function (spc, i) {
          d3.select("#g_opts")
            .append("rect")
            .attr("fill", "white")
            .attr("width", return_mark_tab_l)
            .attr("height", params.chr.width)
            .attr("x", spcname_maxlen - return_mark_tab_l)
            .attr("y", Set_species_ypos(i, spcs.length, params));

          for (var doti = 0; doti < 3; ++doti) {
            d3.select("#g_opts")
              .append("circle")
              .attr("class", "reset_dot")
              .attr("r", 1.2)
              .style("fill", "black")
              .attr("cx", function (d) {
                return (
                  spcname_maxlen +
                  3.7 +
                  ((return_mark_tab_l - 5) / 3) * doti -
                  return_mark_tab_l +
                  2
                );
              })
              .attr(
                "cy",
                Set_species_ypos(i, spcs.length, params) + params.chr.width / 2
              );
          }
        });
      } else {
        var reset_pie = d3
          .pie()
          .value(function (d) {
            return d;
          })
          .startAngle(2 * Math.PI - params.chr.end)
          .endAngle(2 * Math.PI)
          .sort(null)
          .padAngle(0.01);

        var donut_reset = reset_pie([1, 1, 1]);

        d3.select("#g_opts")
          .append("path")
          .attr(
            "d",
            Draw_arc(
              params.chr.r - 20 - params.chr.width,
              params.chr.r - 10,
              2 * Math.PI - params.chr.end + 0.01,
              2 * Math.PI - 0.01
            )
          )
          .attr("fill", "white");

        d3.select("#g_opts")
          .selectAll(".reset_dot")
          .data(donut_reset)
          .enter()
          .append("circle")
          .attr("class", "reset_dot")
          .attr("r", 1.2)
          .style("fill", "black")
          .attr("cx", function (d) {
            return (
              ((params.chr.r - 20 - params.chr.width + params.chr.r - 10) / 2) *
              Math.sin((d.startAngle + d.endAngle) / 2)
            );
          })
          .attr("cy", function (d) {
            return (
              -1 *
              ((params.chr.r - 20 - params.chr.width + params.chr.r - 10) / 2) *
              Math.cos((d.startAngle + d.endAngle) / 2)
            );
          });
      }
    }

    spcs.forEach(function (spc) {
      var total_size = 0;
      var spc_chr_data = data.filter(function (d) {
        if (d.spc == spc) {
          if (coords !== undefined) {
            var coord = coords
              .filter(function (co) {
                var pos = co[1].split(/:|-/);
                return co[0] == spc && pos[0] == d.name;
              })
              .map((d) => d[1]);

            if (coord.length) {
              var pos = coord[0].split(/:|-/);
              d._vstart = parseInt(pos[1]);
              d._vend = parseInt(pos[2]);
            }
          } else {
            d._vstart = 1;
            d._vend = d.len;
          }
          total_size += d._vend - d._vstart + 1;
        }
        return d.spc == spc;
      });

      spc_chr_data
        .sort(function (a, b) {
          return d3.ascending(a._id, b._id);
        })
        .forEach(function (d, i) {
          d._index = i;
        });

      if (
        rate >
        (params.width -
          params.chr.start -
          params.chr.name_maxlen -
          (spc_chr_data.length - 1) * padangle) /
          total_size
      ) {
        rate =
          (params.width -
            params.chr.start -
            params.chr.name_maxlen -
            (spc_chr_data.length - 1) * padangle) /
          total_size;
      }

      params.chr.rate = rate;
    });
    //}

    //if (params.layout == "linear") {
    spcs.forEach(function (spc, i) {
      var offset = 0;
      data
        .filter(function (d) {
          return d.spc == spc;
        })
        .forEach(function (d, j) {
          d._tflen = (d._vend - d._vstart + 1) * rate;
          d._x = params.chr.name_maxlen + offset;
          d._y = Set_species_ypos(i, spcs.length, params);

          if (!("_index" in d)) {
            d._index = j;
          }
          offset += d._tflen;
        });
    });
    //} else {
    var pie = d3
      .pie()
      .value(function (d) {
        return d[1]._vend - d[1]._vstart + 1;
      })
      .startAngle(0)
      .endAngle(2 * Math.PI - params.chr.end)
      .sort(null)
      .padAngle(padangle);

    var donut_data = pie(Object.entries(data));
    for (var i = 0; i < donut_data.length; ++i) {
      data[i].startAngle = donut_data[i].startAngle + padangle * 0.75;
      data[i].endAngle = donut_data[i].endAngle - padangle * 0.75;

      if (data[i].startAngle > data[i].endAngle) {
        data[i].startAngle = donut_data[i].startAngle + padangle * 0.5;
        data[i].endAngle = donut_data[i].endAngle - padangle * 0.5;
      }
    }
    //}
  }

  function Filter_sfdata(poss) {
    var filter_sfs = [];
    poss.forEach(function (pos, i) {
      var [spc, coord] = pos;
      var [chr, start, end] = coord.split(/:|-/);
      spc = _data.all.spcs[spc];

      var alldata = i ? _data.vis.sfs : _data.all.merge_sfs;

      filter_sfs = alldata.filter(function (sf) {
        if (spc in sf.pos) {
          return sf.pos[spc].chr.toLowerCase() == chr.toLowerCase();
        }
      });
    });

    if (filter_sfs.length == 0) {
      return false;
    }

    _data.vis.sfs = filter_sfs;
    var ids = _data.vis.sfs.map((d) => d.id);

    _data.vis.sfs = _data.all.merge_sfs.filter(function (sf) {
      return ids.indexOf(sf.id) != -1;
    });

    var all_chrs = $.extend(true, [], _data.all.chrs);
    _data.vis.chrs = all_chrs.filter(function (chr) {
      var can_show = _data.vis.sfs.filter(function (sf) {
        return chr.spc in sf.pos && sf.pos[chr.spc].chr == chr.name;
      });
      return can_show.length;
    });

  }

  //* User interface *//
  function Set_zoom() {
    var params = _utils.params;
    var track_start = params.chr.start;
    var k = 1;

    if (params.layout == "linear") {
      track_start += params.chr.name_maxlen;
    }

    var svg = d3.select("#" + params.canvas).select("svg");

    if (svg.select(".g_brushs").empty()) {
      svg.append("g").attr("class", "g_brushs");
    }

    var gbrushs = svg.select(".g_brushs");

    d3.select(document.body).on("wheel.body", (e) => {});

    svg.on("wheel", (event) => event.preventDefault());

    _utils.zoom.func = d3
      .zoom()
      .on("start", function (event) {
        Remove_tooltip();

        if (
          !$("#" + this.parentNode.id.replace("g", "loading")).hasClass(
            "hidden"
          )
        ) {
          _utils.zoom.ing = false;
          return false;
        }

        _utils.zoom.ing = true;
        d3.select(this)
          .transition()
          .duration(0)
          .call(_utils.zoom.func.transform, d3.zoomIdentity);
        if (d3.select(this).attr("k") === null) {
          d3.select(this).attr("k", 1);
        }
      })
      .on("zoom", Update_brush)
      .on("end", Update_brush);

    function Update_brush(fn) {
      if (!_utils.zoom.ing) {
        return;
      }

      if (fn.type == "end") {
        _utils.zoom.ing = false;
      } else {
        _utils.zoom.ing = true;
      }

      const reg = new RegExp(/gchart-[0-9]+/);
      var spcidx = Number(
        d3.select(this).attr("class").match(reg)[0].replace("gchart-", "")
      );
      var tf = d3.zoomTransform(d3.select(this).node());

      var range = [],
        newrange = [];

      var chrstart = -1;
      var chrend = -1;
      var k = Number(d3.select(this).attr("k"));

      if (tf.k != 1) {
        var [margin_f, chr1, begin, chr2, end, margin_b] =
          _utils.zoom.brush.range[spcidx];

        if (chr1 == chr2 && end - begin + 1 < 5 && tf.k < 1) {
          return;
        }

        if (
          d3
            .select(".gbrush_" + spcidx)
            .select(".circularbrush")
            .empty()
        ) {
          range = d3.brushSelection(d3.select(".gbrush_" + spcidx).node());

          var focus =
            range[0] +
            (d3.pointer(fn.sourceEvent)[0] / params.omics.width.l) *
              (range[1] - range[0]);
          chrstart = params.chr.start + params.chr.name_maxlen;

          var chrs = _data.vis.chrs.filter(function (chr) {
            return chr.spc == _data.all.spcs[spcidx];
          });
          var lastchr = chrs[chrs.length - 1];
          var maxrange =
            lastchr._x + lastchr._index * params.chr.padding.l + lastchr._tflen;

          chrend = maxrange;

          newrange = [
            Math.max(focus - ((focus - range[0]) * tf.k) / k, chrstart),
            Math.min(focus - ((focus - range[1]) * tf.k) / k, chrend),
          ];

          d3.select(".gbrush_" + spcidx).call(
            _utils.zoom.brush.func[spcidx].move,
            newrange
          );
        } else {
          d3.select(".gbrush_" + spcidx)
            .select("path.circularbrush.extent")
            .each(function (d) {
              range[0] = d.startAngle;
              range[1] = d.endAngle;
            });

          var focus =
            range[0] +
            (d3.pointer(fn.sourceEvent)[0] / params.omics.width.c) *
              (range[1] - range[0]);
          chrstart = -1;
          chrend = -1;

          _data.vis.chrs
            .filter(function (chr) {
              return chr.spc == _data.all.spcs[spcidx];
            })
            .forEach(function (chr) {
              if (chrstart == -1 || chr.startAngle < chrstart)
                chrstart = chr.startAngle;
              if (chr.endAngle > chrend) chrend = chr.endAngle;
            });

          newrange = [
            Math.max(focus - ((focus - range[0]) * tf.k) / k, chrstart),
            Math.min(focus - ((focus - range[1]) * tf.k) / k, chrend),
          ];

          d3.select(".gbrush_" + spcidx).call(
            _utils.zoom.brush.func[spcidx].move(
              newrange,
              d3.select(".gbrush_" + spcidx)
            )
          );
        }
      } else {
        var trackwidth =
          params.layout == "linear"
            ? params.omics.width.l
            : params.omics.width.c;

        trackwidth -= params.omics.border_width * 4;

        if (
          d3
            .select(".gbrush_" + spcidx)
            .select(".circularbrush")
            .empty()
        ) {
          var brush_window_rate =
            Number(
              d3
                .select(".gbrush_" + spcidx)
                .select(".selection")
                .attr("width")
            ) / trackwidth;
          tf.x *= brush_window_rate / 5;

          range = d3.brushSelection(d3.select(".gbrush_" + spcidx).node());

          var chrs = _data.vis.chrs.filter(function (chr) {
            return chr.spc == _data.all.spcs[spcidx];
          });
          var lastchr = chrs[chrs.length - 1];
          var maxrange =
            lastchr._x + lastchr._index * params.chr.padding.l + lastchr._tflen;

          var newrange = [range[0] - tf.x, range[1] - tf.x];
          if (newrange[0] < params.chr.start + params.chr.name_maxlen) {
            newrange = [
              params.chr.start + params.chr.name_maxlen,
              params.chr.start + params.chr.name_maxlen + range[1] - range[0],
            ];
          } else if (newrange[1] > maxrange) {
            newrange = [maxrange - (range[1] - range[0]), maxrange];
          }

          d3.select(".gbrush_" + spcidx).call(
            _utils.zoom.brush.func[spcidx].move,
            newrange
          );
        } else {
          d3.select(".gbrush_" + spcidx)
            .select("path.circularbrush.extent")
            .each(function (d) {
              range[0] = d.startAngle;
              range[1] = d.endAngle;
            });

          var brush_window_rate = (range[1] - range[0]) / trackwidth;
          tf.x *= brush_window_rate / 5;

          _data.vis.chrs
            .filter(function (chr) {
              return chr.spc == _data.all.spcs[spcidx];
            })
            .forEach(function (chr) {
              if (chrstart == -1 || chr.startAngle < chrstart)
                chrstart = chr.startAngle;
              if (chr.endAngle > chrend) chrend = chr.endAngle;
            });

          newrange = [range[0] - tf.x, range[1] - tf.x];
          if (newrange[0] < chrstart) {
            newrange = [chrstart, chrstart + range[1] - range[0]];
          } else if (newrange[1] > chrend) {
            newrange = [chrend - (range[1] - range[0]), chrend];
          }

          d3.select(".gbrush_" + spcidx).call(
            _utils.zoom.brush.func[spcidx].move(
              newrange,
              d3.select(".gbrush_" + spcidx)
            )
          );
        }
      }

      d3.select(this).attr("k", tf.k);
    }

    _data.all.spcs.forEach(function (spc, i) {
      var spc_y = Set_species_ypos(i, _data.all.spcs.length, params);

      gbrushs.select(".gbrush_" + i).remove();
      gbrushs.append("g").attr("class", "gbrush gbrush_" + i);

      var chrs = _data.vis.chrs
        .filter(function (chr) {
          return chr.spc == spc;
        })
        .sort(function (a, b) {
          return d3.ascending(a._index, b._index);
        });

      var firstchr = chrs[0];
      var lastchr = chrs[chrs.length - 1];

      if (_utils.zoom.brush.range[i] !== undefined) {
        var vis_firstchr = chrs.filter(function (chr) {
          return chr._id == _utils.zoom.brush.range[i][1]._id;
        })[0];
        var vis_endchr = chrs.filter(function (chr) {
          return chr._id == _utils.zoom.brush.range[i][1]._id;
        })[0];

        if (vis_firstchr === undefined && vis_endchr === undefined) {
          _utils.zoom.brush.range[i] = undefined;
        } else if (vis_firstchr === undefined) {
          _utils.zoom.brush.range[i][1] = _utils.zoom.brush.visendchr;
          _utils.zoom.brush.range[i][2] = 1;
        } else if (vis_endchr === undefined) {
          _utils.zoom.brush.range[i][3] = _utils.zoom.brush.vis_firstchr;
          _utils.zoom.brush.range[i][4] = _utils.zoom.brush.range[i][3].len;
        }
      }

      if (_utils.params.layout == "linear") {
        _utils.zoom.brush.func[i] = d3
          .brushX()
          .extent([
            [track_start, spc_y - 3],
            [
              params.chr.start +
                lastchr._x +
                lastchr._index * params.chr.padding.l +
                lastchr._tflen,
              spc_y + params.chr.width + 6,
            ],
          ])
          .on("start", function () {
            _utils.zoom.brush.ing = true;
          })
          .on("brush", Update_visdata)
          .on("end", Update_alldata);

        d3.select(".gbrush_" + i).call(_utils.zoom.brush.func[i]);

        var brush = _utils.zoom.brush.func[i];
        if (_utils.zoom.brush.range[i] !== undefined) {
          var setrange = _utils.zoom.brush.range[i];

          setrange[1] = _data.vis.chrs.filter(function (chr) {
            return chr._id == setrange[1]._id;
          })[0];

          setrange[3] = _data.vis.chrs.filter(function (chr) {
            return chr._id == setrange[3]._id;
          })[0];

          var start =
            params.chr.start +
            setrange[1]._x +
            setrange[2] * params.chr.rate +
            (setrange[1]._index - firstchr._index) * params.chr.padding.l;
          var end =
            params.chr.start +
            setrange[3]._x +
            setrange[4] * params.chr.rate +
            (setrange[3]._index - firstchr._index) * params.chr.padding.l;

          if (params.prelayout == "circular") {
            setrange[0] *= params.chr.padding.l / (params.chr.padding.c * 1.5);
            setrange[5] *= params.chr.padding.l / (params.chr.padding.c * 1.5);
          }

          d3.select(".gbrush_" + i).call(brush.move, [
            start - setrange[0],
            end + setrange[5],
          ]);
        } else {
          d3.select(".gbrush_" + i).call(brush.move, [
            track_start,
            track_start + firstchr._tflen,
          ]);
        }
      } else {
        var range = [chrs[0].startAngle, chrs[0].endAngle];
        if (_utils.zoom.brush.range[i] !== undefined) {
          var setrange = _utils.zoom.brush.range[i];

          setrange[1] = _data.vis.chrs.filter(function (chr) {
            return chr._id == setrange[1]._id;
          })[0];

          setrange[3] = _data.vis.chrs.filter(function (chr) {
            return chr._id == setrange[3]._id;
          })[0];

          var start =
            setrange[1].startAngle +
            setrange[2] *
              ((setrange[1].endAngle - setrange[1].startAngle) /
                setrange[1].len);
          var end =
            setrange[3].startAngle +
            setrange[4] *
              ((setrange[3].endAngle - setrange[3].startAngle) /
                setrange[3].len);

          if (params.prelayout == "linear") {
            setrange[0] *= (params.chr.padding.c * 1.5) / params.chr.padding.l;
            setrange[5] *= (params.chr.padding.c * 1.5) / params.chr.padding.l;
          }

          range = [start - setrange[0], end + setrange[5]];
        }

        _utils.zoom.brush.func[i] = d3.svg
          .circularbrush()
          .innerRadius(params.chr.r - 20 - params.chr.width)
          .outerRadius(params.chr.r - 10)
          .handleSize(params.chr.padding.c)
          .extent([i, chrs[0].startAngle, chrs[chrs.length - 1].endAngle])
          .on("brush", Update_visdata)
          .on("end", Update_alldata);

        d3.select(".gbrush_" + i).call(_utils.zoom.brush.func[i]);

        d3.select(".gbrush_" + i).call(
          _utils.zoom.brush.func[i].move(range, d3.select(".gbrush_" + i))
        );

        if (_utils.zoom.brush.range[i] !== undefined) {
          Show_base(spc, _utils.zoom.brush.range[i]);
        }
      }

      gbrushs.select(".gbrush_" + i).attr("transform", function () {
        if (_utils.params.layout == "linear") {
          var pinlayers = 0;
          if ("pin_types" in _data.vis) {
            pinlayers = Object.keys(_data.vis.pin_types).length;
          }
          return "translate(1," + (1 + pinlayers * 9) + ")";
        } else {
          return d3.select("#g_chrs").attr("transform");
        }
      });

      gbrushs
        .select(".gbrush_" + i)
        .select(".overlay")
        .attr("pointer-events", "none");
    });
  }

  function Update_visdata({selection}) {
    var range = Get_brushedregion(this, selection);
    var spc = parseInt(
      d3.select(this).attr("class").replace("gbrush gbrush_", "")
    );
    _utils.zoom.brush.range[spc] = range;

    Draw_charts(spc);
    Mark_syntenies(_data.vis.sfs, _data.vis.chrs, _utils.params, spc);

    d3.selectAll(".gtrack-" + spc).each(function (tr) {
      var coord =
        range.length == 2
          ? "|"
          : range[1].name == range[3].name
          ? " | " +
            range[1].name +
            ":" +
            range[2].toLocaleString() +
            "-" +
            range[4].toLocaleString()
          : " | " +
            range[1].name +
            ":" +
            range[2].toLocaleString() +
            " - " +
            range[3].name +
            ":" +
            range[4].toLocaleString();
      d3.select(this).select(".trackcoord").text(coord);
    });

    if (
      !d3.select(this).select(".selection").empty() &&
      d3.select(this).select(".selection").attr("width") < 1
    ) {
      d3.select(this).select(".selection").attr("stroke", "black");

      if (
        !d3.select(this).select(".selection").empty() &&
        d3.select(this).select(".selection").attr("width") < 0.00001
      ) {
        d3.select(this).select(".selection").attr("width", 0.00001);
      }
    } else {
      d3.select(this).select(".selection").attr("stroke", "white");
    }

    if (!d3.select(this).select(".circularbrush.extent").empty()) {
      d3.select(this)
        .select(".circularbrush.extent")
        .each(function (d) {
          if (d.endAngle - d.startAngle < 0.003) {
            d3.select(this).style("stroke", "black");
          } else {
            d3.select(this).style("stroke", "white");
          }
        });
    }

    _utils.params.tracks
      .filter(function (tr) {
        return tr.species == _data.all.spcs[spc];
      })
      .forEach(function (tr) {
        if (tr._id in _data.all) {
          Update_chart(tr);
        }
      });
  }

  function Update_alldata(event) {
    _utils.zoom.brush.ing = false;
    var th = this;

    setTimeout(function () {
      if (!_utils.zoom.ing) {
        const reg = new RegExp(/gbrush_[0-9]+/);
        var spcidx = Number(
          d3.select(th).attr("class").match(reg)[0].replace("gbrush_", "")
        );

        d3.selectAll(".gchart-" + spcidx).on(".zoom", "");
        $(".loading-track-" + spcidx).removeClass("hidden");

        setTimeout(function () {
          var selection = event.selection;
          if (!selection || !(selection[1] - selection[0])) {
            if (_utils.params.layout == "linear") {
              var start =
                _utils.params.chr.start + _utils.params.chr.name_maxlen;

              if (d3.pointer(event)[0] > _utils.params.chr.width_fig.l) {
                selection = [
                  _utils.params.chr.width_fig.l - 0.000001,
                  _utils.params.chr.width_fig.l,
                ];
              } else {
                selection = [start, start + 0.000001];
              }

              d3.select(th).call(
                _utils.zoom.brush.func[spcidx].move,
                selection
              );
            } else {
              var startAngle = _data.vis.chrs
                .filter(function (chr) {
                  return chr.spc == _data.all.spcs[spcidx];
                })
                .sort(function (a, b) {
                  return d3.ascending(a._index, b._index);
                })[0].startAngle;

              if (selection[0] == startAngle) {
                selection[1] += 0.000000001;
              } else {
                selection[0] -= 0.000000001;
              }

              d3.select(th).call(
                _utils.zoom.brush.func[spcidx].move(selection, d3.select(th))
              );
            }
          }

          //var range = Get_brushedregion(th, selection);
          //_utils.zoom.brush.range[spcidx] = range;
          var range = _utils.zoom.brush.range[spcidx];
          Show_base(spcidx, range);

          if (_utils.params.tracks.length) {
            Update_trackcontent(_data.all.spcs[spcidx]);
          }

          var spc = _data.all.spcs[spcidx];
          for (var type in _data.vis.highlight) {
            _data.vis.highlight[type] = _data.vis.highlight[type].filter(
              function (d) {
                return d.spc != spc;
              }
            );
          }

          for (var type in _data.all.highlight) {
            var fltdata = _data.all.highlight[type].filter(function (d) {
              var curchr = _data.vis.chrs.filter(function (c) {
                return c.spc == d.spc && c.name == d.chr;
              })[0];

              return (
                curchr &&
                range[1]._index <= curchr._index &&
                curchr._index <= range[3]._index &&
                ((range[1]._index == curchr._index &&
                  range[3]._index == curchr._index &&
                  d.start <= range[4] &&
                  range[2] <= d.end) ||
                  (range[1]._index == curchr._index &&
                    range[3]._index != curchr._index &&
                    range[2] <= d.end) ||
                  (range[1]._index != curchr._index &&
                    range[3]._index == curchr._index &&
                    d.start <= range[4]) ||
                  (range[1]._index < curchr._index &&
                    curchr._index < range[3]._index))
              );
            });

            var new_dat = $.extend(true, [], fltdata);
            _data.vis.highlight[type] = $.merge(
              _data.vis.highlight[type],
              new_dat
            );
          }

          setTimeout(function () {
            d3.selectAll(".gchart-" + spcidx).call(_utils.zoom.func);
          }, 100);
        }, 100);
      }
    }, 100);
  }

  function Get_brushedregion(brush, selection) {
    var layout = _utils.params.layout;
    var spc = parseInt(
      d3.select(brush).attr("class").replace("gbrush gbrush_", "")
    );
    var spcname = _data.all.spcs[spc];

    var spcname_maxlen = layout == "linear" ? _utils.params.chr.name_maxlen : 0;

    if (selection !== null) {
      var vischr = _data.vis.chrs
        .filter(function (chr) {
          return chr.spc == spcname;
        })
        .filter(function (chr) {
          var start =
            layout == "linear"
              ? chr._x +
                _utils.params.chr.padding.l * chr._index +
                _utils.params.chr.start
              : chr.startAngle;
          var end =
            layout == "linear"
              ? start + (chr._vend - chr._vstart + 1) * _utils.params.chr.rate
              : chr.endAngle;

          return start <= selection[1] && end >= selection[0];
        })
        .sort(function (a, b) {
          return d3.ascending(a._index, b._index);
        });

      if (vischr.length) {
        var stroke_width = layout == "linear" ? 1 : 0;
        var chrstart =
          layout == "linear"
            ? vischr[0]._x +
              _utils.params.chr.padding.l * vischr[0]._index +
              _utils.params.chr.start
            : vischr[0].startAngle;
        var chrstart_last =
          layout == "linear"
            ? vischr[vischr.length - 1]._x +
              _utils.params.chr.padding.l * vischr[vischr.length - 1]._index +
              _utils.params.chr.start
            : vischr[vischr.length - 1].startAngle;
        var chrend =
          layout == "linear"
            ? chrstart_last +
              (vischr[vischr.length - 1]._vend -
                vischr[vischr.length - 1]._vstart +
                1) *
                _utils.params.chr.rate
            : vischr[vischr.length - 1].endAngle;

        var margin_f =
          chrstart - selection[0] - stroke_width < 0
            ? 0
            : chrstart - selection[0] - stroke_width;
        var margin_b =
          selection[1] - chrend - stroke_width < 0
            ? 0
            : selection[1] - chrend - stroke_width;
        var brushstart =
          chrstart - selection[0] < 0
            ? layout == "linear"
              ? Math.round((selection[0] - chrstart) / _utils.params.chr.rate)
              : Math.round(
                  ((selection[0] - chrstart) /
                    (vischr[0].endAngle - vischr[0].startAngle)) *
                    (vischr[0]._vend - vischr[0]._vstart)
                )
            : 1;
        brushstart += vischr[0]._vstart - 1;

        var brushend =
          selection[1] - chrend < 0
            ? layout == "linear"
              ? Math.round(
                  (selection[1] - chrstart_last) / _utils.params.chr.rate
                )
              : Math.round(
                  ((selection[1] - chrstart_last) /
                    (vischr[vischr.length - 1].endAngle -
                      vischr[vischr.length - 1].startAngle)) *
                    (vischr[vischr.length - 1]._vend -
                      vischr[vischr.length - 1]._vstart)
                )
            : vischr[vischr.length - 1]._vend -
              vischr[vischr.length - 1]._vstart +
              1;
        brushend += vischr[vischr.length - 1]._vstart - 1;

        if (
          vischr[0] == vischr[vischr.length - 1] &&
          brushend - brushstart + 1 < 5
        ) {
          if (selection[1] == _utils.params.chr.width_fig.l) {
            brushstart = brushend - 4;
          } else if (brushstart == 0) {
            brushend = brushstart + 4;
          } else {
            var center = parseInt((brushstart + brushend) / 2);
            brushstart = center - 2;
            brushend = vischr[0].len < center + 2 ? vischr[0].len : center + 2;
          }
        }

        return [
          margin_f,
          vischr[0],
          brushstart,
          vischr[vischr.length - 1],
          brushend,
          margin_b,
        ];
      }
    }
    return selection;
  }

  function Show_tooltip(x, y, content, id, direction = "top") {
    var tail_size = 6;

    d3.select("body")
      .append("div")
      .attr("class", "tooltip_me tooltip_me_body")
      .attr("id", "tooltip" + id + "-body")
      .style("padding", ".5rem 1rem .5rem 1rem")
      .style("z-index", 9999)
      .style("pointer-events", "none")
      .style("position", "absolute")
      .style("border-radius", "5px")
      .style("background-color", "black")
      .style("color", "white")
      .style("font-size", "0.785rem");

    d3.select("#tooltip" + id + "-body").html(content);

    var tooltip_width = $("#tooltip" + id + "-body").outerWidth();
    var tooltip_height = $("#tooltip" + id + "-body").outerHeight();

    if (direction == "top") {
      d3.select("#tooltip" + id + "-body")
        .style("left", x - tooltip_width / 2 + 2 + "px")
        .style("top", y - tooltip_height - tail_size + "px");

      d3.select("body")
        .append("div")
        .attr("class", "tooltip_me tooltip_me_tail")
        .attr("id", "tooltip" + id + "-tail")
        .style("z-index", 9999)
        .style("pointer-events", "none")
        .style("position", "absolute")
        .style("width", "0px")
        .style("height", "0px")
        .style("border-width", tail_size + "px")
        .style("border-style", "solid")
        .style("border-color", "black transparent transparent transparent")
        .style("font-size", 0)
        .style("line-height", 0);

      d3.select("#tooltip" + id + "-tail")
        .style("left", x - tail_size * 2 - 1 + "px")
        .style("top", y - tail_size + "px");
    } else {
      d3.select("#tooltip" + id + "-body")
        .style("left", x + tail_size * 2 - 1 + "px")
        .style("top", y - tooltip_height / 2 + "px");

      d3.select("body")
        .append("div")
        .attr("class", "tooltip_me tooltip_me_tail")
        .attr("id", "tooltip" + id + "-tail")
        .style("z-index", 9999)
        .style("pointer-events", "none")
        .style("position", "absolute")
        .style("width", "0px")
        .style("height", "0px")
        .style("border-width", tail_size + "px")
        .style("border-style", "solid")
        .style("border-color", "transparent black transparent transparent ")
        .style("font-size", 0)
        .style("line-height", 0);

      d3.select("#tooltip" + id + "-tail")
        .style("left", x - tail_size / 2 + 2 + "px")
        .style("top", y - tail_size + "px");
    }
  }

  function Remove_tooltip() {
    d3.selectAll(".tooltip_me").remove();
    d3.selectAll(".tooltip_ele").remove();
  }

  function cancelableClick() {
    // we want to a distinguish single/double click
    // details http://bl.ocks.org/couchand/6394506
    var dispatcher = d3.dispatch("click", "dblclick");

    function cc(selection) {
      var down,
        tolerance = 5,
        last,
        wait = null,
        args;
      // euclidean distance
      function dist(a, b) {
        return Math.sqrt(Math.pow(a[0] - b[0], 2), Math.pow(a[1] - b[1], 2));
      }
      selection.on("mousedown", function () {
        down = d3.pointer(document.body);
        last = +new Date();
        args = arguments;
      });
      selection.on("mouseup", function () {
        if (dist(down, d3.pointer(document.body)) > tolerance) {
          return;
        } else {
          if (wait) {
            window.clearTimeout(wait);
            wait = null;
            dispatcher.apply("dblclick", this, args);
          } else {
            wait = window.setTimeout(
              (function () {
                return function () {
                  dispatcher.apply("click", this, args);
                  wait = null;
                };
              })(),
              300
            );
          }
        }
      });
    }
    // Copies a variable number of methods from source to target.
    var d3rebind = function (target, source) {
      var i = 1,
        n = arguments.length,
        method;
      while (++i < n)
        target[(method = arguments[i])] = d3_rebind(
          target,
          source,
          source[method]
        );
      return target;
    };

    // Method is assumed to be a standard D3 getter-setter:
    // If passed with no arguments, gets the value.
    // If passed with arguments, sets the value and returns the target.
    function d3_rebind(target, source, method) {
      return function () {
        var value = method.apply(source, arguments);
        return value === source ? target : value;
      };
    }
    return d3rebind(cc, dispatcher, "on");
  }
})();

// Original code: https://gist.github.com/emeeks/5850fa6583bfd90e7899 //
// Updated by daehong //
d3.svg.circularbrush = function () {
  var _listeners = d3.dispatch("start", "brush", "end");
  var _extent = [];
  var _pre = 0;
  var _change = 0;
  var _range = [0, Math.PI * 2];
  var _arc = d3.arc().innerRadius(50).outerRadius(100);
  var _brushData = [
    {
      startAngle: _range[0],
      endAngle: _range[1],
      class: "extent",
    },
    {
      startAngle: _range[0] - 0.2,
      endAngle: _range[0],
      class: "resize e",
    },
    {
      startAngle: _range[1],
      endAngle: _range[1] + 0.2,
      class: "resize w",
    },
  ];

  var _newBrushData = [];
  //var d3_window = _brushG;
  var _origin;
  var _brushG;
  var _handleSize = 0.2;
  var _scale = d3.scaleLinear().domain(_range).range(_range);
  var _tolerance = 0.00001;

  function _circularbrush(_container) {
    updateBrushData();

    if (_container.select(".circularbrush").empty()) {
      _brushG = _container.append("g").attr("class", "circularbrush");
    }

    _brushG
      .selectAll("path.circularbrush")
      .data(_brushData)
      .enter()
      .insert("path", "path.resize")
      .attr("d", _arc)
      .attr("class", function (d) {
        if (d.class == "extent") {
          return d.class + " circularbrush";
        } else {
          return d.class + " circularbrush";
        }
      })
      .call(
        d3
          .drag()
          .on("start", brushstart)
          .on("drag", resizeDown)
          .on("end", brushend)
      )
      .style("fill-opacity", function (d) {
        if (d.class == "extent") return 0.3;
        return 0;
      })
      .style("stroke", function (d) {
        if (d.class == "extent") return "white";
        return "none";
      })
      .style("cursor", function (d) {
        if (d.class.indexOf("resize") != -1) {
          return "ew-resize";
        }
        return "move";
      });

    return _circularbrush;
  }

  _circularbrush.extent = function (_value) {
    _extent[_value[0]] = _value;
    _brushData[0].spc = _value[0];
    _brushData[1].spc = _value[0];
    _brushData[2].spc = _value[0];

    return this;
  };

  _circularbrush.move = function (_value, th) {
    _range = [_value[0], _value[1]];
    updateBrushData();

    if (_brushG !== undefined) {
      _newBrushData = _brushData;
      brushRefresh(th.node());
    }

    return this;
  };

  _circularbrush.on = function () {
    var _value = _listeners.on.apply(_listeners, arguments);
    return _value === _listeners ? _circularbrush : _value;
  };

  _circularbrush.handleSize = function (_value) {
    if (!arguments.length) return _handleSize;

    _handleSize = _value;
    _brushData = [
      {
        startAngle: _range[0],
        endAngle: _range[1],
        class: "extent",
      },
      {
        startAngle: _range[0] - _handleSize,
        endAngle: _range[0],
        class: "resize e",
      },
      {
        startAngle: _range[1],
        endAngle: _range[1] + _handleSize,
        class: "resize w",
      },
    ];
    return this;
  };

  _circularbrush.innerRadius = function (_value) {
    if (!arguments.length) return _arc.innerRadius();

    _arc.innerRadius(_value);
    return this;
  };

  _circularbrush.outerRadius = function (_value) {
    if (!arguments.length) return _arc.outerRadius();

    _arc.outerRadius(_value);
    return this;
  };

  _circularbrush.range = function (_value) {
    if (!arguments.length) return _scale.range();

    _scale.range(_value);
    return this;
  };

  _circularbrush.arc = function (_value) {
    if (!arguments.length) return _arc;

    _arc = _value;
    return this;
  };

  _circularbrush.tolerance = function (_value) {
    if (!arguments.length) return _tolerance;

    _tolerance = _value;
    return this;
  };

  _circularbrush.filter = function (_array, _accessor) {
    var data = _array.map(_accessor);

    var extent = _circularbrush.extent();
    var start = extent[0];
    var end = extent[1];
    var firstPoint = _scale.range()[0];
    var lastPoint = _scale.range()[1];
    var filteredArray = [];
    var firstHalf = [];
    var secondHalf = [];

    if (Math.abs(start - end) < _tolerance) {
      return _array;
    }

    if (start < end) {
      filteredArray = _array.filter(function (d) {
        return _accessor(d) >= start && _accessor(d) <= end;
      });
    } else {
      var firstHalf = _array.filter(function (d) {
        return _accessor(d) >= start && _accessor(d) <= lastPoint;
      });
      var secondHalf = _array.filter(function (d) {
        return _accessor(d) <= end && _accessor(d) >= firstPoint;
      });
      filteredArray = firstHalf.concat(secondHalf);
    }

    return filteredArray;
  };

  return _circularbrush;

  function brushstart(event, d) {
    var _mouse = d3.pointer(event, _brushG.node());

    if (_brushData[0] === undefined) {
      _brushData[0] = this;
    }

    _originalBrushData = {
      startAngle: _brushData[0].startAngle,
      endAngle: _brushData[0].endAngle,
    };

    _newBrushData = _brushData;

    _origin = _mouse;
    _change = 0;
    _pre = Math.atan2(_mouse[1], _mouse[0]);
  }

  function resizeDown(event, d) {
    var _mouse = d3.pointer(event, _brushG.node());

    if (_brushData[0] === undefined) {
      _brushData[0] = this;
    }

    if (d.class == "resize e") {
      resizeMove("e", d, this.parentNode.parentNode);
    } else if (d.class == "resize w") {
      resizeMove("w", d, this.parentNode.parentNode);
    } else {
      resizeMove("extent", d, this.parentNode.parentNode);
    }
  }

  function resizeMove(_resize, d, th) {
    var _mouse = d3.pointer(event, _brushG.node());
    var _current = Math.atan2(_mouse[1], _mouse[0]);
    var _start = Math.atan2(_origin[1], _origin[0]);

    if (_resize == "e") {
      var clampedAngle = Math.max(
        Math.min(
          _originalBrushData.startAngle + (_current - _start),
          _originalBrushData.endAngle
        ),
        _originalBrushData.endAngle - 2 * Math.PI
      );

      if (
        _originalBrushData.startAngle + (_current - _start) >
        _originalBrushData.endAngle
      ) {
        clampedAngle =
          _originalBrushData.startAngle + (_current - _start) - Math.PI * 2;
      } else if (
        _originalBrushData.startAngle + (_current - _start) <
        _originalBrushData.endAngle - Math.PI * 2
      ) {
        clampedAngle =
          _originalBrushData.startAngle + (_current - _start) + Math.PI * 2;
      }

      var _newStartAngle = clampedAngle;
      var _newEndAngle = _originalBrushData.endAngle;
    } else if (_resize == "w") {
      var clampedAngle = Math.min(
        Math.max(
          _originalBrushData.endAngle + (_current - _start),
          _originalBrushData.startAngle
        ),
        _originalBrushData.startAngle + 2 * Math.PI
      );

      if (
        _originalBrushData.endAngle + (_current - _start) <
        _originalBrushData.startAngle
      ) {
        clampedAngle =
          _originalBrushData.endAngle + (_current - _start) + Math.PI * 2;
      } else if (
        _originalBrushData.endAngle + (_current - _start) >
        _originalBrushData.startAngle + Math.PI * 2
      ) {
        clampedAngle =
          _originalBrushData.endAngle + (_current - _start) - Math.PI * 2;
      }

      var _newStartAngle = _originalBrushData.startAngle;
      var _newEndAngle = clampedAngle;
    } else {
      var _newStartAngle =
        _originalBrushData.startAngle + (_current - _start * 1);
      var _newEndAngle = _originalBrushData.endAngle + (_current - _start * 1);
    }

    if (_newStartAngle < 0) {
      _newStartAngle += Math.PI * 2;
    }

    if (_newEndAngle < 0) {
      _newEndAngle += Math.PI * 2;
    }

    if (_newStartAngle > Math.PI * 2) {
      _newStartAngle = _newStartAngle - Math.PI * 2;
    } else if (_newStartAngle < -(Math.PI * 2)) {
      _newStartAngle = _newStartAngle + Math.PI * 2;
    }

    if (_newEndAngle > Math.PI * 2) {
      _newEndAngle = _newEndAngle - Math.PI * 2;
    } else if (_newEndAngle < -(Math.PI * 2)) {
      _newEndAngle = _newEndAngle + Math.PI * 2;
    }

    if (_newStartAngle > _newEndAngle) {
      var tmp = _newEndAngle;
      _newEndAngle = _newStartAngle;
      _newStartAngle = tmp;
    }

    if (
      (_change && _newStartAngle < _extent[d.spc][1]) ||
      _newEndAngle < _extent[d.spc][1] ||
      _newStartAngle > _extent[d.spc][2] ||
      _newEndAngle > _extent[d.spc][2]
    ) {
      if (_change >= 0) {
        if (_resize == "extent") {
          _newStartAngle = _extent[d.spc][1];
          _newEndAngle =
            _newStartAngle +
            (_originalBrushData.endAngle - _originalBrushData.startAngle);
        } else {
          _newEndAngle =
            _extent[d.spc][2] < _newEndAngle ? _newStartAngle : _newEndAngle;
          _newStartAngle = _extent[d.spc][1];
        }
      } else {
        if (_resize == "extent") {
          _newEndAngle = _extent[d.spc][2];
          _newStartAngle =
            _newEndAngle -
            (_originalBrushData.endAngle - _originalBrushData.startAngle);
        } else {
          _newStartAngle =
            _extent[d.spc][1] > _newStartAngle ? _newEndAngle : _newStartAngle;
          _newEndAngle = _extent[d.spc][2];
        }
      }
    } else {
      _change = _pre - _current;
      _pre = _current;
    }

    if (
      _newStartAngle == _extent[d.spc][1] &&
      _newEndAngle - _newStartAngle < 0
    ) {
      _newEndAngle = _newStartAngle + _handleSize * 2;
    }
    if (
      _newEndAngle == _extent[d.spc][2] &&
      _newEndAngle - _newStartAngle < 0
    ) {
      _newStartAngle = _newEndAngle - _handleSize * 2;
    }

    _newBrushData = [
      {
        startAngle: _newStartAngle,
        endAngle: _newEndAngle,
        class: "extent",
        spc: d.spc,
      },
      {
        startAngle: _newStartAngle - _handleSize,
        endAngle: _newStartAngle,
        class: "resize e",
        spc: d.spc,
      },
      {
        startAngle: _newEndAngle,
        endAngle: _newEndAngle + _handleSize,
        class: "resize w",
        spc: d.spc,
      },
    ];

    brushRefresh(th);
  }

  function brushRefresh(th) {
    _brushG.selectAll("path.circularbrush").data(_newBrushData).attr("d", _arc);

    var _range = [_newBrushData[0].startAngle, _newBrushData[0].endAngle];
    var _argument = [
      {
        selection: _range,
      },
    ];
    _listeners.apply("brush", th, _argument);
    _listeners.apply("end", th, _argument);
  }

  function brushend() {

    var th = this.parentNode.parentNode;
    _brushData = _newBrushData;

    var _range = [_brushData[0].startAngle, _brushData[0].endAngle];
    var _argument = [
      {
        selection: _range,
      },
    ];

    _listeners.apply("end", th, _argument);
  }

  function updateBrushData() {
    _brushData[0].startAngle = _range[0];
    _brushData[0].endAngle = _range[1];

    _brushData[1].startAngle = _range[0] - _handleSize;
    _brushData[1].endAngle = _range[0];

    _brushData[2].startAngle = _range[1];
    _brushData[2].endAngle = _range[1] + _handleSize;
  }
};
