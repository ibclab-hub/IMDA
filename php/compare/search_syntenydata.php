<?php
    $script = "../../script/compare/";

	$ref = $_GET["ref"];
	$tar = $_GET["tar"];
	
	$cmd = "python $script/get_madesyn.py ".$ref." ".$tar;
    $result = shell_exec($cmd);
    echo $result;
?>
