<?php

define("TCPSOCKET",  1);
define("WEBSOCKET",  2);

define("UI_SOCKET", TCPSOCKET);
define("CTRL_SOCKET", TCPSOCKET);

use Ratchet\Server\IoServer;
use Ratchet\WebSocket\WsServer;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Http\HttpServer;
use Ratchet\Http\HttpServerInterface;
use Ratchet\Http\HttpRequestParser;
use Guzzle\Http\Message\Response;


function LOG_CTRL_EVT($msg){ echo "CTL-Ev: $msg\n"; }
function LOG_CTRL_TX($msg) { echo "CTL-Tx: $msg\n"; }
function LOG_CTRL_RX($msg) { echo "CTL-Rx: $msg\n"; }
function LOG_UI_EVT($msg)  { echo " UI-Ev: $msg\n"; }
function LOG_UI_TX($msg)   { echo " UI-Tx: $msg\n"; }
function LOG_UI_RX($msg)   { echo " UI-Rx: $msg\n"; }
function LOG_FCT($msg)     { echo "ACTION: $msg\n"; }
function LOG_I($msg)       { echo "      : $msg\n"; }
function LOG_E($msg)       { echo "*error: $msg*\n";  }
function LOG_W($msg)       { echo "*warn: $msg*\n";  }
function LOG_D($msg)       { echo $msg; echo "\n"; }


require("config.php");
require 'game.php';
require 'vendor/autoload.php';


class UIMgnt implements MessageComponentInterface
{
    protected $clients;
    public function __construct() { $this->clients = new \SplObjectStorage; }
    public function onOpen(ConnectionInterface $conn)  { $this->clients->attach($conn); LOG_UI_EVT("Connected"); }
    public function onClose(ConnectionInterface $conn) { $this->clients->detach($conn); LOG_UI_EVT("Disconnected"); }
    public function onError(ConnectionInterface $conn, \Exception $e) { $conn->close(); LOG_UI_EVT("Error $e"); }
    public function onMessage(ConnectionInterface $from, $msg) {
        if (strcmp(trim($msg),"<policy-file-request/>")==0) {
            $this->sendFlashPolicy($from);
            return;
        }
        if (strcmp(substr($msg,0,3),"GET")==0) {
            $line = explode("/n", $msg);
            $getline = explode(" ", $line[0]);
            $this->onHttpGetMessage($from,substr($getline[1],1));
            return;
        }
        LOG_UI_RX($msg);
        $data = json_decode($msg);
        if ($data==null) {
            LOG_W("MalFormated json");
            return;
        }
    }
    public function send($data, $verbose=true){
        $msg = json_encode($data);
        if ($verbose) LOG_UI_TX($msg);
        foreach ($this->clients as $client) {
            $client->send("$msg\n");
        }
    }


    private function createHttpOKHeader($contentType="text/plain", $content="") {
        $date = gmdate('D, d M Y H:i:s \G\M\T');
        $header = "";
        $header .= "HTTP/1.1 200 OK"."\r\n";
        $header .= "Date: $date\r\n";
        $header .= "Server: Apache"."\r\n";
        $header .= "X-Powered-By: PHP/5.3.13"."\r\n";
        $header .= "Content-Length: ".strlen($content)."\r\n";
        $header .= "Content-Type: $contentType"."\r\n";
        $header .= "\r\n";
        if (VERBOSE_HTTP) LOG_I("200 OK");
        return $header;
    }

    private function createHttpNOKHeader($contentType="text/plain", $content="") {
        $date = gmdate('D, d M Y H:i:s \G\M\T');
        $header = "";
        $header .= "HTTP/1.1 404 File Not Found"."\r\n";
        $header .= "Date: $date\r\n";
        $header .= "Server: Apache"."\r\n";
        $header .= "X-Powered-By: PHP/5.3.13"."\r\n";
        $header .= "Content-Length: ".strlen($content)."\r\n";
        $header .= "Content-Type: $contentType"."\r\n";
        $header .= "\r\n";
        if (VERBOSE_HTTP) LOG_I("404 Not Found");
        return $header;
    }

    public function onHttpGetMessage($client,$url) {
        if (VERBOSE_HTTP) LOG_I("GET '$url'");
        $fileExtArray = explode(".", $url);

        // should file with extension
        if (sizeof($fileExtArray)!=2) {
            LOG_E("GET '$url'");
            $client->send($this->createHttpNOKHeader());
            return;
        }
        // Flash policy required ?
        if ($url=="crossdomain.xml") {
            LOG_I("Send Flash Policy (crossdomain.xml)");
            $contents = "";
            $contents .= "<?xml version=\"1.0\"?><!DOCTYPE cross-domain-policy SYSTEM \"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">"."\r\n";
            $contents .= "<cross-domain-policy>"."\r\n";
            $contents .= "    <allow-access-from domain=\"*\" to-ports=\"*\"/>"."\r\n";
            $contents .= "</cross-domain-policy>";
            $header = $this->createHttpOKHeader("text/x-cross-domain-policy", $contents);
            $client->send($header.$contents);
            return;
        }

        // test file required ?
        if ($url=="text.txt") {
            LOG_I("Send test text file");
            $contents = "Hello from text file!!!\r\n";
            $header = $this->createHttpOKHeader("text/plain", $contents);
            $client->send($header.$contents);
            return;
        }

        // 'png' file required ?
        if ($fileExtArray[1]=="png") {
            $url = "www/$url";
            if (!file_exists($url)) {
                LOG_E("GET '$url'");
                $client->send($this->createHttpNOKHeader());
                return;
            }
            $contents = file_get_contents($url);
            if (!$contents) {
                LOG_E("GET '$url'");
                $client->send($this->createHttpNOKHeader());
                return;
            } else {
                $header = $this->createHttpOKHeader("image/png", $contents);
                $client->send($header.$contents);
                return;
            }
        }

        // Failed
        LOG_E("GET '$url'");
        $client->send($this->createHttpNOKHeader());
    }

    public function sendFlashPolicy(ConnectionInterface $client) {
        LOG_I("Send Flash Policy");
        $contents = "";
        $contents = "";
        $contents .= "<cross-domain-policy>\n";
        $contents .= "   <allow-access-from domain=\"*\" to-ports=\"*\" />\n";
        $contents .= "</cross-domain-policy>\n\0";
        $client->send($contents);
    }
}

class CTRLMgnt implements MessageComponentInterface
{
    protected $game;
    public function __construct($game) { $this->game = $game; }
    public function onOpen(ConnectionInterface $conn)  { LOG_CTRL_EVT("Connected"); }
    public function onClose(ConnectionInterface $conn) { LOG_CTRL_EVT("Disconnected"); }
    public function onError(ConnectionInterface $conn, \Exception $e) { LOG_CTRL_EVT("Error $e");  $conn->close(); }
    public function onMessage(ConnectionInterface $from, $msg) {
        LOG_CTRL_RX($msg);
        $arr = explode("\n", $msg);
        foreach($arr as $line) {
            $data = json_decode($line);
            if ($data==null) {
                LOG_E("MalFormated json");
                continue;
            }
            # FORWARD REQUEST TO GAME
            $this->game->onCtrlMsg($data);
        }
    }
    public function send($data){
        $msg = json_encode($data);
        LOG_CTRL_TX($msg);
    }
}


$loop   = React\EventLoop\Factory::create();

#Create objects
$ui = null;
switch(UI_SOCKET) {
    case WEBSOCKET:
        $ui = new UIMgnt();
        break;
    case TCPSOCKET:
        $ui = new UIMgnt();
        break;
}

$game = new Game($ui);

switch(CTRL_SOCKET) {
    case WEBSOCKET:
        $ctrl = new CTRLMgnt($game);
        break;
    case TCPSOCKET:
        $ctrl = new CTRLMgnt($game);
        break;
}



#Add service for UI
$uiServer = null;
$sock1 = new React\Socket\Server($loop);
$sock1->listen(8081, '0.0.0.0');
switch(UI_SOCKET) {
    case WEBSOCKET:
        $uiServer = new Ratchet\Server\IoServer(new Ratchet\Http\HttpServer(new Ratchet\WebSocket\WsServer($ui)), $sock1);
        break;
    case TCPSOCKET:
        $uiServer = new Ratchet\Server\IoServer($ui, $sock1);
        break;
}

#Add service for CTRL(IPAD)
$ctrlServer = null;
$sock2 = new React\Socket\Server($loop);
$sock2->listen(8080, '0.0.0.0');
switch(CTRL_SOCKET) {
    case WEBSOCKET:
        $ctrlServer = new Ratchet\Server\IoServer(new Ratchet\Http\HttpServer(new Ratchet\WebSocket\WsServer($ctrl)), $sock2);
        break;
    case TCPSOCKET:
        $ctrlServer = new Ratchet\Server\IoServer($ctrl, $sock2);
        break;
}

#Game Update
$loop->addPeriodicTimer(0.1, function() use($game){
    $game->onTime();
});

#infinite loop
echo "server running\n";
$loop->run();

mysql_close($link);
