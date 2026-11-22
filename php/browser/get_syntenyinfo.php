<?php
    $script = "../../script/browser/";
    $accession = $_GET["accession"];

    $list = shell_exec("perl $script/get_synteny_desc.pl $accession");
    echo $list;
?>
