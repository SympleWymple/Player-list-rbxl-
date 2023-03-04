--> made by symple

local LeaderBoard = {}
local Teams = game:GetService("Teams")

function LeaderBoard:AddTeams(scrollingFrame)
	--> get all teams from game 
	for teamNumber, TeamInstance:Team in ipairs(Teams:GetTeams()) do
		local globalLayoutOrder = 0
		if not scrollingFrame:FindFirstChild(TeamInstance.Name) then --check is not already been added
			local teamColor = TeamInstance.TeamColor
			local TeamName = TeamInstance.Name
			
			for _,Object in pairs(scrollingFrame:GetChildren()) do
				if Object:IsA("Frame") then
					globalLayoutOrder = globalLayoutOrder + 1
				end
			end
			
			local clone = script.Team:Clone()
			clone.Name = TeamName
			clone.Parent = scrollingFrame
			clone.teamName.Text = TeamName
			clone.BackgroundColor = teamColor
			
			clone.LayoutOrder = globalLayoutOrder
			
			local hideStatus = true
			for i, v in pairs(game:GetService("Players"):GetPlayers()) do
				if v.Team == TeamInstance then
					hideStatus = false
				end
			end
			if hideStatus  and scrollingFrame.Parent.hideTeam.Value == true then
				scrollingFrame:FindFirstChild(TeamName).Visible = false
			else
				scrollingFrame:FindFirstChild(TeamName).Visible = true
			end
		end
	end
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end

function LeaderBoard:AddPlayer(client: Player,  scrollingFrame)
	if not scrollingFrame:FindFirstChild(client.Name) then
		local Clone = script:WaitForChild("Player"):Clone()
		
		Clone.Name = client.Name
		Clone.Parent = scrollingFrame
		
		Clone:WaitForChild("Name").Text = client.Name
		Clone.RANKValue.Text = LeaderBoard:GetRankAndDivision(client)["Rank"]
		Clone.REGValue.Text = LeaderBoard:GetRankAndDivision(client)["Reg"]
		Clone.LayoutOrder = scrollingFrame:FindFirstChild(client.Team.Name).LayoutOrder
		Clone.gradient.UIGradient.Color = ColorSequence.new{ --> add UI gradient
			ColorSequenceKeypoint.new(0, client.Team.TeamColor.Color),
			ColorSequenceKeypoint.new(1, client.Team.TeamColor.Color)
		}
		
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
		LeaderBoard:UpdateTeam(client.Team, client.Team.Name, scrollingFrame)
		
	end
end

function LeaderBoard:AddPlayerTOExistingClient(client: Player, List: {table})
	if #List == 0 then return end
	for number, selectedPlayer: Player in pairs(List) do
		local scrollingFrame = selectedPlayer.PlayerGui:WaitForChild("Playerlist").Container.ScrollingFrame
		if not scrollingFrame:FindFirstChild(client.Name) then
			local Clone = script:WaitForChild("Player"):Clone()

			Clone.Name = client.Name
			Clone.Parent = scrollingFrame

			Clone:WaitForChild("Name").Text = client.Name
			Clone.RANKValue.Text = LeaderBoard:GetRankAndDivision(client)["Rank"]
			Clone.REGValue.Text = LeaderBoard:GetRankAndDivision(client)["Reg"]
			
			Clone.gradient.UIGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, client.Team.TeamColor.Color),
				ColorSequenceKeypoint.new(1, client.Team.TeamColor.Color)
			}
			Clone.LayoutOrder = scrollingFrame:FindFirstChild(client.Team.Name).LayoutOrder
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
			LeaderBoard:UpdateTeam(client.Team, client.Team.Name, scrollingFrame)
		end
	end
end

function LeaderBoard:UpdateTeam(Team: Team, Name, scrollingFrame)
	if scrollingFrame:FindFirstChild(Name) then
		local TeamFrame = scrollingFrame:FindFirstChild(Name)
		TeamFrame.Name = Team.Name
		TeamFrame.teamName.Text = Team.Name
		TeamFrame.BackgroundColor3 = Team.TeamColor.Color
		
		local hideStatus = true
		for i, v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Team == Team then
				hideStatus = false
			end
		end
		if hideStatus  and scrollingFrame.Parent.hideTeam.Value == true then
			scrollingFrame:FindFirstChild(Name).Visible = false
		else
			scrollingFrame:FindFirstChild(Name).Visible = true
		end
	end
end

function LeaderBoard:AddKOs(player: Player) : number
	for i, client in pairs(game:GetService("Players"):GetPlayers()) do
		local scrollingFrame = client.PlayerGui:WaitForChild("Playerlist").Container.ScrollingFrame
		if scrollingFrame:FindFirstChild(player.Name) then
			local textLabel = scrollingFrame:FindFirstChild(player.Name)
			local currentKosValue = tonumber(textLabel.KOsValue.Text)
			local newCurrentKosValue = currentKosValue + 1
			
			textLabel.KOsValue.Text = newCurrentKosValue
		else
			continue
		end
	end
	
	local scrollingFrame = script.Parent:WaitForChild("Playerlist").Container.ScrollingFrame
	if scrollingFrame:FindFirstChild(player.Name) then
		local textLabel = scrollingFrame:FindFirstChild(player.Name)
		local currentKosValue = tonumber(textLabel.KOsValue.Text)
		local newCurrentKosValue = currentKosValue + 1

		textLabel.KOsValue.Text = newCurrentKosValue
	end
	return 1
end

function LeaderBoard:RemovePlayer(Player: Player, List)
	local OrginscrollingFrame = script.Parent.Playerlist.Container.ScrollingFrame  
	if OrginscrollingFrame:FindFirstChild(Player.Name) then OrginscrollingFrame:FindFirstChild(Player.Name):Destroy() end
	if #List == 0 then return end
	for number, selectedPlayer: Player in pairs(List) do
		local scrollingFrame = selectedPlayer.PlayerGui:WaitForChild("Playerlist").Container.ScrollingFrame
		if scrollingFrame:FindFirstChild(Player.Name) then
			scrollingFrame:FindFirstChild(Player.Name):Destroy()
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
			LeaderBoard:UpdateTeam(Player.Team, Player.Team.Name, scrollingFrame)
		end
	end
	OrginscrollingFrame.CanvasSize = UDim2.new(0, 0, 0, OrginscrollingFrame.UIListLayout.AbsoluteContentSize.Y)
	LeaderBoard:UpdateTeam(Player.Team, Player.Team.Name, OrginscrollingFrame)
end

function LeaderBoard:GetRankAndDivision(Player: Player)
	local config  = require(script.Parent.Config)
	--> Rank
	local rankTable = config.RankInfo
	local shortName
	for _, ranks in ipairs(rankTable) do
		if Player:GetRankInGroup(config.MainId) == ranks["ID"] then
			shortName  = ranks["ShortName"]break
		end
		if not Player:IsInGroup(config.MainId) then
			shortName = "CIV" 
			break
		end
	end
	
	--> Division
	local regTable = config.RegInfo
	local regShortName
	for count, regs in ipairs(regTable) do
		if Player:IsInGroup(regs["ID"]) then
			regShortName = regs["ShortName"]
			break
		end
		if count ==  11 and not Player:IsInGroup(regs["ID"]) then 
			regShortName = "CIV" 
			break 
		end
		if not Player:IsInGroup(config.MainId) then
			regShortName = "CIV"
			break
		end
	end
	return {["Rank"] = shortName, ["Reg"] = regShortName}
end



LeaderBoard:AddTeams(script.Parent.Playerlist.Container.ScrollingFrame)

--> prob not the best way to do this
game.Players.PlayerAdded:Connect(function(player)
	local list = {}
	for i, players in game:GetService("Players"):GetPlayers() do
		if players.Name ~= player.Name then
			table.insert(list, players)
		end
	end
	while player.Neutral == true do task.wait(1) end
	LeaderBoard:AddPlayer(player, script.Parent:WaitForChild("Playerlist").Container.ScrollingFrame)
	script.Parent.Playerlist:Clone().Parent = player.PlayerGui
	LeaderBoard:AddPlayerTOExistingClient(player, list)
	
	--> KOS stuff
	player.CharacterAdded:Connect(function(Character)
		Character.Humanoid.Died:Connect(function(Died)
			local creator = Character.Humanoid:FindFirstChild("creator")
			if creator ~= nil and creator.Value ~= nil then
				LeaderBoard:AddKOs(game:GetService("Players")[tostring(creator.Value)])
			end
		end)
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	local list = {}
	for i, players in game:GetService("Players"):GetPlayers() do
		if players.Name ~= player.Name then
			table.insert(list, players)
		end
	end
	LeaderBoard:RemovePlayer(player, list)
end)

return LeaderBoard
