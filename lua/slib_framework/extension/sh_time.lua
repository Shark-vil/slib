slib.deltaTime = slib.deltaTime or 0
slib.fixedDeltaTime = slib.fixedDeltaTime or 0

local SysTime = SysTime
local FrameTime = FrameTime
local start_delta_time = 0
local is_second_tick = false

hook.Add('Tick', 'Slib.Extension.Time.DeltaTime', function()
	slib.fixedDeltaTime = FrameTime()
end)

hook.Add('Tick', 'Slib.Extension.Time.DixedDeltaTime', function()
	if is_second_tick then
		slib.deltaTime = SysTime() - start_delta_time
	else
		start_delta_time = SysTime()
	end
	is_second_tick = not is_second_tick
end)