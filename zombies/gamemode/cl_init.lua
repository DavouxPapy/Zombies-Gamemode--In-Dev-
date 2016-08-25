include("shared.lua")
--Round Files--
include("round_controller/cl_round.lua")
----
include("lobby_manager/cl_lobby.lua")
net.Receive("top", function()
	net.Start("usuk")
	net.SendToServer()
end)
scoreboard = scoreboard or {}
function scoreboard:show()
	return false
end
function scoreboard:hide()
	return
end
function GM:ScoreboardShow()
	scoreboard:show()
end
function GM:ScoreboardHide()
	scoreboard:hide()
end
local stuffs = {
	"CHudHealth",
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo"
}
function hideHud(name)
	for _, hud in pairs(stuffs) do
		if name == hud then
			return false
		end
	end
end
hook.Add("HUDShouldDraw", "hideHud", hideHud)
local shouldDraw = true
local function createZFont()
	surface.CreateFont("ZombiesFont", {
		font = "hidden",
		extended = false,
		size = 20,
		weight = 500,
		blursize = 0,
		italic = false,
		symbol = false,
		outline = false,
		shadow = false,
		underline = false,
	})
end
function GM:HUDPaint()
	if shouldDraw then
		shouldDraw = false
		createZFont()
	end
	self.BaseClass:HUDPaint()
	local ply = LocalPlayer()
	local hp = ply:Health()
	surface.SetTextColor(255,255,255,255)
	surface.SetTextPos(10, (ScrH() / 2) + (ScrH() / 4))
	surface.SetFont("ZombiesFont")
	surface.DrawText("Pre Alpha [Gamemode in development]")
	surface.SetTextColor(255,0,0)
	surface.SetTextPos(ScrW() - 800, ScrH() - 98)
	surface.SetFont("ZombiesFont")
	if hp <= 0 then
		surface.DrawText("YOU HAVE DIED!")
	else
		surface.DrawText("CURRENT HEALTH: " .. hp)
	end
	surface.SetTextColor(255,0,0)
	surface.SetTextPos(ScrW() - 920, ScrH() - 98)
	surface.SetFont("ZombiesFont")
	surface.DrawText("KILLS: " .. ply:GetNWInt("killcounter"))


	surface.SetTextColor(255,0,0)
	surface.SetTextPos(ScrW() - 1100, ScrH() - 98)
	surface.SetFont("ZombiesFont")
	surface.DrawText("ROUND: " .. ply:GetNWInt("wave"))
	if IsValid(ply) and ply:Alive() then
		if #ply:GetWeapons() <= 0 then
			return false
		elseif ply:GetActiveWeapon() ~= nil then
			local ammoType = ply:GetActiveWeapon():GetPrimaryAmmoType()
			local reserve = ply:GetAmmoCount(ammoType)
			surface.SetTextColor(255,0,0)
			surface.SetTextPos(ScrW() - 500, ScrH() - 98)
			surface.SetFont("ZombiesFont")
			surface.DrawText("AMMO TOTAL: " .. reserve)
		else
			return false
		end
	else
		return false
	end
end
net.Receive("loop1", function()
	net.Send("beginGame")
	net.SendToServer()
end)
