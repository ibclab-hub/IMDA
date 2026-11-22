<?php
    $script = '../../script/browser/get_gene_position.pl';
    $data = $_GET['data'] ?? '';
    $gene = trim($_GET['gene'] ?? '');
    if ($data === '' || $gene === '' || strlen($gene) > 200) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid gene search request']);
        exit;
    }
    $cmd = 'perl ' . escapeshellarg($script) . ' ' . escapeshellarg($data) . ' ' . escapeshellarg($gene);
    passthru($cmd, $status);
    if ($status !== 0) {
        error_log('get_gene_position.pl failed: ' . $status);
    }
?>

