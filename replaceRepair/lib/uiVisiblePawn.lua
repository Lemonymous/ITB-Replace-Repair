
local function uiVisiblePawn()
	if not Board then return end

	local highlighted = Board:GetHighlighted()
	local selected = Board:GetSelectedPawn()

	return selected or Board:GetPawn(highlighted)
end

return uiVisiblePawn
