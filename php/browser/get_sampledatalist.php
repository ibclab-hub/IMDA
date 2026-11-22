<?php
    $script = "../../script/browser/";

	$sid = $_GET["accession"];
	$spc = $_GET["species"];
	$type = $_GET["datatype"];

	$command = "python $script/get_sample_id.py $sid $spc $type";
	$result = shell_exec($command);

 	echo $result;
?>
