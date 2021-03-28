snet.storage.default = snet.storage.default or {}

function snet.GetNormalizeDataTable(data, entity_to_table)
	local data = data
	local entity_to_table = entity_to_table or false
	local new_data = {}

	if isentity(data) then data = data:GetTable() end
	if not istable(data) then return new_data end

	for k, v in pairs(data) do
		if isfunction(v) or isfunction(k) or v == nil or k == nil then goto skip end

		if istable(v) then
			new_data[k] = snet.GetNormalizeDataTable(v)
		elseif entity_to_table and isentity(v) then
			new_data[k] = snet.GetNormalizeDataTable(v:GetTable())
		else
			new_data[k] = v
		end

		::skip::
	end

	return new_data
end

function snet.execute(name, ply, ...)
	if CLIENT then ply = LocalPlayer() end

	if snet.storage.default[name] == nil then return end

	local data = snet.storage.default[name]

	if data.adminOnly then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			data.execute(ply, ...)
		end
	else
		data.execute(ply, ...)
	end

	if data.onRemove then
		net.RemoveCallback(name)
	end
end

local function network_callback(len, ply)
	local name = net.ReadString()
	local vars = net.ReadTable()

	snet.execute(name, ply, unpack(vars))
end

if SERVER then
	util.AddNetworkString('sv_network_rpc_callback')
	util.AddNetworkString('cl_network_rpc_callback')

	snet.Receive('sv_network_rpc_callback', network_callback)
else
	snet.Receive('cl_network_rpc_callback', network_callback)
end

snet.Invoke = function(name, ply, ...)
	if SERVER then
		if not IsValid(ply) or not ply:IsPlayer() then return end
		
		net.Start('cl_network_rpc_callback')
		net.WriteString(name)
		net.WriteTable(snet.GetNormalizeDataTable({ ... }))
		net.Send(ply)
	else
		net.Start('sv_network_rpc_callback')
		net.WriteString(name)
		net.WriteTable(snet.GetNormalizeDataTable({ ... }))
		net.SendToServer()
	end
end

snet.InvokeAll = function(name, ...)
	if SERVER then
		net.Start('cl_network_rpc_callback')
		net.WriteString(name)
		net.WriteTable(snet.GetNormalizeDataTable({ ... }))
		net.Broadcast()
	end
end

snet.RegisterCallback = function(name, func, onRemove, adminOnly)
	adminOnly = adminOnly or false
	onRemove = onRemove or false
	snet.storage.default[name] = {
		adminOnly = adminOnly,
		execute = func,
		onRemove = onRemove
	}
end

snet.RemoveCallback = function(name)
	snet.storage.default[name] = nil
end