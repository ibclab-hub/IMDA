<?php
    $script = "../../script/browser/";

	$data = $_GET["data"];
    $downsample = $_GET["downsample"];
	$pos = $_GET["position"];
	
    $cmd = "perl $script/get_data.pl $data $downsample $pos";
    error_log($cmd);
	system($cmd);
?>
