Creator = {};
local Creator = Creator;

local MapConfig = root.assetJson(Argon.GetArgonDirectory() .. "Elements/Text/Maps.json");

local Maps = {};
for k,i in ipairs(MapConfig.Maps) do
	if string.match(i.Map,"^/") ~= nil then
		Maps[i.Name] = root.assetJson(i.Map).Map;
	else
		Maps[i.Name] = root.assetJson(Argon.GetArgonDirectory() .. i.Map).Map;
	end
end

function Creator.Create(CanvasName,Position,Font)
	if Font == nil then
		Font = Maps["Default"];
	else
		if Maps[Font] == nil then
			error(sb.print(Font) .. " is an invalid font name");
		end
		Font = Maps[Font];
	end
	local Element = CreateElement(CanvasName);
	Element.SetPosition(Position);
	local String = "";

	Element.AddControllerValue("GetString",function()
		return String;
	end);

	Element.AddControllerValue("SetString",function(value)
		if type(value) == "string" then
			String = value;
			Element.RemoveAllSprites();
			local StartPos = {0,0};
			local index = 1;
			for word in string.gmatch(String,".") do
				if word == " " then
					StartPos[1] = StartPos[1] + (Font.WidthOfSpace or Font.TextSize[1]);
				else
					local Image = Font.Image;
					--sb.logInfo("word = " .. sb.print(word));
					if string.match(Image,"^/") == nil then
						Image = Argon.GetArgonDirectory() .. Image;
					end
					if Font.BigCharacters[word] ~= nil then
						Element.AddSprite(index,{StartPos[1],StartPos[2],StartPos[1] + Font.TextSize[1],StartPos[2] + Font.TextSize[2]},Image,nil,nil,{Font.BigCharacters[word][1],Font.BigCharacters[word][2],Font.BigCharacters[word][1] + Font.TextSize[1],Font.BigCharacters[word][2] + Font.TextSize[2]});
						index = index + 1;
						StartPos[1] = StartPos[1] + Font.TextSize[1];
					elseif Font.SmallCharacters[word] ~= nil then
						Element.AddSprite(index,{StartPos[1],StartPos[2],StartPos[1] + Font.SmallSize[1],StartPos[2] + Font.SmallSize[2]},Image,nil,nil,{Font.SmallCharacters[word][1],Font.SmallCharacters[word][2],Font.SmallCharacters[word][1] + Font.SmallSize[1],Font.SmallCharacters[word][2] + Font.SmallSize[2]});
						index = index + 1;
						StartPos[1] = StartPos[1] + Font.SmallSize[1];
					end
				end
			end
		end
	end);
	return Element;
end