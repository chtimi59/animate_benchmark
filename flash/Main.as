package {
    import flash.display.MovieClip;
    import flash.text.*;
	import flash.events.*;
    import flash.system.*;
	import flash.utils.*;
    import flash.display.Sprite;
    import flash.geom.Rectangle; 
    import flash.media.Sound;
	
	import anim.*;
    
    public class Main extends MovieClip implements anim.IClientServices
    {
 		 public static var MAX_PARTICLES:Number = 500;
         public static var STAGE_WIDTH:Number;
		 public static var STAGE_HEIGHT:Number;
		 public static var MAX_VELOCITY:Number = 500;
		 public static var PARTICLE_RADIUS:Number = 15;

		 var mClient:anim.Client;
		 public function onReceived(evt:Object) {
	     }
		
         var mPrevTimer:Number=0;
         private function fps(e:Event):void {
			var t:Number=getTimer();
			var elapsed = t-mPrevTimer;
			this.mPrevTimer=t;
			if (this.mPrevTimer==0) return;
			this.title.text = String(Math.round(1000/elapsed))+"fps";
			 
			for (var i:int=0; i<MAX_PARTICLES; i++) { 
				var p:anim.Particule = mParticules[i];
				p.draw(elapsed)
			}
          }

		  var mParticules:Array = new Array();
          public function Main() {
            trace("start");
            this.title.text="...";	
			this.removeChild(this.placeholder);
			this.addEventListener(Event.ENTER_FRAME,fps);
			var container = new MovieClip();
			this.addChild(container);
			this.swapChildren(container, title);
			Main.STAGE_WIDTH = stage.stageWidth;
			Main.STAGE_HEIGHT = stage.stageHeight;
			
			mClient = new anim.Client("192.168.0.115", 8081, this);
			
			for (var i:int=0; i<MAX_PARTICLES; i++) {
				var p = new anim.Particule();
				this.mParticules.push(p);
				container.addChild(p);
				p.gotoAndPlay(Math.round(20*Math.random()));
			}	
			
         }
    }
}