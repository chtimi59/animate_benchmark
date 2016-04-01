<!--
	NOTES:
	1. All tokens are represented by '$' sign in the template.
	2. You can write your code only wherever mentioned.
	3. "DO NOT" alter the tokens in the template html as they are required during publishing.
-->

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Test</title>
<!-- write your code here -->


<script src="https://code.createjs.com/createjs-2015.11.26.min.js"></script>
<script src="Test.js?1459524295520"></script>
<script src="main.js"></script>
<script>
var canvas, stage, exportRoot;
function init() {
	// --- write your JS code here ---
	
	canvas = document.getElementById("canvas");
	images = images||{};

	var loader = new createjs.LoadQueue(false);
	loader.addEventListener("fileload", handleFileLoad);
	loader.addEventListener("complete", handleComplete);
	loader.loadManifest(lib.properties.manifest);
}

function handleFileLoad(evt) {
	if (evt.item.type == "image") { images[evt.item.id] = evt.result; }
}

function handleComplete(evt) {
	exportRoot = new lib.Test();

	stage = new createjs.Stage(canvas);
	stage.addChild(exportRoot);
	stage.update();

	createjs.Ticker.setFPS(lib.properties.fps);
	createjs.Ticker.addEventListener("tick", stage);
    
    new Main();
}

</script>

<!-- write your code here -->

</head>
<body onload="init();" style="background-color:#D4D4D4;margin:0px;">
	<canvas id="canvas" width="1680" height="1050" style="background-color:#FFFFFF"></canvas>
</body>
</html>
