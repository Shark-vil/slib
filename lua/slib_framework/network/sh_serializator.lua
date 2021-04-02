local ValueSerialize = {
   [TYPE_TABLE] = function(datatable, t, v)
      local getdatatable = snet.Serialize(v, true)
      if getdatatable and #getdatatable ~= 0 then
         table.insert(datatable, { t, getdatatable })
      end
   end,
   [TYPE_NUMBER] = function(datatable, t, v)
      table.insert(datatable, { t, v })
   end,
   [TYPE_STRING] = function(datatable, t, v)
      table.insert(datatable, { t, v })
   end,
   [TYPE_BOOL] = function(datatable, t, v)
      table.insert(datatable, { t, v })
   end,
   [TYPE_ENTITY] = function(datatable, t, v)
      if not v or not IsValid(v) then return end

      local index = v:EntIndex()
      if index == -1 then return end

      table.insert(datatable, { t, index })
   end,
   [TYPE_VECTOR] = function(datatable, t, v)
      table.insert(datatable, { t, v:ToTable() })
   end,
   [TYPE_ANGLE] = function(datatable, t, v)
      table.insert(datatable, { t, v:ToTable() })
   end,
   [TYPE_MATRIX] = function(datatable, t, v)
      table.insert(datatable, { t, v:ToTable() })
   end,
}

function snet.Serialize(data, notcompress)
   local datatable = {}

   if not istable(data) then return datatable end
	if data._snet_disable then return datatable end
	if data._snet_getdata and isfunction(data._snet_getdata) then return data:_snet_getdata() end

   for i = 1, #data do
      local value = data[i]
      local t = TypeID(value)
		local converter = ValueSerialize[t]
      if converter then converter(datatable, t, value) end
	end

   local notcompress = notcompress or false

   if not notcompress then
      return util.Compress(util.TableToJSON(datatable))
   else
      return datatable
   end
end

local ValueDeserialize = {
   [TYPE_TABLE] = function(datatable, v)
      local getdatatable = snet.Deserialize(v)
      if getdatatable and #getdatatable ~= 0 then
         table.insert(datatable, getdatatable)
      end
   end,
   [TYPE_NUMBER] = function(datatable, v)
      table.insert(datatable, v)
   end,
   [TYPE_STRING] = function(datatable, v)
      table.insert(datatable, v)
   end,
   [TYPE_BOOL] = function(datatable, v)
      table.insert(datatable, v)
   end,
   [TYPE_ENTITY] = function(datatable, v)
      table.insert(datatable, Entity(v))
   end,
   [TYPE_VECTOR] = function(datatable, v)
      table.insert(datatable, Vector(v[1], v[2], v[3]))
   end,
   [TYPE_ANGLE] = function(datatable, v)
      table.insert(datatable, Angle(v[1], v[2], v[3]))
   end,
   [TYPE_MATRIX] = function(datatable, v)
      table.insert(datatable, Matrix(v))
   end,
}

function snet.Deserialize(json_datatable)
   local datatable = {}
   local t_type = type(json_datatable) 
   local getdatatable

   if t_type == 'string' then
      getdatatable = util.JSONToTable(util.Decompress(json_datatable))
   elseif t_type == 'table' then
      getdatatable = json_datatable
   else
      return datatable
   end

   for i = 1, #getdatatable do
      local data = getdatatable[i]
      local deconverter = ValueDeserialize[data[1]]
      if deconverter then deconverter(datatable, data[2]) end
   end

   return datatable
end