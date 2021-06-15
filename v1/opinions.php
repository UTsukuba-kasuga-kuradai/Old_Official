<?php
header('Access-Control-Allow-Origin: *');  
header("Content-Type: text/json; charset=utf-8");
setlocale(LC_ALL, 'ja_JP.UTF-8');
$file_path = 'opinions.csv';

function get_params() {
  $label = $_REQUEST["label"];
  $pages = $_REQUEST["pages"];
  echo $label;
  echo $pages;
}

get_params();

function get_csv($file) {
  $fp  = fopen($file, "r");
  while (($data = fgetcsv($fp, 0, ",")) !== FALSE) {
    $csv[] = $data;
  }
  fclose($fp);
  return $csv;
}

function parse_csv($csv) {
  // var_dump($csv);
  $first = 0;
  $last = 16;
  if ($page = $_REQUEST["page"]) {
    $first = 16 * $page;
    $last = $last + $first;
  }
  $data = [];
  $item = [];

  for ($i = $first ; $i < $last; $i++) {
    if ($csv[$i]) {
      $item[] = array(
        "file_name" => $csv[$i][2],
        "label" => $csv[$i][3]
      );
    }
  }

  $count = count($csv) - 1;
  array_shift($item);

  $data = array(
    "info" => array("count" => $count),
    "item" => $item
  );
  return $data;
}

function create_json($data) {
  return json_encode($data);
}

function output_json($json) {
  echo json_encode($json);
}

$csv = get_csv($file_path);
$data = parse_csv($csv);
$json = create_json($data);
output_json($json);
// $json = get_json();
// output_json($json);
exit();
?>