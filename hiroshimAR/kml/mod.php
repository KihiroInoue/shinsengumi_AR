<?php

$fileName = 'yoyogi';
$filePath = $fileName . '.kml';

$xml = simplexml_load_file($filePath);
echo 'it works.';

foreach ($xml->Document->Folder->Placemark as $placemark) {
	$coordinates = explode(',',$placemark->Point->coordinates);
	$lat = $coordinates[1];
	$lon = $coordinates[0];		
	$descriptionOriginal = $placemark->description;
	$descriptionNew = $descriptionOriginal . '<p id="routeButton"><a href="http://maps.google.com/maps?saddr=&daddr=' . $lat . ',' . $lon . '&z=16"><img src="http://1964.mapping.jp/cesium/icon/navi.png" class="route"></a></p>';	
	$placemark->description = $descriptionNew;
}	
	$newfileName = "new_" . $filePath;
	$xml->asXml($newfileName);

?>