<?php
    $script = "../../script/browser/";

	$accession = $_GET["accession"];
	
    $cmd = "python $script/get_analysis.py $accession";
	system($cmd);
?>
