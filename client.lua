local player = game:GetService("Players").LocalPlayer
local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local playerList  = script.Parent
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
local closeMenuTab = Enum.KeyCode.Tab

local closed = false
local viewHiddenTeams = false

if InputService.TouchEnabled then
	playerList.Container.Visible = false
end

InputService.InputBegan:Connect(function(keycode, chat)
	if chat then return end
	if keycode.KeyCode == closeMenuTab then
		if not closed then
			TweenService:Create(playerList.Container,TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(1.4, 0,0.053, 0)}):Play()
		else
			TweenService:Create(playerList.Container,TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.796, 0,0.053, 0)}):Play()
		end
		closed = not closed
	end
end)

playerList.Container.ScrollingFrame.ViewTeams.MouseButton1Click:Connect(function()
	local done = true
	if not done then return end
	playerList.Container.hideTeam.Value = not playerList.Container.hideTeam.Value
	if not viewHiddenTeams then -- just make all teams visible
		done = false
		for i, Teams in pairs(game:GetService("Teams"):GetTeams()) do
			if playerList.Container.ScrollingFrame:FindFirstChild(Teams.Name) then
				playerList.Container.ScrollingFrame:FindFirstChild(Teams.Name).Visible = true
			end
		end
		playerList.Container.ScrollingFrame.ViewTeams.Text = "Unview Empty Teams"
		done = true
	end
	
	if viewHiddenTeams then
		done = false
		for i, Teams in pairs(game:GetService("Teams"):GetTeams()) do
			local hideTeam = true
			if playerList.Container.ScrollingFrame:FindFirstChild(Teams.Name) then
				for i, players in pairs(game:GetService("Players"):GetPlayers()) do
					if players.Team == Teams then
						hideTeam = false
					end
				end
				if hideTeam then playerList.Container.ScrollingFrame:FindFirstChild(Teams.Name).Visible = false end
			end
		end
		playerList.Container.ScrollingFrame.ViewTeams.Text = "View Empty Teams"
		done = true
	end
	viewHiddenTeams = not viewHiddenTeams
end)
