package anim {

    import flash.display.MovieClip;
    import flash.text.*;
	import flash.events.*;
    import flash.system.*;
	import flash.utils.*;
    import flash.display.Sprite;
    import flash.geom.Rectangle; 
    import flash.media.Sound;

    public class Particule extends A
    {
		var angle:Number;
		var velocity:Number;
		
		public function Particule() {
			this.x = Main.STAGE_WIDTH/2-Main.PARTICLE_RADIUS;
			this.y = Main.STAGE_HEIGHT/2-Main.PARTICLE_RADIUS;
			this.width = Main.PARTICLE_RADIUS*2;
			this.height = Main.PARTICLE_RADIUS*2;
			this.angle = Math.PI * 2 * Math.random();
			this.velocity = Main.MAX_VELOCITY / 8 * 7 * Math.random() + Main.MAX_VELOCITY / 8;
		}
		
		public function draw(timeDelta)
		{
			// Calculate next position of particle
			var nextX = x + Math.cos(angle) * velocity * (timeDelta / 1000);
			var nextY = y + Math.sin(angle) * velocity * (timeDelta / 1000);
			
			// If particle is going to move off right side of screen
			if (nextX + Main.PARTICLE_RADIUS * 2 > Main.STAGE_WIDTH)
			{
				// If angle is between 3 o'clock and 6 o'clock
				if ((angle >= 0 && angle < Math.PI / 2))
				{
					angle = Math.PI - angle;
				}
				// If angle is between 12 o'clock and 3 o'clock
				else if (angle > Math.PI / 2 * 3)
				{
					angle = angle - (angle - Math.PI / 2 * 3) * 2
				}
			}
			
			// If particle is going to move off left side of screen
			if (nextX < 0)
			{
				// If angle is between 6 o'clock and 9 o'clock
				if ((angle > Math.PI / 2 && angle < Math.PI))
				{
					angle = Math.PI - angle;
				}
				// If angle is between 9 o'clock and 12 o'clock
				else if (angle > Math.PI && angle < Math.PI / 2 * 3)
				{
					angle = angle + (Math.PI / 2 * 3 - angle) * 2
				}
			}
			
			// If particle is going to move off bottom side of screen
			if (nextY + Main.PARTICLE_RADIUS * 2 > Main.STAGE_HEIGHT)
			{
				// If angle is between 3 o'clock and 9 o'clock
				if ((angle > 0 && angle < Math.PI))
				{
					angle = Math.PI * 2 - angle;
				}
			}
			
			// If particle is going to move off top side of screen
			if (nextY < 0)
			{
				// If angle is between 9 o'clock and 3 o'clock
				if ((angle > Math.PI && angle < Math.PI * 2))
				{
					angle = angle - (angle - Math.PI) * 2;
				}
			}

			
			x = nextX;
			y = nextY;
		}
	}
	
}