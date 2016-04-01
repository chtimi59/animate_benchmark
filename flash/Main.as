package {
    import flash.display.MovieClip;
    import flash.text.*;
    import flash.system.*;
    import flash.display.Sprite;
    import flash.geom.Rectangle; 
    import flash.media.Sound;
    
    public class Main extends MovieClip
    {
         
         var frames:int=0;
         var prevTimer:Number=0;
         var curTimer:Number=0;
         
         function fps(e:Event):void {
            frames+=1;            
            if(curTimer-prevTimer>=1000){
                curTimer=getTimer();
                this.title.text = Math.round(frames*1000/(curTimer-prevTimer)));
                prevTimer=curTimer;
                frames=0;
            }
          }

          public function Main() {
            trace("start");
            this.title.text="...";			
            this.removeChild(this.placeholder);
			this.addEventListener(Event.ENTER_FRAME,fps);
			/*for (var j:int=0; j<10; j=j+5) {
				for (var i:int=0; i<10; i=i+5)
				{
					var t = new A();
					t.x = i;
					t.y = j;
					t.width = 2;
					t.height = 2;
					this.addChild(t);
				}
			}*/
         }
    }
}