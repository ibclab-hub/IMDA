<?php
    $script = "../../script/browser/";

    $page_idx = $_GET["page_idx"];
    $row_cnt = $_GET["row_cnt"];
    $sth_query = $_GET["sth_query"];
    #$aln_query = $_GET["aln_query"];
    #$syn_query = $_GET["syn_query"];

    $cmd = "perl $script/search_tabledata.pl $sth_query $page_idx $row_cnt";
    #$cmd = "perl $script/search_tabledata.pl $sth_query $aln_query $syn_query $page_idx $row_cnt";
    error_log($cmd);
    $list = shell_exec($cmd);
   
    echo $list;
?>
