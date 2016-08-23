GM.Name = "Zombies. A Half Life 2 based zombie gamemode."
GM.Author = "Papyrus"
function GM:Initialize()
	self.BaseClass.Initialize(self)
end
util.PrecacheModel("models/player/kleiner.mdl")