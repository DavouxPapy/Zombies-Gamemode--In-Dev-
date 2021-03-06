--You will need the map made customely for this gamemode. You wont get errors if you use other maps, but you and the zombies will spawn elsewhere.
--Map directory located in MapDirectory.txt
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
-- Round Files--
AddCSLuaFile("round_controller/cl_round.lua")
include("round_controller/sv_round.lua")
----
AddCSLuaFile("lobby_manager/cl_lobby.lua")
include("lobby_manager/sv_lobby.lua")
--Class Networking Strings--
util.AddNetworkString("class1")
util.AddNetworkString("class2")
util.AddNetworkString("class3")
util.AddNetworkString("class4")
util.AddNetworkString("readyUp")
playersReady = 0
----
local class1weaps = {
	"weapon_crowbar",
	"weapon_357"
}
local class2weaps = {
	"weapon_crowbar",
	"weapon_smg"
}
local class3weaps = {
	"weapon_ar2",
	"weapon_crowbar"
}
local class4weaps = {
	"weapon_shotgun",
	"weapon_crowbar"
}
local ammos = {
	"pistol",
	"buckshot",
	"ar2",
	"smg1",
	"357"
}
local pos = {
	Vector(776.157532, 767.663940, -12287.975586),
}
function GM:PlayerInitialSpawn(ply)
	ply:SetModel("models/player/kleiner.mdl")
	ply:SetGravity(1)
	ply:SetWalkSpeed(250)
	ply:SetRunSpeed(320)
	ply:SetCrouchedWalkSpeed(0.3)
	ply:SetHealth(40)
	GAMEMODE:PlayerSelectSpawn(ply)
	ply:SetNWBool("ready", false)
	ply:SetTeam(1)
	ply:GodDisable()
	net.Start("openLobby")
	net.Send(ply)
end
function GM:GetRound()
	return activeRound
end
function GM:PlayerLoadout()
	net.Receive("class1", function(len, ply)
		for _, weap in pairs(class1weaps) do
			ply:Give(weap)
			ply:GiveAmmo(90, ammos[5], true)
		end
	end)
	net.Receive("class2", function(len, ply)
		for _, weap in pairs(class2weaps) do
			ply:Give(weap)
			ply:GiveAmmo(90, ammos[4], true)
		end
	end)
	net.Receive("class3", function(len, ply)
		for _, weap in pairs(class3weaps) do
			ply:Give(weap)
			ply:GiveAmmo(70, ammos[3], true)
		end
	end)
	net.Receive("class4", function(len, ply)
		for _, weap in pairs(class4weaps) do
			ply:Give(weap)
			ply:GiveAmmo(48, ammos[2], true)
		end
	end)
end
function GM:PlayerDeathSound()
	return true
end
function GM:PlayerSelectSpawn(pl)
	pl:SetPos(table.Random(pos))
end
function GM:CanPlayerSuicide(ply)
	return false
end
function GM:PlayerShouldTakeDamage()
	return true
end
function GM:GetPlayerPoints(ply)
	return ply:GetPData("points", "0")
end
function GM:GetPlayerKills(ply)
	return ply:GetPData("kills", "0")
end
function GM:HUDShouldDraw(element)
	if element == "CHudDeathNotice" then
		return false
	end
end
function GM:PlayerCanHearPlayersVoice()
	return true
end
function GM:PlayerCanPickupItem()
	return false
end
function GM:PlayerCanPickupWeapon()
	return true
end
function KillCounter( victim, killer, weapon )
	killer:SetNWInt("killcounter", killer:GetNWInt("killcounter") + 1)
end
local amountKilled = 0
hook.Add("OnNPCKilled", "Addkills", KillCounter)
function GM:DoPlayerDeath(ply, att, infl)
	ply:SetNWInt("wave", 1)
	ply:SetNWInt("killcounter", 0)
	ply:SetNWBool("ready", false)
	stopPlaying(ply)
	amountKilled = amountKilled + 1
	if amountKilled == #player.GetAll() and #player.GetAll() ~= 0 then
		endRound()
		sound.Play("rounds/round/game_over_4.mp3", att:GetPos())
	end
	if returnRound() == 1 then
		ply:PrintMessage(HUD_PRINTCENTER, "GAME OVER! YOU SURVIVED " .. returnRound() .. " ROUND!")
	elseif returnRound() == 0 then
		ply:PrintMessage(HUD_PRINTCENTER, "You didnt survive any roundes :(")
	else
		ply:PrintMessage(HUD_PRINTCENTER, "GAME OVER! YOU SURVIVED " .. returnRound() .. " ROUNDS!")
	end
	ply:ChatPrint("You have died! You must wait for the other humans to die now.")
end
function GM:PlayerSelectSpawn(pl)
	local selectSpawns = ents.FindByClass("spawn_human")
	local random = table.Random(selectSpawns)
	return random
end
hook.Add("PlayerShouldTakeDamage", "lel", function(ply, ent)
	if ply:Team() == 1 and IsValid(ply) then
		return true
	end
end)
local amountready = 0
hook.Add("Think", "stuffs", function()
	for _, ply in pairs(player.GetAll()) do
		if ply:GetNWBool("ready") then
			amountready = amountready + 1
		end
	end
	if amountready == #player.GetAll() then
		net.Start("loop1")
		net.Broadcast()
	end
end)
hook.Add("EntityTakeDamage", "moar", function(ent, dmginfo)
	if ent:IsPlayer() and IsValid(ent) and ent:Team() == 1 then
		local hp = ent:Health()
		local dmgtaken = hp - dmginfo:GetDamage()
		ent:SetHealth(dmgtaken)
		if ent:Health() <= 0 then
			ent:Kill()
		end
		return true
	end
end)
