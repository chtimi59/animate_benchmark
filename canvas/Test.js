(function (lib, img, cjs, ss) {

var p; // shortcut to reference prototypes

// library properties:
lib.properties = {
	width: 1680,
	height: 1050,
	fps: 24,
	color: "#FFFFFF",
	manifest: [
		{src:"images/ASpiria.png?1459524295359", id:"ASpiria"}
	]
};



// symbols:



(lib.ASpiria = function() {
	this.initialize(img.ASpiria);
}).prototype = p = new cjs.Bitmap();
p.nominalBounds = new cjs.Rectangle(0,0,208,213);


(lib.A = function(mode,startPosition,loop) {
	this.initialize(mode,startPosition,loop,{});

	// Layer 1
	this.instance = new lib.ASpiria();

	this.timeline.addTween(cjs.Tween.get(this.instance).wait(1));

}).prototype = p = new cjs.MovieClip();
p.nominalBounds = new cjs.Rectangle(0,0,208,213);


// stage content:
(lib.Test = function(mode,startPosition,loop) {
	this.initialize(mode,startPosition,loop,{});

	// Layer 1
	this.title = new cjs.Text("TOTO", "88px 'Arial'");
	this.title.name = "title";
	this.title.textAlign = "center";
	this.title.lineHeight = 100;
	this.title.lineWidth = 1622;
	this.title.setTransform(840.4,107);

	this.placeholder = new lib.A();
	this.placeholder.setTransform(815.8,518.6,1,1,0,0,0,104,106.5);

	this.timeline.addTween(cjs.Tween.get({}).to({state:[{t:this.placeholder},{t:this.title}]}).wait(1));

}).prototype = p = new cjs.MovieClip();
p.nominalBounds = new cjs.Rectangle(869.4,632,1626.2,518.1);

})(lib = lib||{}, images = images||{}, createjs = createjs||{}, ss = ss||{});
var lib, images, createjs, ss;