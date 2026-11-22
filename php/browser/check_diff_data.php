<?php
    $script = "../../script/browser/";

    $analysis = $_GET["analysis"];
    $session= $_GET["session"];
    $synteny_id = $_GET["syntenyid"];
    $profile_ids = $_GET["sampleids"]; 
    $jobid = shell_exec("bash $script/make_job_id.sh $session");
    $email = $_GET["email"];

    $profile_ids = str_replace(" ", ",", $profile_ids);
    $jobid = str_replace(array("\r\n","\r","\n"),'',$jobid);

    #check data existance
    $check_cmd = "perl $script/check_Diff_DATA.pl $session  $jobid  $analysis  $synteny_id  $profile_ids   $email";
    #$check_cmd = "perl $script/check_CS_Diff_DATA.pl $session  $jobid  $analysis  $synteny_id  $profile_ids   $email";
    $check = exec($check_cmd);
    #error_log("check diff pipe job $check");
    echo "$check";
?>
