<?php
    $script = "../../script/browser/";

	$accession = $_GET["accession"];
	
    $cmd = "python $script/get_alldata.py $accession";
	system($cmd);
?>
