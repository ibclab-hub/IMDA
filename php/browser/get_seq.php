<?php
    $script = "../../script/browser/";
    $data_path = "../../database/DATA/GENOME/";

	$prj = $_GET["project"];
	$spc = $_GET["species"];
	$pos = $_GET["position"];

    $spcid = "";
	$cmd = "perl $script/get_seq.pl $spc $pos";
    error_log($cmd);
	$result = system($cmd);
	$seq = json_decode($result);

	echo $seq;
?>
