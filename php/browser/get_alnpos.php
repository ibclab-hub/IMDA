<?php
    $script = "../../script/browser/";

    $aln_path = $_GET["alnpath"];
    $refspc = $_GET["refspc"];
	$pos = $_GET["position"];
	
    $cmd = "perl $script/get_alndata.pl $aln_path $refspc $pos";
    error_log($cmd);
	system($cmd);
?>
