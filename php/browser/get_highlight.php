<?php
    $script = "../../script/browser/";
	$path = $_GET["path"];
	
    $cmd = "perl $script/get_highlight.pl $path";
    file_put_contents('php://stderr', "#$cmd\n");
	system($cmd);
?>
