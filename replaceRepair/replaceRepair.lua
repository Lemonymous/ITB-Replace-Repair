
local VERSION = "3.0.0"
local PRIORITY_CUSTOM = 0
local PRIORITY_PILOT = 1
local PRIORITY_MECH = 2

local path = GetParentPath(...)
local selected = require(path.."lib/selected")
local getSelectedPawn = selected.getSelectedPawn

local function onModsInitialized()
	if VERSION < ReplaceRepair.version then
		return
	end

	if ReplaceRepair.initialized then
		return
	end

	ReplaceRepair:finalizeInit()
	ReplaceRepair.initialized = true
end

local function isPilotSkill(self, pawn)
	return pawn:IsAbility(self.PilotSkill)
end

local function isMechType(self, pawn)
	return pawn:GetType() == self.MechType
end

local function addSkill(self, repairSkill)
	-- backwards compatibility
	-- IsActive didn't use to have a 'self' parameter.
	if repairSkill.IsActive then
		repairSkill.isActive = function(self, pawn) return repairSkill.IsActive(pawn) end
	end

	local weapon = repairSkill.weapon or repairSkill.Weapon
	local icon = repairSkill.icon or repairSkill.Icon
	local isActive = repairSkill.isActive
	local pilotSkill = repairSkill.pilotSkill or repairSkill.PilotSkill
	local mechType = repairSkill.mechType or repairSkill.MechType

	Assert.Equals('string', type(weapon), "Field 'weapon'")
	Assert.Equals({'nil', 'string'}, type(icon), "Field 'icon'")
	Assert.Equals({'nil', 'function'}, type(isActive), "Field 'isActive'")

	if isActive then
		repairSkill.priority = PRIORITY_CUSTOM
	else
		if pilotSkill then
			repairSkill.isActive = isPilotSkill
			repairSkill.priority = PRIORITY_PILOT
		elseif mechType then
			repairSkill.isActive = isMechType
			repairSkill.priority = PRIORITY_MECH
		end

		if repairSkill.isActive == nil then
			error(string.format(
				"Repair skill condition not defined for"..
				"repair skill added by mod with id [%s]",
				repairSkill.modId
			))
		end
	end

	local mod = mod_loader.mods[repairSkill.modId]

	if icon then
		icon = icon:match(".-.png$") or icon..".png"

		if modApi:fileExists(mod.resourcePath..icon) then
			repairSkill.surface = sdlext.getSurface{ path = mod.resourcePath..icon }
		elseif modApi:assetExists(icon) then
			repairSkill.surface = sdlext.getSurface{ path = icon }
		end
	end

	table.insert(self.repairSkills, repairSkill)
end

local function getCurrentSkill(self)
	if not Board then
		return nil
	end

	local highlighted = Board:GetHighlighted() or Point(-1, -1)
	local pawn = getSelectedPawn() or Board:GetPawn(highlighted)

	if pawn == nil then
		return
	end

	for _, repairSkill in ipairs(ReplaceRepair.repairSkills) do
		if repairSkill:isActive(pawn) then
			return repairSkill
		end
	end
end

modApi:addModsInitializedHook(onModsInitialized)

if ReplaceRepair == nil or not modApi:isVersion(VERSION, ReplaceRepair.version) then
	ReplaceRepair = ReplaceRepair or {}
	ReplaceRepair.version = VERSION
	ReplaceRepair.queued = ReplaceRepair.queued or {}

	function ReplaceRepair:getVersion()
		return self.version
	end

	function ReplaceRepair:addSkill(repairSkill)
		Assert.ModInitializingOrLoading()
		Assert.Equals('table', type(repairSkill), "Argument #1")

		repairSkill.modId = modApi.currentMod
		table.insert(self.queued, repairSkill)
	end

	function ReplaceRepair:finalizeInit()
		self.addSkill = addSkill
		self.getCurrentSkill = getCurrentSkill

		require(path.."defaults")
		require(path.."ui")
		require(path.."alter")

		self.repairSkills = {}

		for _, repairSkill in ipairs(self.queued) do
			self:addSkill(repairSkill)
		end

		self.queued = nil

		table.sort(self.repairSkills, function(a,b)
			-- sort table, such that: custom skill > pilot skills > mech skills
			return a.priority > b.priority
		end)
	end

	require(path.."compatibility")
end

return ReplaceRepair
