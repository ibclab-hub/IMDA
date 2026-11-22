<?php
    $script = "../../script/compare/";
    
	$session = $_GET["session"];
    $id = $_GET["jobid"];
    $pid = $_GET["pid"];

	$cmd = "perl $script/quit_and_process.pl   $session $id $pid";
    error_log($cmd);
	$result = system($cmd);
?>
