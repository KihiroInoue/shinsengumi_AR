<?php

$directory_path = "./newKml";
if(file_exists($directory_path)){
    echo "A directory already exists<br />";
}else{
    if(mkdir($directory_path, 0777)){
        chmod($directory_path, 0777);
        echo "I made a directory";
    }else{
        echo "I couldn't make a directory";
    }
}

$list;

$files = glob('photographs_en.kml');
$list = array();
foreach ($files as $file) {
    if (is_file($file)) {
        $list[] = $file;
    }
    if (is_dir($file)) {
        $list = array_merge($list, getFileList($file));
    }
}

foreach ($list as $value){
	$filePath = $value;

	$xml = simplexml_load_file($filePath);
	echo 'A KML file "' . $value . '" is loaded' . '<br />';

	foreach ($xml->Document->Folder->Placemark as $placemark) {	
		$descriptionOriginal = $placemark->description;
		$start = mb_strpos($descriptionOriginal,'<p class="image">');
		$end = mb_strpos($descriptionOriginal,'<div class="reference">');
		$photoHtml = mb_substr($descriptionOriginal,$start,$end-$start);
		$descriptionMod = str_replace($photoHtml,'',$descriptionOriginal);
		$newPhotoHtml = '<div class="balloon">' . $photoHtml;
		$descriptionNew = str_replace('<div class="balloon">',$newPhotoHtml,$descriptionMod);
		$placemark->description = $descriptionNew;
	}
		$newfileName = "newKml/" . $filePath;
		$xml->asXml($newfileName);
	echo 'A modified KML file is saved' . '<br />';	
}

?>