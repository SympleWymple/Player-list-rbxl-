-- made by symple
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamService = game:GetService("Teams")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local AttributeService = game:GetService("CollectionService")

local LoadModule coroutine.wrap(function(...) LoadModule = require(ReplicatedStorage:WaitForChild("LoadModule")) end)()
while (not LoadModule.Loaded) do  game:GetService("RunService").Heartbeat:Wait()  end

local PlayerListClosed = false
local PlayerListUI = nil
local TrackAllPlayers = {}
local TeamNumberCount = {}

local rankAndRegInfo = LoadModule.Directory.RegandRank

local openPlayerDropDownUI = nil
local PlayerDropDownTweenInfo = TweenInfo.new(.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function decideBlackorWhite(colour)
	return math.sqrt(0.299 * (colour.r * colour.r) + 0.587 * (colour.g * colour.g) + 0.114 * (colour.b * colour.b)) < 0.5
end

local greyColour = Color3.new(0.137255, 0.137255, 0.137255)
local whiteColour = Color3.new(1, 1, 1)
local blackColour = Color3.new(0, 0, 0)

local function AddTeams(scrollingFrame)
	for teamNumber, TeamInstance:Team in ipairs(TeamService:GetTeams()) do
		if not scrollingFrame:FindFirstChild(TeamInstance.Name) then --check is not already been added
			local teamColor = TeamInstance.TeamColor.Color
			local TeamName = TeamInstance.Name
			local shouldBeBlackOrWhite = decideBlackorWhite(TeamInstance.TeamColor.Color)
			local clone = script.TeamTemplate:Clone()
			clone.Name = TeamName
			clone.Parent = scrollingFrame
			clone.TeamHeader.TeamName.Text = TeamName
			clone.TeamHeader.BackgroundColor3 = teamColor
			clone.Visible = false
			clone.LayoutOrder = teamNumber
			
			clone.UIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, greyColour), ColorSequenceKeypoint.new(0.95, greyColour), ColorSequenceKeypoint.new(0.95, TeamInstance.TeamColor.Color), ColorSequenceKeypoint.new(1, TeamInstance.TeamColor.Color) })
			clone.TeamHeader.TeamName.TextColor3 = shouldBeBlackOrWhite and whiteColour or blackColour
			TeamNumberCount[TeamInstance.Name] = 0
		end
	end
end


local function GetRankAndDivision(Player: Player)
	--> Rank
	local rankTable = rankAndRegInfo.RankShortenings
	local shortName = "N/A"
	for _, ranks in ipairs(rankTable) do
		if LoadModule.Functions.CheckRank(Player, rankAndRegInfo.MainGroupID) == ranks["ID"] then
			shortName  = ranks["ShortName"] break
		end
		if LoadModule.Functions.CheckRank(Player, LoadModule.Variables.MainGroupID) == 0 then
			shortName = "CIV" 
			break
		end
	end

	--> Division
	local regTable = rankAndRegInfo.Regiments
	local regShortName = "N/A"
	for count, regs in ipairs(regTable) do
		if LoadModule.Functions.CheckRank(Player, regs["ID"]) >= regs["RankRequired"] then
			regShortName = regs["ShortName"]
			break
		end

		if LoadModule.Functions.CheckRank(Player, LoadModule.Variables.MainGroupID) == 0 then
			regShortName = "CIV"
			break
		end
	end
	return {["Rank"] = shortName, ["Reg"] = regShortName}
end

local function AddPlayer(client: Player,  scrollingFrame)
	local playerClone = script.PlayerTemplate:Clone()
	
	playerClone.Username.Text = client.Name
	playerClone.StatsFrame.KOs.Text = client.Kills.Value
	playerClone.StatsFrame.RANK.Text = GetRankAndDivision(client)["Rank"]
	playerClone.StatsFrame.REG.Text = GetRankAndDivision(client)["Reg"]
	
	playerClone.Name = client.Name
	playerClone.Parent = scrollingFrame:FindFirstChild(client.Team.Name).PlayerHolder
	
	if LoadModule.Functions.CheckRank(client, 16934083) >= 3 then
		playerClone.Username.Text = "🔨 "..client.Name
	end
	
	TeamNumberCount[client.Team.Name] += 1
end

local function TeamChange(player)
	TeamNumberCount[TrackAllPlayers[player.Name].team.Name] -= 1
	PlayerListUI.Container.ScrollingFrame:FindFirstChild(TrackAllPlayers[player.Name].team.Name).PlayerHolder:FindFirstChild(player.Name):Destroy()
	AddPlayer(player, PlayerListUI.Container.ScrollingFrame)
	TrackAllPlayers[player.Name].team = player.Team
end

repeat task.wait() until Players.LocalPlayer.PlayerGui:FindFirstChild("Playerlist")
PlayerListUI = Players.LocalPlayer.PlayerGui:WaitForChild("Playerlist")

coroutine.wrap(function(...)  
	AddTeams(PlayerListUI.Container.ScrollingFrame)
end)()


local function trackPlayers()
	for i, frames in PlayerListUI.Container.ScrollingFrame:GetChildren() do
		if frames:IsA("Frame") and frames.Name ~= "TOPFrame" then
			for j, player in frames.PlayerHolder:GetChildren() do
				if player:IsA("Frame") then
					if not Players:FindFirstChild(player.Name) then
						TeamNumberCount[player.Parent.Parent.Name] -= 1
						TrackAllPlayers[player.Name] = nil
						player:Destroy()
					end
				end
			end
		end
	end
	
	for i, player in game.Players:GetPlayers() do
		if player:FindFirstChild("Kills") and player:FindFirstChild("__LOADED") then
			if not TrackAllPlayers[player.Name] then 
			
				TrackAllPlayers[player.Name] = {
					["player"] = player,
					["team"] = player.Team
				}
				
				AddPlayer(player, PlayerListUI.Container.ScrollingFrame)
				
			else
				if player.Team ~= TrackAllPlayers[player.Name].team then
					TeamChange(player)
				else
					
					local playerFrame = PlayerListUI.Container.ScrollingFrame:FindFirstChild(player.Team.Name).PlayerHolder:FindFirstChild(player.Name)
					playerFrame.StatsFrame.KOs.Text = player.Kills.Value
				end
			end
			
			for teamName, playersInTeam in TeamNumberCount do
				PlayerListUI.Container.ScrollingFrame:FindFirstChild(teamName).Visible = true and playersInTeam > 0 or false
			end
		end
	end
end

coroutine.wrap(function(...)  
	while true do
		if workspace.CurrentCamera.ViewportSize.X < 1020 then
			PlayerListUI.Container.Visible = false
		else
			PlayerListUI.Container.Visible = true
			trackPlayers()
		end
		for i= 1, 10  do
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
end)()

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

UserInputService.InputBegan:Connect(function(input)
	if UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		if PlayerListClosed == false then
			TweenService:Create(PlayerListUI.Container,TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(2, 0.07) 
			}):Play()
			PlayerListClosed = true
		else
			TweenService:Create(PlayerListUI.Container,TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.99, 0.07) 
			}):Play()
			PlayerListClosed = false
		end
	end
end)
