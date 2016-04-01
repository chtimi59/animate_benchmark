package game
{
    public interface IGameServerServices 
    { 
        function onShowAdvert(evt:Object);
        function onShowInstruction(evt:Object);
		function onShowDemoLabel(evt:Object);
		function onShowSplashScreen(evt:Object);
		function onEslWait(evt:Object);
		function onShowHighScore(evt:Object);
		
		function onSetPlayer1(evt:Object);
		function onSetPlayer2(evt:Object);
		
		function onStart(evt:Object);
		function onStop(evt:Object);

		function onPlayer1Scan(evt:Object);
		function onPlayer2Scan(evt:Object);
		function onPlayer1Win(evt:Object);
		function onPlayer2Win(evt:Object);
    }
}