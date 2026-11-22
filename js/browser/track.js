function Fill_dataInfo(config, selector) {
  var desc = "<b> Description </b><ul>";

  var keylist = [
    "Reference genome",
    "Target genome(s)",
    "Whole genome alignment program",
    "Synteny generation program",
    "Minimum resolution (bp)",
  ];
  keylist.forEach(function (key) {
    if (key != "path" && key) {
      var value =
        key != "Minimum resolution (bp)"
          ? config[key]
          : config[key].toLocaleString();
      desc += "<li><p class='m-0'>" + key + ": " + value + "</p></li>";
    }
  });

  desc += "</ul>";
  $(selector).html(desc);
}

function Show_option(data, selector) {
  // Require "name" & "_id" & "vis" key in data
  var id = data._id;

  var newopt;
  if (selector == "#highlight-setting") {
    var randcolor = (randomColor =
      "#" + (0x1000000 + Math.random() * 0xffffff).toString(16).substr(1, 6));

    if (data.sample_spcs.length == 1) {
      newopt =
        "<div id='opt-" +
        id +
        "' class='text-center row pb-3'> \
        <div class='col-2 p-0 border-end row'> \
          <div class='col-1 p-0 align-self-center'><span class='material-symbols-sharp drag_indicator' style='cursor:move'>drag_indicator</span></div><div class='col align-self-center'>Track " +
        data.name +
        "</div> \
        </div> \
        <div class='col'> " +
        "<div class='row'><div class='col-5 row'><div class='col-7 py-1'>Region summary method</div><div class='col py-1'><select class='form-select form-select-sm method_diff_analysis' id='method_diff_analysis-" +
        id +
        "'><option value='avg'selected> Average </option><option value='max'> Max </option><option value='min'> Min </option></select></div></div><div class='col row'><div class='col-4 py-1'>Filtering cutoff</div><div class='col py-1'><div class='input-group'><select class='form-select form-select-sm cutofftype' id='cutofftype-" +
        id +
        "'><option value='perc' selected>Top %</option><option value='value'>Value</option</select><input type='number' id='cutoffvalue-" +
        id +
        "' class='form-control form-control-sm cutoffvalue' value=10></div></div></div><div class='col-2 row'><div class='col'>Color</div><div class='col'><input id='pincolor-" +
        id +
        "' class='pincolor' type='color' value='" +
        randcolor +
        "'></div></div></div>" +
        "<div class='row'></div></div></div> \
      </div>";
    } else {
      newopt =
        "<div id='opt-" +
        id +
        "' class='text-center row pb-3'> \
      <div class='col-2 p-0 border-end row'> \
        <div class='col-1 p-0 align-self-center'><span class='material-symbols-sharp drag_indicator' style='cursor:move'>drag_indicator</span></div><div class='col align-self-center'>Track " +
        data.name +
        "</div> \
      </div> \
      <div class='col'> " +
        "<div class='row'><div class='col-5 row'><div class='col-7 py-1'>Region summary method</div><div class='col py-1'><select class='form-select form-select-sm method_diff_analysis' id='method_diff_analysis-" +
        id +
        "'><option value='avg'selected> Average </option><option value='max'> Max </option><option value='min'> Min </option></select></div></div><div class='col row'><div class='col-4 py-1'>Filtering cutoff</div><div class='col py-1'><div class='input-group'><select class='form-select form-select-sm cutofftype' id='cutofftype-" +
        id +
        "'><option value='pval'>P-value</option><option value='qval' selected>Q-value</option</select><input type='number' id='cutoffvalue-" +
        id +
        "' class='form-control form-control-sm cutoffvalue' value=0.05 step=0.01 min=0 max=1></div></div></div><div class='col-2 row'><div class='col'>Color</div><div class='col'><input id='pincolor-" +
        id +
        "' class='pincolor' type='color' value='" +
        randcolor +
        "'></div></div></div>" +
        "<div class='row'></div></div></div> \
    </div>";
    }
  } else {
    newopt =
      "<div id='opt-" +
      id +
      "' class='text-center row pb-3'> \
    <div class='col-2 p-0 border-end row'><div class='col-1 p-0 align-self-center'><span class='material-symbols-sharp drag_indicator' style='cursor:move'>drag_indicator</span></div><div class='col align-self-center'>Track " +
      data.name +
      "</div></div><div class='col'>";

    if (data.type == "Gene annotation") {
      newopt +=
        "<div class='row'> \
            <div class='col-3 py-1 align-self-center'><label class='col-form-label pe-0 py-1' for='method_downsample-" +
        id +
        "'>Visualization level</level></div><div class='col-3 align-self-center'><select class='form-select form-select-sm method_downsample' id='method_downsample-" +
        id +
        "'><option value='gene'>Gene</option><option value='na'>Exon and Intron</option></select></div> \
        <div class='col-3 align-self-center'><label class='col-form-label pe-0 py-1' for='minlen-" +
        id +
        "'>Minimum gene length (bp)</label></div> \
        <div class='col-3 align-self-center'><input type='number' class='form-control form-control-sm minlen' id='minlen-" +
        id +
        "' value=0 step=1000></div></div>";
    } else {
      newopt +=
        "<div class='row'><div class='col-2 py-1'>Y axis range</div><div class='col row'><label class='col-4 col-form-label pe-0 py-1' for='ymin-" +
        id +
        "'>Minimum</label><div class='col'><input type='number' class='form-control form-control-sm yrange' id='ymin-" +
        id +
        "' value=0 disabled></div></div><div class='col row'><label class='col-4 col-form-label pe-0 py-1' for='ymax-" +
        id +
        "'>Maximum</label><div class='col'><input type='number' class='form-control form-control-sm yrange' id='ymax-" +
        id +
        "' value=0 disabled></div></div><div class='col-2 form-check py-1 text-start'><input class='form-check-input yauto' type='checkbox' value='auto' id='auto-" +
        id +
        "' checked><label class='form-check-label' for='auto-" +
        id +
        "'>Set automatically</label></div></div> \
      <div class='row'><div class='col-2 py-1'>Track type</div><div class='col'><select class='form-select form-select-sm type' id='type-" +
        id +
        "'></select></div> \
            <div class='col-3 py-1'>Downsampling method</div><div class='col'><select class='form-select form-select-sm method_downsample' id='method_downsample-" +
        id +
        "'><option value='max'>Max</option><option value='min'>Min</option><option value='avg' selected>Average</option><option value='na'>None</option></select></div></div>";
    }

    newopt += "</div></div>";
  }

  $(selector).append(newopt);
  var type_opts = "";
  data.vis.forEach(function (t) {
    type_opts +=
      "<option value='" +
      t +
      "'>" +
      t.charAt(0).toUpperCase() +
      t.slice(1) +
      "</option>";
  });
  $("#type-" + id).append(type_opts);

  $("#highlight-setting div").addClass("align-self-center");
}

function Make_omicsconfig(data) {
  var type = data.vis[0];
  var min = "auto";
  var max = "auto";

  if (!$("#auto-" + data._id).empty()) {
    min = $("#auto-" + data._id).is(":checked")
      ? "auto"
      : Number($("#ymin-" + data._id).val());
    max = $("#auto-" + data._id).is(":checked")
      ? "auto"
      : Number($("#ymax-" + data._id).val());
  }

  var downsample =
    type == "gene"
      ? $("#minlen-" + data._id).val()
      : $("#method_downsample-" + data._id + " option:selected").val();

  if (!downsample) {
    downsample = $(
      "#method_diff_analysis-" + data._id + " option:selected"
    ).val();
  }

  var conf = {
    name: data.name,
    species: data.spcs,
    type: type,
    range: [min, max],
    path: data.data_path,
    downsample: downsample,
    resizable: true,
  };

  LIBNAME.Update_params_omics(conf);
}
