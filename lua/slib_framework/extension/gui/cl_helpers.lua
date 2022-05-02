local sgui = slib.Components.GUI
local ScrW = ScrW
local ScrH = ScrH
local Material = Material
local Color = Color
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect
local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture
local spawnmenu_AddContentType = spawnmenu.AddContentType
--
local m_blur_material = Material('pp/blurscreen')
local m_blur_color = Color(255, 255, 255)
local m_blur_key = '$blur'

function sgui.DrawBlurBackground(panel, amount, passages)
	local x, y = panel:LocalToScreen(0, 0)
	local screen_width, screen_height = ScrW(), ScrH()

	amount = amount or 0

	surface_SetDrawColor(m_blur_color)
	surface_SetMaterial(m_blur_material)

	for i = 1, passages do
		m_blur_material:SetFloat(m_blur_key, (i / 3) * amount)
		m_blur_material:Recompute()

		render_UpdateScreenEffectTexture()
		surface_DrawTexturedRect(x * -1, y * -1, screen_width, screen_height)
	end
end

function spawnmenu.AddContentType(name, constructor)
	spawnmenu_AddContentType(name, function(container, obj)
		local new_icon = hook.Run('PreSlibSpawnmenuAddContentType', name, container, obj)
		if new_icon then return new_icon end

		local icon = constructor(container, obj)

		new_icon = hook.Run('PostSlibSpawnmenuAddContentType', name, icon, container, obj)
		if new_icon then return new_icon end

		return icon
	end)
end