<?php
    $script = "../../script/compare/";

    $type = $_GET["type"];

    if($type == 'all'){
        $cmd = "perl $script/get_spc_list.pl";
        $result = shell_exec($cmd);
    }else{
        $cmd = "perl $script/get_tablespc_list.pl";
        $result = shell_exec($cmd);
    }

    echo $result;
?>
