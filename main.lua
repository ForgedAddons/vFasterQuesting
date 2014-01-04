local addon, ns = ...

ns.completed_quests = {}
ns.uncompleted_quests = {}

function ns:canAutomate ()
	if IsShiftKeyDown() then
		return false
	else
		return true
	end
end

function ns:strip_text (text)
	if not text then return end
	text = text:gsub('%[.*%]%s*','')
	text = text:gsub('|c%x%x%x%x%x%x%x%x(.+)|r','%1')
	text = text:gsub('(.+) %(.+%)', '%1')
	text = text:trim()
	return text
end

ns.RegisterEvent("QUEST_PROGRESS", function()
	if not self:canAutomate() then return end
	if IsQuestCompletable() then
		CompleteQuest()
	end
end)

ns.RegisterEvent("QUEST_LOG_UPDATE", function()
	if not self:canAutomate() then return end
	local start_entry = GetQuestLogSelection()
	local num_entries = GetNumQuestLogEntries()
	local title
	local is_complete
	local no_objectives

	self.completed_quests = {}
	self.uncompleted_quests = {}

	if num_entries > 0 then
		for i = 1, num_entries do
			SelectQuestLogEntry(i)
			title, _, _, _, _, _, is_complete = GetQuestLogTitle(i)
			no_objectives = GetNumQuestLeaderBoards(i) == 0
			if title and (is_complete or no_objectives) then
				self.completed_quests[title] = true
			else
				title = title or ''
				self.uncompleted_quests[title] = true
			end
		end
	end

	SelectQuestLogEntry(start_entry)
end)

ns.RegisterEvent("GOSSIP_SHOW", function()
	if not self:canAutomate() then return end

	local button
	local text

	for i = 1, 32 do
		button = _G['GossipTitleButton' .. i]
		if button:IsVisible() then
			text = self:strip_text(button:GetText())
			if button.type == 'Available' then
				button:Click()
			elseif button.type == 'Active' then
				if self.completed_quests[text] then
					button:Click()
				end
			end
		end
	end
end)

ns.RegisterEvent("QUEST_GREETING", function()
	if not self:canAutomate() then return end

	local button
	local text

	for i = 1, 32 do
		button = _G['QuestTitleButton' .. i]
		if button:IsVisible() then
			text = self:strip_text(button:GetText())
			if self.completed_quests[text] then
				button:Click()
			elseif not self.uncompleted_quests[text] then
				button:Click()
			end
		end
	end
end)

ns.RegisterEvent("QUEST_DETAIL", function()
	if not self:canAutomate() then return end
	AcceptQuest()
end)

ns.RegisterEvent("QUEST_COMPLETE", function()
	if not self:canAutomate() then return end
	if GetNumQuestChoices() == 1 then
		GetQuestReward(1)
	end
	if GetNumQuestChoices() == 0 then
		GetQuestReward(nil)
	end
end)