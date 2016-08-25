util.AddNetworkString("updateRound")
util.AddNetworkString("giveWeapon")
util.AddNetworkString("beginGame")
util.AddNetworkString("loop1")
local meta = FindMetaTable("Player")
function meta:MaxAmmo()
	for _, weap in pairs(self:GetWeapons()) do
		local ammo = weap:GetPrimaryAmmoType()
		local ammo2 = weap:GetSecondaryAmmoType()
		self:SetAmmo(200, ammo, true)
		self:SetAmmo(2, ammo2, true)
	end
end
roundStatus = 0 -- 0 is off, 1 is on for normal zombies, 2 is for boss zombies.
activeRound = 0
local t = 0
local interval = 4
local zombieCount = 6
local isSpawning = false
local positions = {}
local zombie = "npc_zombie"
local hp = 25
local amountReady = 0
local shouldStart = nil
local multiplier = 1.00
local amountKilled = 0
local currentRound = 1
local wait = false
function AddZombieSpawn(map, position)
	timer.Simple(1, function()
		if game.GetMap() == map then
			table.insert(positions, position)
		end
	end)
end
function AddHumanSpawn(map, position, ang)
	timer.Simple(1, function()
		if game.GetMap() == map then
			local ent = ents.Create("spawn_human")
			if not IsValid(ent) then
				return
			end
			ent:SetPos(position)
			ent:SetAngles(ang)
			ent:Spawn()
			ent:DropToFloor()
		end
	end)
end
hook.Add("InitPostEntity", "hooman", AddHumanSpawn)
hook.Add("InitPostEntity", "zambie", AddZombieSpawn)
-----------------------------------------------------
--Add spawnpoints for gm_construct, the default map--
AddHumanSpawn("gm_construct", Vector(491, -402, 83), Angle(0, 30, 0));
-----------------------------------------------------
AddZombieSpawn("gm_construct", Vector(820, -109, 79));
AddZombieSpawn("gm_construct", Vector(781, 337, -79));
AddZombieSpawn("gm_construct", Vector(843, -458, 79));
AddZombieSpawn("gm_construct", Vector(790, 62, -79));
AddZombieSpawn("gm_construct", Vector(830, -319, -79));
AddZombieSpawn("gm_construct", Vector(500, -402, 83));
AddZombieSpawn("gm_construct", Vector(550, -402, 83));
AddZombieSpawn("gm_construct", Vector(825, -688, 79));
AddZombieSpawn("gm_construct", Vector(832, -220, -79));
-----------------------------------------------------
----------------------------------------------------
-- Add any custom spawnpoints for other maps here.--
----------------------------------------------------
net.Receive("readyUp", function(len, ply)
	local readied = ply:GetNWBool("ready")
	if readied == true then
		amountReady = amountReady + 1
	end
end)
if amountReady >= #player.GetAll() then
	shouldStart = true
end
function beginRound()
	if shouldStart then
		roundStatus = 1
		for _, ply in pairs(player.GetAll()) do
			ply:SetTeam(1)
			ply:SetNWInt("wave", activeRound)
		end
		net.Start("updateRound")
		net.Broadcast()
	end
end
net.Receive("beginGame", beginRound)
function bestSpawn()
	local bestspawn = Vector(0,0,0)
	local cDis = 0
	for _, pos in pairs(positions) do
		local zDis = 1000000
		for _, ent in pairs(ents.FindByClass(zombie)) do
			if ent:GetPos():Distance(pos) < zDis then
				zDis = ent:GetPos():Distance(pos)
			end
		end
	end
	if zDis > cDis then
		cDis = zDis
		bestspawn = pos
	end
end
hook.Add("DoPlayerDeath", "addingOnward", function(ply, att, infl)
	roundStatus = 0
	zombieCount = 0
	isSpawning = false
end)
function endRound()
	roundStatus = 0
	zombieCount = 0
	isSpawning = false
	local zombieTypes = {
		"npc_zombie",
		"npc_zombine",
		"npc_fastzombie",
		"npc_poisonzombie",
		"npc_antlionguard",
		"npc_headcrab"
	}
	for _, zombieT in pairs(zombieTypes) do
		for _, ent in pairs(ents.FindByClass(zombieT)) do
			ent:Remove()
		end
	end
	for _, ply in pairs(player.GetAll()) do
		ply:Lock()
		timer.Simple(10, function()
			ply:UnLock()
			GAMEMODE:PlayerSelectSpawn(ply)
			ply:Spawn()
			beginRound()
		end)
	end
	timer.Simple(11, function()
		roundStatus = 1
		zombieCount = 6
		hp = 25
		zombie = "npc_zombie"
		roundStatus = 1
		activeRound = 1
		hp = 25
		zombie = "npc_zombie"
		zombieCount = 6
		isSpawning = true
		interval = 5
		currentRound = 1
		net.Start("openLobby")
		net.Broadcast()
	end)
end
function stopPlaying(ply)
	ply:Lock()
end
function roundStat()
	return roundStatus
end
function returnRound()
	return activeRound
end
hook.Add("Think", "Waves", function()
	if roundStatus == 1 and isSpawning == true then
		wait = false
		if t < CurTime() then
			t = CurTime() + interval
			local ent = ents.Create(zombie)
			ent:SetPos(positions[math.random(1, table.Count(positions))])
			ent:Spawn()
			if #player.GetAll() <= 0 then
				return false
			else
				ent:SetTarget(player.GetAll()[math.random(1, #player.GetAll())])
			end
			ent:SetHealth(hp * activeRound)
			ent:Activate()
			ent:SetGravity(1)
			ent:SetVelocity(Vector(500, 0, 0)) --Do not remove. If you do, the zombies will spawn ontop of each other sadly.
			zombieCount = zombieCount - 1
			if not IsValid(ent) then
				amountKilled = amountKilled + 1
			end
			if currentRound % 4 == 0 then
				for _, ply in pairs(player.GetAll()) do
					ply:MaxAmmo()
				end
				PrintMessage(HUD_PRINTCENTER, "MAX AMMO!")
				sound.Play("powerup/max_ammo.mp3", player.GetAll()[1]:GetPos(), 75, 100)
				currentRound = currentRound + 1
			end
			if zombieCount <= 0 then
				isSpawning = false
			end
		end
	end
	if roundStatus == 1 and isSpawning == false and table.Count(ents.FindByClass(zombie)) == 0 and wait == false then
		sound.Play("rounds/round/round_end.mp3", player.GetAll()[1]:GetPos(), 75, 100)
		timer.Simple(7, function() sound.Play("rounds/round/round_start.mp3", player.GetAll()[1]:GetPos(), 75, 100) end)
		activeRound = activeRound + 1
		currentRound = currentRound + 1
		multiplier = multiplier + 0.75
		wait = true
		for _, ply in pairs(player.GetAll()) do
			ply:SetNWInt("wave", activeRound)
		end
		timer.Create("rektkid", 7, 1, function()
			if activeRound % 8 == 0 then
				zombie = "npc_zombine"
				hp = 50
				zombieCount = 6
			elseif activeRound % 5 == 0 then
				zombie = "npc_fastzombie"
				hp = 15
				zombieCount = 10
			elseif activeRound % 15 == 0 then
				zombie = "npc_poisonzombie"
				hp = 75
				zombieCount = 6
			else
				zombie = "npc_zombie"
				hp = 25
				zombieCount = 5 * activeRound
			end
			if activeRound >= 5 and activeRound < 10 then
				interval = 3
			elseif activeRound >= 10 then
				interval = 2
			end
			isSpawning = true
			PrintMessage(HUD_PRINTTALK, "Round: " .. activeRound .. " has begun!")
		end)
	end
	if amount == #player.GetAll() then
		roundStatus = 0
	end
end)
hook.Add("Think", "giveweaponsCL", function()
	net.Receive("giveWeapon", function(len, ply)
		local killcounter = ply:GetNWInt("killcounter")
		local killamount = killcounter
		if killamount % 39 == 0 then
			ply:Give("weapon_stunstick")
			killamount = killamount + 1
		end
	end)
end)
