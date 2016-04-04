package anim
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
    
    import anim.IClientServices;
    
	public class Client {

        /* Listener */
        private var mListener:IClientServices = null;
                
        /* TCP socket to connect to the server */
		private var mSocket: Socket = null;
		
        /* HTTP Server PATH for ASSETS */
        private var mPath:String;
        private var mIp:String;
        private var mPort:Number;
        
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
				mListener.onReceived(json);
            }
		}
		
		/* constructor */
		public function Client(ip:String, port:Number, listener:IClientServices)
		{	
            mListener = listener;
			mIp = ip;
			mPort = port;
			mPath = "http://"+mIp+":"+mPort+"/";
			
			/* apply policy */
            trace("policy: " + mPath + "crossdomain.xml"); 
			
			Security.allowDomain("*");
			Security.loadPolicyFile(mPath + "crossdomain.xml");			
		
            /* little test */
            var urlLoader:URLLoader = new URLLoader();
			var urlRequest:URLRequest = new URLRequest(mPath + "text.txt");
			urlLoader.addEventListener(Event.COMPLETE, function (evt:Event):void { trace(urlLoader.data); });
			urlLoader.load(urlRequest);
						
			mSocket = new Socket();
			mSocket.addEventListener(Event.CLOSE, closeHandler);
			mSocket.addEventListener(Event.CONNECT, connectHandler);
			mSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			mSocket.connect(mIp, mPort);
		}
	}



}