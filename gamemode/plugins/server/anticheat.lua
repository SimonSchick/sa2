local PLUGIN = Plugin("Anticheat", {"Sourcenans"})


--[[<?php
	function findMatchingSteamID() {
		$conn = mysqli_connect("localhost", "user", "pass", "db");
		$res = $conn->query(
			'SELECT IntToSteam(`steamid`) as `steamid` FROM `sa_player_join` INNER JOIN `sa_player`
			ON `sa_player_join`.`playerid`=`sa_player`.`playerid`');
		if($res->num_rows > 0) {
			return $res->fetchRow()['steamid'];
		}
		return null;
	}
	
	function banUserIfFound() {
		$id = findMatchingSteamID();
		if($id) {
			$SourceBans = new SourceBansConnection();
			$SourceBans->banID($id);
		}
	}
	
	function isSteamBrowser() {
		return $_SERVER['HTTP_USER_AGENT']
	}
	
	function isSteamHTTPRequest() {
		return $_SERVER['HTTP_USER_AGENT']
	}
	
	if(!(isset($_GET['action']) && isSteamBrowser()) || (isset($_POST['action') && isSteamHTTPRequest())
		banUserIfFound();
	
	$source = isset($_GET['action']) ? $_GET : isset($_POST['action']) ? $_POST : null;
	if(!$source || $source['action'] != 'report')
		banUserIfFound();
	
	$id = (isset($source['plyid']) ? (is_numeric($source['plyid']) ? floor($source['plyid']) : null))
	if(!$id)
		banUserIfFound();
		
	$token = (isset($source['token']) ? (strlen($source['token'] !== 64) ? $source['token'] : null));
	if(!$token)
		banUserIfFound();
		
	$conn = mysqli_connect("localhost", "user", "pass", "db");
	$res = $conn->query(
		'SELECT IntToSteam(`steamid`) as `steamid` FROM `sa_player_join` WHERE `unique_token` = 
		\''.$conn->escape($token).'\';');
		
	if($res->num_rows > 0) {
		$SourceBans = new SourceBansConnection();
		$SourceBans->banID($res->fetchRow()['steamid']);
	}
?>]]
function PLUGIN:OnEnable()
	concommand.Add("saant1ch3at", function(ply, cmd, args)
		if(args[1] == "!") then
			--SA.Plugins.Sourcebans:BanPlayer(ply, 0, "Anticheat triggered")
		end
	end)
	
	util.AddNetworkString("SAAnt1ch3atSelfReport")
	net.Receive("SAAnt1ch3atSelfReport", function(len, ply)
		if(args[1] == "!") then
			net.ReadString()
			net.ReadString()
			--SA.Plugins.Sourcebans:BanPlayer(ply, 0, "Anticheat triggered")
		end
	end)
	
	
	util.AddNetworkString("SAAnt1ch3atTokenReply")
	net.Receive("SAAnt1ch3atTokenReply", function(len, ply)
		if(not (net.ReadString() == ply.__SAAntiCheatToken)) then
			--SA.Plugins.Sourcebans:BanPlayer(ply, 0, "Anticheat triggered")
		else
			ply.__SAAntiCheatOk = true
		end
	end)
	
	util.AddNetworkString("SAAnt1ch3atToken")
	SA:AddEventListener("PlayerLoaded", "SAAntiCheat", function(ply)
		local token = util.CRC(tostring(SysTime()) .. ply:Ping() .. ply:SteamID())
		timer.Simple(4, function()
			net.Start("SAAnt1ch3atToken")
				ply.__SAAntiCheatToken = token
				net.WriteUInt(token, 32)
			net.Send(ply)
		end)
		timer.Simple(8, function()
			if(not ply.__SAAntiCheatOk) then
				--SA.Plugins.Sourcebans:BanPlayer(ply, 0, "Anticheat triggered")
			else
				ply.__SAAntiCheatToken = nil
				ply.__SAAntiCheatOk = nil
			end
		end)
	end)
end

function PLUGIN:OnDisable()
	concommand.Remove("saant1ch3at")
	SA:RemoveEventListener("PlayerLoaded", "SAAntiCheat")
	
	net.Receive("SAAnt1ch3atSelfReport", nil)
	net.Receive("SAAnt1ch3atTokenReply", nil)
end

SA:RegisterPlugin(PLUGIN)