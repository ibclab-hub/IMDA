<?php
    $script = "../../script/browser/";

    $page_idx = $_GET["page_idx"];
    $row_cnt = $_GET["row_cnt"];

    $cmd = "perl $script/get_synteny_list.pl $page_idx $row_cnt";
    error_log($cmd);
    $list = shell_exec($cmd);
    echo $list;
?>
