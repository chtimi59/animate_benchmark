package game
{

	import flash.display.MovieClip;
	import flash.text.*;
	import flash.system.*;

	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	
	import flash.display.Sprite;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.Security;
    
    import game.IGameServerServices;
    
	public class GameServer {

        /* Listener */
        private var mListener:IGameServerServices = null;
                
        /* TCP socket to connect to the server */
		private var mSocket: Socket = null;
		
        /* HTTP Server PATH for ASSETS */
        public static var PATH:String = "http://"+CONFIG::SERVER+":"+CONFIG::PORT+"/";
        
		private function closeHandler(event: Event): void {
			trace("connection closed");
		}
		private function connectHandler(event: Event): void {
			trace("connected");
		}
		private function socketDataHandler(event: ProgressEvent): void {
			var recv:String = "";
			while(mSocket.bytesAvailable) recv += mSocket.readUTFBytes(1);
            var datas:Array = recv.split("\n");
            
            for (var i = 0; i<datas.length; i++) {
                var data:String = datas[i];
				if (data.length==0) continue;
                trace(data);
                var json = JSON.parse(data);                
                switch(json.event) {
                
                    case "onShowAdvert": 
                        mListener.onShowAdvert(json.value);
                        break;     
                    case "onShowInstruction": 
                        mListener.onShowInstruction(json.value);
                        break;     
                    case "onShowDemoLabel": 
                        mListener.onShowDemoLabel(json.value);
                        break;     
					case "onShowSplashScreen": 
                        mListener.onShowSplashScreen(json.value);
                        break;    
                    case "onEslWait": 
                        mListener.onEslWait(json.value);
                        break;
                    case "onShowHighScore":
                        mListener.onShowHighScore(json.value);
                        break;
                    
                    case "onSetPlayer1": 
                        mListener.onSetPlayer1(json.value);
                        break;                    
                    case "onSetPlayer2": 
                        mListener.onSetPlayer2(json.value);
                        break;
                        
                        
                    case "onStart":
                        mListener.onStart(json.value);
                        break;					
                    case "onStop":
                        mListener.onStop(json.value);
                        break;	         
                        

                    
                    case "onPlayer1Scan": 
                        mListener.onPlayer1Scan(json.value);
                        break;                    
                    case "onPlayer2Scan": 
                        mListener.onPlayer2Scan(json.value);
                        break;   
                    case "onPlayer1Win": 
                        mListener.onPlayer1Win(json.value);
                        break;   
                    case "onPlayer2Win": 
                        mListener.onPlayer2Win(json.value);
                        break;   
                                            
                    
                    default:
                        trace("unknown: "+ data);  
                        break;
                }
            }
		}
		
		/* constructor */
		public function GameServer(listener:IGameServerServices)
		{	
            mListener = listener;
			
			/* apply policy */
            trace("policy: " + PATH + "crossdomain.xml"); 
			
			Security.allowDomain("*");
			Security.loadPolicyFile(PATH + "crossdomain.xml");			

            if (CONFIG::NOSERVER) return;			
            /* little test */
            var urlLoader:URLLoader = new URLLoader();
			var urlRequest:URLRequest = new URLRequest(PATH + "text.txt");
			urlLoader.addEventListener(Event.COMPLETE, function (evt:Event):void { trace(urlLoader.data); });
			urlLoader.load(urlRequest);
						
			mSocket = new Socket();
			mSocket.addEventListener(Event.CLOSE, closeHandler);
			mSocket.addEventListener(Event.CONNECT, connectHandler);
			mSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			mSocket.connect(CONFIG::SERVER, CONFIG::PORT);
		}
	}



}