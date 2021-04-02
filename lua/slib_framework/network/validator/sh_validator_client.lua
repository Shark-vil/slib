local netowrk_name_to_client = slib.GetNetworkString('SNet', 'CL_ValidatorForClient')
local netowrk_name_to_server = slib.GetNetworkString('SNet', 'SV_ValidatorForClient')

if SERVER then
   local callback_data = {}

   function snet.IsValidForClient(ply, func_callback, validator_name, ...)
      validator_name = validator_name or 'entity'
      
      local uid = slib.GenerateUid(ply:UserID() .. validator_name)
      local func = func_callback

      callback_data[uid] = function(ply, result)
         timer.Remove('SNetClientValidatorTimeout_' .. uid)
         if func and isfunction(func) then
            func(ply, result)
         end
         callback_data[uid] = nil
      end

      timer.Create('SNetClientValidatorTimeout_' .. uid, 1.5, 1, function()
         local data_callback = callback_data[uid]
         if data_callback then data_callback(ply, false) end
      end)

      snet.Create(netowrk_name_to_client).SetData(uid, validator_name, ...).Invoke(ply)
   end

   net.Callback(netowrk_name_to_server, function(ply, uid, success)
      local data_callback = callback_data[uid]
      if data_callback then data_callback(ply, success) end
   end).Register()
else
   net.Callback(netowrk_name_to_client, function(ply, uid, validator_name, ...)
      local success = false
      local validator_method = snet.GetValidator(validator_name)
      if validator_method == nil then return end
      
      success = validator_method(ply, uid, ...)

      snet.Create(netowrk_name_to_server).SetData(uid, success).InvokeServer()
   end).Register()
end