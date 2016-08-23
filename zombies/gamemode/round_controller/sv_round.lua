util.AddNetworkString("updateRound")
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
activeRound = 1
local t = 0
local interval = 3
local zombieCount = 6
local isSpawning = false
local positions = {
	Vector(648.569580, -246.743088, -12287.975586),
	Vector(2.734118, 152.259125, -12287.975586),
	Vector(-517.236023, -521.195251, -12287.975586),
	Vector(-494.958130, 43.163109, -12287.975586),
	Vector(-32.042698, 748.289673, -12287.975586),
	Vector(793.767700, -365.695862, -12287.976563)
}
util.AddNetworkString("UpdateRoundStatus")
util.AddNetworkString("kills")
function beginRound()
	roundStatus = 1
	clUp()
	isSpawning = true
	net.Start("updateRound")
	net.Broadcast()
end
function stuffs()
	activeRound = 1
	roundStatus = 1
	zombieCount = 6
	hp = 50
	zombie = "npc_zombie"
	for _, ply in pairs(player.GetAll()) do
		ply:SetNWInt("killcounter",0)
	end
	net.Start("openLobby")
	net.Broadcast()
end
function bestSpawn()
	local best_spawn = Vector(0,0,0)
	local closestdis = 0
	if table.Count(ents.FindByClass("npc_zombie")) == 0 then
		return positions[math.random(1, table.Count(positions))]
	end
	for _, pos in pairs(positions) do
		local closestZDis = 1000000
		for _, ent in pairs(ents.FindByClass(zombie)) do
			if ent:GetPos():Distance(pos) < closestZDis then
				closestZDis = ent:GetPos():Distance(pos)
			end
		end
		if closestZDis > closestdis then
			closestdis = closestZDis
			best_spawn = pos
		end
	end
end
local zombie = "npc_zombie"
local hp = 50
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
			ply:SetPos(positions[math.random(1, table.Count(positions))])
			ply:Spawn()
			beginRound()
			stuffs()
		end)
	end
	clUp()
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
function clUp()
	net.Start("UpdateRoundStatus")
		net.WriteInt(roundStatus, 4)
	net.Broadcast()
end
local multiplier = 1.00
local amountKilled = 0
local currentRound = 1
local wait = false
hook.Add("Think", "Waves", function()
	if roundStatus == 1 and isSpawning == true then
		wait = false
		if t < CurTime() then
			t = CurTime() + interval
			local ent = ents.Create(zombie)
			ent:SetPos(bestspawn or positions[math.random(1, table.Count(positions))])
			ent:Spawn()
			ent:SetHealth(hp * multiplier)
			ent:Activate()
			zombieCount = zombieCount - 1
			if not IsValid(ent) then
				amountKilled = amountKilled + 1
			end
			if amountKilled == 25 then
				for _, ply in pairs(player.GetAll()) do
					ply:Give("weapon_stunstick")
				end
				amountKilled = amountKilled + 1
			end
			if activeRound % 5 == 0 then
				zombie = "npc_zombine"
				hp = 100
			elseif activeRound % 7 == 0 then
				zombie = "npc_fastzombie"
				hp = 70
			elseif activeRound % 15 == 0 then
				zombie = "npc_poisonzombie"
				hp = 200
			elseif activeRound % 10 == 0 then
				roundStatus = 2
				isSpawning = false
				local ent = ents.Create("npc_antlionguard")
				ent:SetPos(bestspawn or positions[math.random(1, table.Count(positions))])
				ent:Spawn()
				ent:SetHealth(750)
				ent:Activate()
				if not IsValid(ent) then
					isSpawning = false
					roundStatus = 1
				end
			else
				zombie = "npc_zombie"
				hp = 50
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
		net.Send("updateRound")
			net.WriteInt(activeRound, 5)
		net.Broadcast()
		multiplier = multiplier + 0.75
		wait = true
		PrintMessage(HUD_PRINTTALK, "Round: " .. activeRound .. " has begun!")
		for _, ply in pairs(player.GetAll()) do
			ply:SetNWInt("wave", activeRound)
		end
		timer.Create("rektkid", 7, 1, function()
			zombieCount = 5 * activeRound
			isSpawning = true
		end)
	end
	if amount == #player.GetAll() then
		roundStatus = 0
	end
end)