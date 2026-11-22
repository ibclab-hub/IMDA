<?php
header('Content-Type: application/json; charset=utf-8');

$species = $_POST['species'] ?? null;
if (!is_array($species) || count($species) < 2 || count($species) > 100 ||
    count(array_unique($species)) !== count($species)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid species selection.']);
    exit;
}
foreach ($species as $id) {
    if (!is_string($id) || !preg_match('/\A[A-Za-z0-9_.-]+\z/D', $id)) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid assembly ID.']);
        exit;
    }
}

$script = __DIR__ . '/../../script/compare/get_pairwise_distance.pl';
$args = implode(' ', array_map('escapeshellarg', $species));
$output = [];
$returnCode = 0;
exec('perl ' . escapeshellarg($script) . ' ' . $args . ' 2>&1', $output, $returnCode);
if ($returnCode !== 0) {
    error_log('Pairwise distance lookup failed: ' . implode("\n", $output));
    http_response_code(500);
    echo json_encode(['error' => 'Unable to retrieve evolutionary distances.']);
    exit;
}
$result = json_decode(implode("\n", $output), true);
if (!is_array($result) || !isset($result['pairs'])) {
    http_response_code(500);
    echo json_encode(['error' => 'Invalid distance response.']);
    exit;
}
echo json_encode($result);
