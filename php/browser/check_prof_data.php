<?php
    $script = "../../script/browser/";

    $analysis = $_GET["analysis"];
    $session= $_GET["session"];
    $synteny_id = $_GET["syntenyid"];
    $sample_ids = $_GET["sampleids"]; 
	$opts_str = $_GET["opts"];
    $opts = json_decode($opts_str);
	$command_param = "";
	foreach ($opts as $param=>$arg){
		$command_param .= "--$param $arg ";
	}

    #$profile_ids = str_replace(" ", ",", $profile_ids);

    #check data existance
    $command = "perl $script/check_prof_data.pl $analysis --synteny $synteny_id $command_param $sample_ids ";
    $check = exec($command);
    #error_log("check diff pipe job $check");
    echo "$check";


    #activate this for run Multiomics
   error_log($command);
?>
