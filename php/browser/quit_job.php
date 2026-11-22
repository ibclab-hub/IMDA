<?php
    $script = "../../script/browser/";

	$pid = $_GET["pid"];
    $session_id = $_GET["session"];
    $job_id = $_GET["jobid"];
    #$cmd = "kill -15 $pid";
    $cmd = "perl $script/quit_job.pl $pid $session_id $job_id";
    
    shell_exec($cmd);
?>
