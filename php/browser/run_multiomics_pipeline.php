<?php
    $script = "../../script/browser/";

	$analysis = $_GET["analysis"];
	$session= $_GET["session"];
	$synteny_id = $_GET["syntenyid"];
	$sample_ids = $_GET["sampleids"];
	$jobid = shell_exec("bash $script/make_job_id.sh $session");
	$email = $_GET["email"];
	$opts_str = $_GET["opts"];

    $opts = json_decode($opts_str);
    $jobid = str_replace(array("\r\n","\r","\n"),'',$jobid);


	$command_param = "";
	foreach ($opts as $param=>$arg){
		$command_param .= "--$param $arg ";
	}

    #activate this for run Multiomics 
    $command = "perl $script/run_Multiomics_PIPE.pl $analysis --session_id $session --job_id $jobid --synteny $synteny_id $command_param $sample_ids $email";
   error_log($command);


    ##test GENOME 
    #test genome all  
    #$command = "perl ../script/run_Multiomics_PIPE.pl GENOME --session_id test  --aln_program LASTZ --syn_program makeblocks --resolution 1000000 GRCh38.p13  GRCh38.p13,TAIR10.1  $email ";
    #test check aln 
    #$command = "perl ../script/run_Multiomics_PIPE.pl GENOME --session_id test  --aln_program LASTZ --syn_program makeblocks --resolution 1000000 TAIR10.1  Pop_tri_v3,Glycine_max_v4.0  $email ";
    #test check onlygenome 
    #$command = "perl ../script/run_Multiomics_PIPE.pl GENOME --session_id test  --aln_program LASTZ --syn_program makeblocks --resolution 100k Release-6-plus-ISO1-MT  UCI_Dpse_MV25,Prin_Dsim_3.1  $email ";
    
    
    
    #$command = "perl ../script/run_Multiomics_PIPE.pl $analysis --session_id test $session --synteny $synteny_id $command_param $sample_ids $email";
	#$command = "perl ../script/test/test.pl";
	#$command = "perl ../script/run_Multiomics_PIPE.pl RNA $analysis --session_id $session --synteny $synteny_id $command_param $sample_ids $email";
	#$command = "perl ../script/run_Multiomics_PIPE.pl HIC $analysis --session_id $session --synteny $synteny_id $command_param $sample_ids $email";

	passthru($command);
?>
