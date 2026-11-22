
var spc_data;
var sci_com = {};
var search_key = [];

var email_reg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
var resol_reg = /^\d+$/;

// Evolutionary distance validation
var MYA_WARNING_THRESHOLD = 2000;
var imdaJobSubmitting = false;

var php_path = "../php/compare/";

$(document).ready(function () {

  d3.select("#argument").html(
    "<form id='go_jobstate' method='get', action='../browser/index.html'>" +
    "<input type='hidden' name='id' value='" + session_id + "'></form>"
  );

  Get_spcdata();

  // Search species
  $("#search_ref").on("change keyup paste", function () {
    if (jQuery.trim($(this).val()).length > 0) {
      Search_spc(jQuery.trim($(this).val()), "search_ref_result");
    }
  });

  $("#search_comp").on("change keyup paste", function () {
    if (jQuery.trim($(this).val()).length > 0) {
      Search_spc(jQuery.trim($(this).val()), "search_comp_result");
    }
  });

  $("#search_ref").focus(function () {
    if (jQuery.trim($(this).val()).length > 0) {
      $("#search_ref_result > .dropdown-menu").html("");
      Search_spc(jQuery.trim($(this).val()), "search_ref_result");
    }
  });

  $("#search_ref").blur(function () {
    $("#search_ref_result").hide();
  });

  $("#search_comp").focus(function () {
    if (jQuery.trim($(this).val()).length > 0) {
      $("#search_comp_result > .dropdown-menu").html("");
      Search_spc(jQuery.trim($(this).val()), "search_comp_result");
    }
  });

  $("#search_comp").blur(function () {
    $("#search_comp_result").hide();
  });

  // Expand, collapse, unselect
  $("#ref-expand").click(function () {
    $("#ref_div .accordion-collapse").addClass("show");
  });

  $("#ref-collapse").click(function () {
    $("#ref_div .accordion-collapse").removeClass("show");
  });

  $("#ref-uncheck").click(function () {
    $("#ref_div input:checked").prop("checked", false);
    $("#comp_div input:disabled").prop("disabled", false);
  });

  $("#comp-expand").click(function () {
    $("#comp_div .accordion-collapse").addClass("show");
  });

  $("#comp-collapse").click(function () {
    $("#comp_div .accordion-collapse").removeClass("show");
  });

  $("#comp-uncheck").click(function () {
    $("#comp_div input:checked").prop("checked", false);
    $("#ref_div input:disabled").prop("disabled", false);
  });

  // Search prebuilt results
  $("#search").click(function () {
    var is_ready = true;
    var ref = $(".ref_root_children_body input:checkbox:checked").val();

    if (ref === undefined) {
      alert("Please select a reference genome!");
      is_ready = false;
    }

    var tar = [];

    if ($(".comp_root_children_body input:checkbox:checked").length === 0) {
      alert("Please select at least one comparing genome");
      is_ready = false;
    }

    $(".comp_root_children_body input:checkbox:checked").each(function () {
      tar.push($(this).val());
    });

    if (ref === undefined || tar.length === 0) {
      is_ready = false;
    }

    if (is_ready) {
      var ref_sciname = spc_data
        .find((d) => d.data.name == ref)
        .data.parent.split("%|%")[0];

      $("#dbsearch_result").show();

      $("#refgenome").html(
        '<p class="m-1">' + ref_sciname + " (" + ref + ")</p>"
      );

      $("#compgenome").html("");

      tar.forEach(function (t) {
        var t_sciname = spc_data
          .find((d) => d.data.name == t)
          .data.parent.split("%|%")[0];

        $("#compgenome").append(
          '<p class="m-1">' + t_sciname + " (" + t + ")</p>"
        );
      });

      Search_synteny(ref, tar.join(","));
    }
  });

  // Omics information toggle
  $(document).on("click", ".info", function () {
    var click_class = $(this)
      .attr("class")
      .match(/info-\w+/)[0];

    var canvas_id = click_class.replace("info", "omics");
    $("#" + canvas_id).toggleClass("hidden");
  });

  // Reference search navigation
  $(document).on(
    "mousedown",
    "#search_ref_result .dropdown-item",
    function () {
      var id = $(this).attr("id");

      var node = spc_data.find(function (d) {
        return d.id.indexOf(id) != -1;
      });

      var ancs = node.ancestors();

      ancs.forEach(function (d) {
        if (d.id !== "root") {
          $("#btn_ref_" + d.id).removeClass("collapsed");
          $("#ref_" + d.id + "_children").addClass("show");
        }
      });

      $("#ref_div").scrollTop(
        $("#ref_" + ancs[2].id + "_children").position().top -
        $("#ref_div").position().top
      );
    }
  );

  // Target search navigation
  $(document).on(
    "mousedown",
    "#search_comp_result .dropdown-item",
    function () {
      var id = $(this).attr("id");

      var node = spc_data.find(function (d) {
        return d.id.indexOf(id) != -1;
      });

      var ancs = node.ancestors();

      ancs.forEach(function (d) {
        if (d.id !== "root") {
          $("#btn_comp_" + d.id).removeClass("collapsed");
          $("#comp_" + d.id + "_children").addClass("show");
        }
      });

      $("#comp_div").scrollTop(
        $("#comp_" + ancs[2].id + "_children").position().top -
        $("#comp_div").position().top
      );
    }
  );

  $("input[name='radio_aln']").change(function () {
    $("input[name=radio_aln]").removeClass("is-invalid");
    $("#alignment-feedback").hide();
  });

  $("input[name='radio_syn']").change(function () {
    $("input[name=radio_syn]").removeClass("is-invalid");
    $("#synteny-feedback").hide();
  });

  $("#resol").change(function () {
    $("#resol").removeClass("is-invalid");
    $("#resol-feedback").hide();
  });

  $("#email").on("change keyup paste", function () {
    if (email_reg.test($("#email").val())) {
      $("#email").removeClass("is-invalid");
      $("#email-feedback").hide();
    }
  });

  // ============================================================
  // SUBMIT JOB WITH EVOLUTIONARY DISTANCE VALIDATION
  // ============================================================

  $("#submit").on("click", function () {

    // Prevent duplicate submission
    if (imdaJobSubmitting) {
      return;
    }

    var is_ready = true;
    var resolValue = $("#resol").val();
    var emailValue = $("#email").val();

    // Validate resolution
    if (
      !resol_reg.test(resolValue) ||
      Number(resolValue) < 1000 ||
      Number(resolValue) > 1000000
    ) {
      $("#resol").addClass("is-invalid");
      $("#resol-feedback").show();
      is_ready = false;
    }

    // Validate email
    if (
      emailValue.length > 0 &&
      !email_reg.test(emailValue)
    ) {
      $("#email").addClass("is-invalid");
      $("#email-feedback").show();
      is_ready = false;
    }

    if (!is_ready) {
      return;
    }

    // Get selected reference genome
    var ref = $(".ref_root_children_body input:checkbox:checked").val();

    if (ref === undefined) {
      alert("Please select a reference genome!");
      return;
    }

    // Get all selected genomes
    var spcs = [ref];

    $(".comp_root_children_body input:checkbox:checked").each(function () {
      spcs.push($(this).val());
    });

    if (spcs.length < 2) {
      alert("Please select at least one comparing genome");
      return;
    }

    var spc_str = spcs.join(",");
    var synp = "makeblocks";
    var resol = Number(resolValue);
    var email = emailValue.length ? emailValue : "noemail";

    var $submit = $("#submit");

    // Lock submit button during validation and submission
    imdaJobSubmitting = true;
    $submit.prop("disabled", true);

    var statusWindow = window.open("about:blank", "_blank");
    if (statusWindow) {
        statusWindow.document.title = "IMDA Job Status";
        statusWindow.document.body.innerHTML = "<p>Validating evolutionary distances...</p>";
    }

    console.log("Checking evolutionary distances:", spcs);

    // Step 1: Retrieve evolutionary distances
    $.ajax({
      method: "POST",
      url: php_path + "get_pairwise_distance.php",
      data: {
        species: spcs
      },
      dataType: "json"
    })

    .done(function (result) {

      console.log("Evolutionary distance response:", result);

      // Check expected number of pairs
      var expectedPairs = spcs.length * (spcs.length - 1) / 2;

      if (
        !result ||
        !Array.isArray(result.pairs) ||
        result.pairs.length !== expectedPairs
      ) {
        alert(
          "Incomplete evolutionary distance results. " +
          "No job was submitted."
        );

        finishSubmission();
        return;
      }

      var distantPairs = [];
      var unknownPairs = [];

      // Step 2: Check all species pairs
      result.pairs.forEach(function (pair) {

        var label = pair.species1 + " - " + pair.species2;
        var value = Number(pair.distance);

        // Invalid or unavailable distance
        if (
          pair.distance === null ||
          pair.distance === undefined ||
          pair.distance === "" ||
          !Number.isFinite(value) ||
          value < 0 ||
          value >= 9999999
        ) {
          unknownPairs.push(label);
        }

        // Distance exceeds threshold
        else if (value > MYA_WARNING_THRESHOLD) {
          distantPairs.push(
            label + ": " + value.toFixed(2) + " MYA"
          );
        }

      });

      // Step 3: Block invalid species selections
      if (distantPairs.length || unknownPairs.length) {

        if (statusWindow && !statusWindow.closed) { statusWindow.close(); }

        var message = "WARNING: Evolutionary Distance Validation\n\n";

        if (distantPairs.length) {
          message +=
            "The following species pairs exceed " +
            MYA_WARNING_THRESHOLD +
            " MYA:\n" +
            distantPairs.join("\n") +
            "\n\n";
        }

        if (unknownPairs.length) {
          message +=
            "Evolutionary distance information is unavailable for:\n" +
            unknownPairs.join("\n") +
            "\n\n";
        }

        message +=
          "IMDA relies on syntenic regions for downstream " +
          "comparative multi-omic analyses. " +
          "This selection cannot be submitted because " +
          "the evolutionary distance is too large or " +
          "cannot be verified.\n\n" +
          "Please select more closely related species and try again.";

        window.alert(message);

        // Stop submission
        finishSubmission();
        return;
      }

      // Step 4: All pairs passed distance validation
      console.log(
        "Distance validation passed. Submitting job..."
      );

      // Submit analysis job
      Build_synteny(session_id, ref, spc_str, synp, resol, email )
      .fail(function(xhr, status, error) {
        console.error(
          "Job submission request failed:",
          xhr.status,
          status,
          error,
          xhr.responseText
        );
      })
      .always(function(){
        finishSubmission();
      });

      if (statusWindow && !statusWindow.closed) {
        statusWindow.location.replace("./job_status.html?session=" + encodeURIComponent(session_id) );
      } else {
        alert(
          "Job submission request completed. " +
          "Check the job status page for progress."
        );
      }

    })

    .fail(function (xhr, status, error) {

      console.error(
        "Evolutionary distance lookup failed:",
        xhr.status,
        status,
        error,
        xhr.responseText
      );

      alert(
        "Could not verify evolutionary distances. " +
        "No job was submitted. Please try again."
      );

      finishSubmission();

    });

    // Restore button state
    function finishSubmission() {
      imdaJobSubmitting = false;
      $submit.prop("disabled", false);
    }

  });

});


// ============================================================
// SPECIES DATA
// ============================================================

function Get_spcdata() {

  $.ajax({
    method: "get",
    data: {
      type: "all"
    },
    url: php_path + "/get_spclist.php",

    success: function (dat) {

      var table = d3.tsvParse(dat);

      spc_data = d3.stratify()
        .id(function (d) {
          var names = d.name.split("%|%");
          sci_com[names[0]] = names[1];
          return names[0];
        })
        .parentId(function (d) {
          var names = d.parent.split("%|%");
          return names[0];
        })(table);

      var divs = [];

      $(".load_spc").parent().each(function () {
        var target_div = $(this).attr("class").split("_")[0];
        divs.push(target_div);
      });

      spc_data.each(function (d) {

        if (d.children !== undefined && d.id != "root") {

          divs.forEach(function (div) {

            var list =
              "<div class='accordion mt-1'>" +
              "<div class='accordion-item border-0'>" +
              "<h2 class='accordion-header' id='" + div + "_" + d.id + "'>" +
              "<button style='font-size: 0.875rem' " +
              "class='accordion-button collapsed py-1' " +
              "id='btn_" + div + "_" + d.id + "' " +
              "type='button' data-bs-toggle='collapse' " +
              "data-bs-target='#" + div + "_" + d.id + "_children'>" +
              d.id + " (" + sci_com[d.id] + ")" +
              "</button></h2>" +
              "<div id='" + div + "_" + d.id + "_children' " +
              "class='accordion-collapse collapse'>" +
              "<div class='" + div + "_" + d.id +
              "_children_body tab border-start'>" +
              "</div></div></div></div>";

            $("." + div + "_" + d.parent.id + "_children_body")
              .append(list);

          });

          search_key.push([d.id]);
        }

        if (d.children === undefined) {

          divs.forEach(function (div) {

            var checks =
              "<div class='form-check py-1'>" +
              "<input class='form-check-input' type='checkbox' " +
              "value='" + d.id + "' " +
              "id='" + div + "_" + d.parent.id + "_" + d.id + "'>" +
              "<label style='font-size: 0.875rem' " +
              "class='form-check-label' " +
              "for='" + div + "_" + d.parent.id + "_" + d.id + "'>" +
              d.id +
              "</label></div>";

            $("." + div + "_" + d.parent.id + "_children_body")
              .append(checks);

          });

          search_key.push([d.id, d.parent.id]);
        }

      });

      $(".load_spc").addClass("hidden");

    }
  });

  // Reference selection
  $(document).on(
    "change",
    ".ref_root_children_body input:checkbox",
    function () {

      if (
        $(".ref_root_children_body input:checkbox:checked").length >= 2
      ) {
        alert("Only one genome is allowed for reference genome");
        $(this).prop("checked", false);
      }

      $(".comp_root_children_body input:checkbox")
        .prop("disabled", false);

      $(".ref_root_children_body input:checkbox:checked")
        .each(function () {

          $(".comp_root_children_body input:checkbox").filter(
            "[value='" + $(this).val() + "']"
          ).prop("disabled", true);

        });

    }
  );

  // Target selection
  $(document).on(
    "change",
    ".comp_root_children_body input:checkbox",
    function () {

      $(".ref_root_children_body input:checkbox")
        .prop("disabled", false);

      $(".comp_root_children_body input:checkbox:checked")
        .each(function () {

          $(".ref_root_children_body input:checkbox").filter(
            "[value='" + $(this).val() + "']"
          ).prop("disabled", true);

        });

    }
  );

}


// ============================================================
// SEARCH SPECIES
// ============================================================

function Search_spc(query, tar) {

  $("#" + tar).html("");

  query = query.toLowerCase();

  var match = 0;
  var result = [];

  search_key.forEach(function (dat) {

    if (match > 100) return false;

    if (
      dat[0].toLowerCase().indexOf(query) != -1 ||
      (
        dat[0] in sci_com &&
        sci_com[dat[0]] !== undefined &&
        sci_com[dat[0]].toLowerCase().indexOf(query) != -1
      ) ||
      (
        dat.length == 2 &&
        (
          dat[1].toLowerCase().indexOf(query) != -1 ||
          sci_com[dat[1]].toLowerCase().indexOf(query) != -1
        )
      )
    ) {

      match++;

      if (result.indexOf(spc_data[sci_com[dat]]) == -1) {
        result.push(dat);
      }
    }

  });

  var item_cnt = 0;
  var full = false;

  for (var i = 0; i < result.length; ++i) {

    var q = result[i];
    var asm = q[0];
    var item;

    if (q.length == 2) {

      var sci_name = q[1].replaceAll("_", " ");
      var comm_name = sci_com[q[1]].replaceAll("_", " ");

      item = asm + " (" + comm_name + ", " + sci_name + ")";

    } else {

      var comm_name = sci_com[q[0]].replaceAll("_", " ");

      item = asm.replaceAll("_", " ") +
             " (" + comm_name + ")";
    }

    if (item.toLowerCase().indexOf(query) != -1) {

      var print_item =
        "<li><a class='dropdown-item' id='" +
        asm + "'> " + item + "</a></li>";

      $("#" + tar).append(print_item);

      item_cnt++;

      if (item_cnt > 30) {
        full = true;
        break;
      }
    }

    if (full) break;
  }

  $("#" + tar).css({
    "min-width": $(".form-control").width() + 18,
    "max-height": $(".dropdown-item").height() * 15,
    "overflow-y": "auto"
  });

  $("#" + tar).show();
}


// ============================================================
// SEARCH PREBUILT SYNTENY
// ============================================================

function Search_synteny(refspc, tarspc) {

  $("#search_loading").show();

  $.ajax({
    method: "get",
    data: {
      ref: refspc,
      tar: tarspc
    },
    url: php_path + "/search_syntenydata.php",

    success: function (result) {

      $("#search_loading").hide();

      if (result != "NA\n") {

        $("#result_nofind").hide();
        $("#result_nofind .alert").hide();
        $("#result_find").show();

        Make_table([result], "result_table");

      } else {

        $("#result_find").hide();
        $("#result_nofind").show();
        $("#result_nofind .alert").show();

      }
    },

    error: function () {
      $("#search_loading").hide();
      console.error("Failed to search prebuilt synteny.");
    }
  });

}


// ============================================================
// PREBUILT RESULT TABLE
// ============================================================

function Make_table(table_data, out) {

  var table_col = [
    "Accession ID",
    "Scientific name",
    "Assembly ID",
    "Count",
    "Scientific name",
    "Assembly ID",
    "Evolutionary distance",
    "Whole genome alignment",
    "Synteny generation",
    "Resolution (bp)",
    "Download"
  ];

  var selected_col = [0, 1, 2, 4, 5, 7, 8, 9];

  var th = "<thead class='table-light'>";
  th += "<tr class='align-middle'>";

  th += "<td rowspan='2' class='border-bottom'>" +
        table_col[0] + "</td>";

  th += "<td colspan='2' class='border-bottom'>" +
        "Reference genome</td>";

  th += "<td colspan='2' class='border-bottom'>" +
        "Target genome</td>";

  th += "<td colspan='2' class='border-bottom'>" +
        "Program</td>";

  th += "<td rowspan='2' class='border-bottom'>" +
        table_col[9] + "</td>";

  th += "</tr><tr>";

  selected_col.forEach(function (i) {
    if (i != 0 && i != 9 && i != 10) {
      th += "<td>" + table_col[i] + "</td>";
    }
  });

  th += "</tr></thead>";

  $("#" + out).html(th);

  var curln = 0;

  table_data.forEach(function (r) {

    if (!r) return;

    var col = r.split("|")[0].split("\t");

    var aid = col[0];
    var refspc_str = col[1];
    var compspc_str = col[2];
    var res = col[3];
    var aln = col[4];
    var sf = col[5];

    var compspcs = compspc_str.split(/[,:\(]/);
    var refspc_info = refspc_str.split(/\(/);

    var tr_row = compspcs.length;

    var tr = "";

    for (var i = 0; i < tr_row; i += 3) {

      tr += "<tr class='" +
        (curln % 2 ? "table-light " : "") +
        "border-top info info-" + curln + "'>";

      if (i === 0) {

        tr += "<td nowrap rowspan='" + (tr_row / 3) + "'>" +
          "<a href='../browser/genome.html?accession=" +
          aid + "'>" + aid + "</a></td>";

        tr += "<td nowrap rowspan='" + (tr_row / 3) + "'>" +
          refspc_info[0].replaceAll("_", " ") + "</td>";

        tr += "<td nowrap rowspan='" + (tr_row / 3) + "'>" +
          refspc_info[1].replace(")", "") + "</td>";
      }

      tr += "<td nowrap>" +
        compspcs[i].replaceAll("_", " ") + "</td>";

      tr += "<td nowrap>" +
        compspcs[i + 1] + "</td>";

      if (i === 0) {

        tr += "<td nowrap rowspan='" + (tr_row / 3) + "'>" +
          aln + "</td>";

        tr += "<td nowrap rowspan='" + (tr_row / 3) + "'>" +
          sf + "</td>";

        tr += "<td nowrap rowspan='" + (tr_row / 3) + "'>" +
          res + "</td>";
      }

      tr += "</tr>";
    }

    $("#" + out).append(tr);

    curln++;
  });

}


// ============================================================
// BUILD SYNTENY JOB
// ============================================================

function Build_synteny(session, refspc, spcs, synp, resol, email) {

  return $.ajax({
    method: "get",
    data: {
      session: session,
      ref: refspc,
      spc: spcs,
      synp: synp,
      resol: resol,
      email: email
    },
    url: php_path + "/build_synteny.php"
  });

}

