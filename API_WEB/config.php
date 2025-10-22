<?php
$tlca_data = array();
$tlca_data['server'] = 'localhost';
$tlca_data['dbuser'] = 'socdo';
$tlca_data['dbpassword'] = 'Xdnt.qOPNz8!(cQi';
$tlca_data['dbname'] = 'socdo';
date_default_timezone_set('Asia/Saigon');
//Connect
$conn = mysqli_connect($tlca_data['server'], $tlca_data['dbuser'], $tlca_data['dbpassword'], $tlca_data['dbname']);
// Template config
//@define(skin_name, 'skin');
//@define(skin_ext, '.tpl');
?>