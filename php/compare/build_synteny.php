<?php
    $script = "../../script/compare/";

	$session = $_GET["session"];
	$refspc = $_GET["ref"];
	$spc = $_GET["spc"];
    $synp = $_GET["synp"];
    $resol = $_GET["resol"];
	$email = $_GET["email"];
    $jobid = shell_exec("bash ../../script/make_job_id.sh $session");
    $jobid = str_replace(array("\r\n","\r","\n"),'',$jobid);

    $command = "perl $script/run_Multiomics_PIPE.pl GENOME --session_id $session --job_id $jobid --syn_program $synp --resolution $resol $refspc $spc $email";
    echo $command;
    error_log($command);
    shell_exec($command);
?>
