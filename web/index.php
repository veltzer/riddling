<html>
	<head>
		<meta charset="UTF-8">
		<title>Riddling</title>
		<link rel="shortcut icon" href="favicon.ico"/>
	</head>
	<body>
		<h1>Welcome to the riddling project</h1>
		<p>
		<b>riddles</b> is collection of riddles in tex format.
		You can find the latest version <a href="../out/riddling.pdf">here</a>.
		</p>
		<iframe src="viewer/viewer.html" width="100%" height="1700px"></iframe>
		<p>
		Mark Veltzer, <?php 
			$copyYear = 2012;
			$curYear = date('Y');
			echo $copyYear . (($copyYear != $curYear) ? '-' . $curYear : '');
		?>
		<a href="mailto:mark.veltzer@gmail.com">mark.veltzer@gmail.com</a>
		</p>
	</body>
</html>