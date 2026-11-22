<?php
    $script = "../../script/browser/";

	$accession = $_GET["accession"];
	
    $cmd = "python $script/get_all_diff.py $accession";
	system($cmd);
?>
