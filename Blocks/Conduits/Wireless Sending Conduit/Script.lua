local Cables;

local WirelessUpdated = false;

local WirelessBuffer = nil;

local function UniIter(t)
	for _,_ in ipairs(t) do
		return ipairs(t);
	end
	return pairs(t);
end

local function GetWirelessConnectedConduits()
	if object.isOutputNodeConnected(0) == true then
		local Outputs = object.getOutputNodeIds(0);
		local Final = {};
		for i,_ in UniIter(Outputs) do
			if world.getObjectParameter(i,"conduitType") == "receiver" then
				Final[#Final + 1] = i;
			end
		end
		if #Final == 0 then
			return nil;
		end
		return Final;
	end
	return nil;
end

function init()
	Cables = CableCore;
	local OldGetConduits = GetConduits;
	GetConduits = function()
		local Final = {};
		local NearbyConduits = OldGetConduits();
		if WirelessUpdated == false then
			WirelessUpdated = true;
			WirelessBuffer = GetWirelessConnectedConduits();
		end
		local WirelessConduits = WirelessBuffer;
		for k,i in ipairs(NearbyConduits) do
			Final[#Final + 1] = i;
		end
		if WirelessConduits ~= nil then
			for k,i in ipairs(WirelessConduits) do
				Final[#Final + 1] = i;
			end
		end
		return Final;
	end
	Cables.AddCondition("Conduits","conduitType",function(value) return value ~= nil end);
	--Cables.Initialize();
end

local First = false;
function update(dt)
	if First == false then
		First = true;
		Cables.Initialize();
	end
end

function IsConnectedWirelesslyTo(ID)
	if WirelessUpdated == false then
		WirelessUpdated = true;
		WirelessBuffer = GetWirelessConnectedConduits();
	end
	if WirelessBuffer == nil then return false end;
	for _,i in ipairs(WirelessBuffer) do
		if i == ID then
			return true;
		end
	end
	return false;
end

function die()
	Cables.Uninitialize();
end

function onNodeConnectionChange(args)
	--sb.logInfo("Updated");
	Cables.UpdateExtractionConduits();
	WirelessBuffer = GetWirelessConnectedConduits();
end
