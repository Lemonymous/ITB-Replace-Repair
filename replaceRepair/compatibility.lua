
local nullfunction = function() end

lmn_replaceRepair = ReplaceRepair

ReplaceRepair.SetRepairSkill = ReplaceRepair.addSkill
ReplaceRepair.SetPilotRepairSkill = ReplaceRepair.addSkill
ReplaceRepair.SetMechRepairSkill = ReplaceRepair.addSkill
ReplaceRepair.GetVersion = ReplaceRepair.getVersion
ReplaceRepair.GetHighestVersion = ReplaceRepair.getVersion
ReplaceRepair.mostRecent = ReplaceRepair
ReplaceRepair.init = nullfunction
ReplaceRepair.load = nullfunction
ReplaceRepair.internal_init = nullfunction

if replaceRepair_internal == nil then
	replaceRepair_internal = {}
	setmetatable(replaceRepair_internal, { __index = ReplaceRepair })

	replaceRepair_internal.RootGetTargetArea = Skill_Repair.GetTargetArea
	replaceRepair_internal.RootGetSkillEffect = Skill_Repair.GetSkillEffect
	replaceRepair_internal.OrigGetTargetArea = Skill_Repair.GetTargetArea
	replaceRepair_internal.OrigGetSkillEffect = Skill_Repair.GetSkillEffect
	replaceRepair_internal.OrigTipImage = Skill_Repair.TipImage
	replaceRepair_internal.OrigName = Weapon_Texts.Skill_Repair_Name
	replaceRepair_internal.OrigDescription = Weapon_Texts.Skill_Repair_Description
end

function ReplaceRepair:ForPilot(sPilotSkill, sWeapon, sPilotTooltip, sIcon)
	Assert.ModInitializingOrLoading()

	self:SetRepairSkill{
		name = sPilotTooltip[1],
		description = sPilotTooltip[2],
		pilotSkill = sPilotSkill,
		weapon = sWeapon,
		icon = sIcon
	}
end

function ReplaceRepair:ForMech(sMech, sWeapon, sIcon)
	Assert.ModInitializingOrLoading()

	self:SetRepairSkill{
		mechType = sMech,
		weapon = sWeapon,
		icon = sIcon
	}
end
