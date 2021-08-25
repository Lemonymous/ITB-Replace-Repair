
local path = GetParentPath(...)
local menu = require(path.."lib/menu")
local selected = require(path.."lib/selected")
local getSelectedPawn = selected.getSelectedPawn
local escMenuIsClosed = menu.isClosed

local vanillaRepairIcon = sdlext.getSurface{ path = "img/weapons/repair.png" }
local vanillaRepairFrozenIcon = sdlext.getSurface{ path = "img/weapons/repair_frozen.png" }
local smokeIcon = sdlext.getSurface{ path = "img/combat/icons/icon_smoke.png", scale = 2 }
local waterIcon = sdlext.getSurface{ path = "img/combat/icons/icon_water.png", scale = 2 }
local acidIcon = sdlext.getSurface{ path = "img/combat/icons/icon_acid_water.png", scale = 2 }
local lavaIcon = sdlext.getSurface{ path = "img/combat/icons/icon_lava.png", scale = 2 }

local COLOR_BLACK_140 = sdl.rgba(0, 0, 0, 140)
local COLOR_BLACK_220 = sdl.rgba(0, 0, 0, 220)
local rect_mask_R = sdl.rect(0, 0, 15, 15)

local function getSelectedOrHighlightedPawn()
	if Board == nil then
		return nil
	end

	local highlighted = Board:GetHighlighted() or Point(-1, -1)
	local pawn = getSelectedPawn() or Board:GetPawn(highlighted)

	return pawn
end

local function getTerrainOverlayIcon(pawn)
	if pawn == nil then
		return nil
	end

	local loc = pawn:GetSpace()
	local isFlying = pawn:IsFlying()

	if Board:IsTerrain(loc, TERRAIN_LAVA) and not isFlying then
		return lavaIcon

	elseif Board:GetTerrain(loc) == TERRAIN_WATER and not isFlying then
		return Board:IsAcid(loc) and acidIcon or waterIcon

	elseif Board:IsSmoke(loc) and not pawn:IsAbility("Disable_Immunity") then
		return smokeIcon
	end
end

local function drawSurfaceCentered(self, screen, widget)
	if self.surface == nil then return end

	widget.decorationx = math.ceil(widget.rect.w / 2 - self.surface:w() / 2)
	widget.decorationy = 0

	DecoSurface.draw(self, screen, widget)

	widget.decorationx = 0
	widget.decorationy = 0
end

local function fadeToBlack(anim, widget, percent)
	widget.decoMenuMask.color = InterpolateColor(
		deco.colors.transparent,
		COLOR_BLACK_220,
		percent
	)
end

local function drawWhileEscMenu(self, screen, widget)
	local anim = widget.animations.fade
	if escMenuIsClosed() then
		anim:stop()
		self.color = deco.colors.transparent
	elseif anim:isStopped() then
		anim:start()
	end

	DecoSolid.draw(self, screen, widget)
end

local function createUi(screen, uiRoot)
	local ui = Ui()
		:widthpx(34):heightpx(80)
		:addTo(uiRoot)

	ui.translucent = true
	ui.ignoreMouse = true
	ui.clipped = true
	ui.decoRepairIcon = DecoSurface()
	ui.decoInactiveMask = DecoSolid()
	ui.decoMenuMask = DecoSolid(deco.colors.transparent)
	ui.decoTerrainMask = DecoSolid()
	ui.decoTerrainIcon = DecoSurface()
	ui.animations.fade = UiAnim(ui, 100, fadeToBlack)

	ui.decoRepairIcon.draw = drawSurfaceCentered
	ui.decoTerrainIcon.draw = drawSurfaceCentered
	ui.decoMenuMask.draw = drawWhileEscMenu

	function ui.animations.fade:isDone()
		return false
	end

	ui:decorate{
		ui.decoRepairIcon,
		ui.decoInactiveMask,
		ui.decoTerrainMask,
		ui.decoTerrainIcon,
		ui.decoMenuMask
	}

	function ui:relayout()
		self.visible = false

		local screen = sdl.screen()
		local xOffset
		local drawnVanillaIcon
		local customRepairIcon
		local skill = ReplaceRepair:getCurrentSkill()
		local pawn = getSelectedOrHighlightedPawn()

		if pawn == nil or skill == nil then
			return
		end

		if screen:w() >= 1280 then
			self.w = 34
			xOffset = -1
		else
			self.w = 59
			xOffset = -13
		end

		if vanillaRepairIcon:wasDrawn() then
			drawnVanillaIcon = vanillaRepairIcon
			customRepairIcon = skill.surface

		elseif vanillaRepairFrozenIcon:wasDrawn() then
			drawnVanillaIcon = vanillaRepairFrozenIcon
			customRepairIcon = skill.surface_frozen or skill.surface
		end

		if customRepairIcon then
			self.x = drawnVanillaIcon.x + xOffset
			self.y = drawnVanillaIcon.y
			self.screenx = self.x
			self.screeny = self.y
			self.rect.x = self.screenx
			self.rect.y = self.screeny
			self.rect.w = self.w
			self.rect.h = self.h

			self.visible = true
			self.decoRepairIcon.surface = customRepairIcon
			self.decoTerrainIcon.surface = getTerrainOverlayIcon(pawn)

			if self.decoTerrainIcon.surface == nil then
				self.decoTerrainMask.color = deco.colors.transparent
			else
				self.decoTerrainMask.color = COLOR_BLACK_140
			end

			if pawn:IsActive() then
				self.decoInactiveMask.color = deco.colors.transparent
			else
				self.decoInactiveMask.color = COLOR_BLACK_140
			end
		end

		Ui.relayout(self)
	end

	function ui:draw(screen)
		local maskCount = 0
		local pawn = getSelectedOrHighlightedPawn()

		if sdlext.CurrentWindowRect then
			screen:mask(sdlext.CurrentWindowRect)
			maskCount = maskCount + 1
		end

		if pawn and pawn:IsActive() then
			rect_mask_R.x = self.rect.x + self.rect.w - rect_mask_R.w
			rect_mask_R.y = self.rect.y + self.rect.h - rect_mask_R.h
			screen:mask(rect_mask_R)
			maskCount = maskCount + 1
		end

		Ui.draw(self, screen)
		screen:unmask(maskCount)
	end
end

modApi.events.onUiRootCreated:subscribe(createUi)
