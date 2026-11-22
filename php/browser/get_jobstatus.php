<?php
    $script = "../../script/browser/";

	$session = $_GET["session"];
    $type = $_GET["type"];

	$cmd = "perl $script/get_loginfo.pl $session $type";
    error_log($cmd);
	system($cmd);
?>
