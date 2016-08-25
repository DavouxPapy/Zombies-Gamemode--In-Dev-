GM.Name = "Zombies. A Half Life 2 based zombie gamemode."
GM.Author = "Papyrus. Inspiration taken from JetBoom's Zombie Survival gamemode and <CODE BLUE>'s tutorials."
function GM:Initialize()
	self.BaseClass.Initialize(self)
end
team.SetUp(1, "TEAM_SURV", Color(255,0,255), true)
util.PrecacheModel("models/player/kleiner.mdl")
