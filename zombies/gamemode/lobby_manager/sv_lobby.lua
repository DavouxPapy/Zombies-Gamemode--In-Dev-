util.AddNetworkString("openLobby")
util.AddNetworkString("startGame")
function enterLobby()
	net.Start("openLobby")
	net.Broadcast()
end
net.Receive("startGame", function()
	beginRound()
end)