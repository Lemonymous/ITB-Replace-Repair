
local nullfunction = function() end

lmn_replaceRepair = ReplaceRepair

ReplaceRepair.SetRepairSkill = ReplaceRepair.addSkill
ReplaceRepair.SetPilotRepairSkill = ReplaceRepair.addSkill
ReplaceRepair.SetMechRepairSkill = ReplaceRepair.addSkill
ReplaceRepair.getVersion = ReplaceRepair.getVersion
ReplaceRepair.GetHighestVersion = ReplaceRepair.getVersion
ReplaceRepair.mostRecent = ReplaceRepair
ReplaceRepair.init = nullfunction
ReplaceRepair.load = nullfunction
ReplaceRepair.internal_init = nullfunction

if replaceRepair_internal then
	replaceRepair_internal.RootGetTargetArea = SelfTarget.GetTargetArea
	replaceRepair_internal.OrigTipImage.Fire = Point(2,2)
end

function ReplaceRepair:ForPilot(sPilotSkill, sWeapon, sPilotTooltip, sIcon)
	Assert.ModInitializingOrLoading()

	self:SetRepairSkill{
		Name = sPilotTooltip[1],
		Description = sPilotTooltip[2],
		PilotSkill = sPilotSkill,
		Weapon = sWeapon,
		Icon = sIcon
	}
end

function ReplaceRepair:ForMech(sMech, sWeapon, sIcon)
	Assert.ModInitializingOrLoading()

	self:SetRepairSkill{
		MechType = sMech,
		Weapon = sWeapon,
		Icon = sIcon
	}
end
