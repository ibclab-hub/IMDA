<?php
    $script = "../../script/browser/";

    $cmd = "perl $script/get_taxon.pl";
    $result = shell_exec($cmd);

    echo $result;
?>
