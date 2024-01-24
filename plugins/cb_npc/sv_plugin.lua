local PLUGIN = PLUGIN
local meta = FindMetaTable("Player")
local apiKey = "sk-************************************************" -- Your OpenAI API key here

meta.sendGPTRequest = function(this, text)
    HTTP({
        url = 'https://chat.geekgpt.org/',
        type = 'application/json',
        method = 'post',
        headers = {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = 'Bearer ' .. apiKey,
        },
        body = [[{
            "model": "gpt-3.5-turbo",
            "messages": [{"role": "user", "content": "]] .. text .. [["}],
            "max_tokens": 50,
            "temperature": 0.7
        }]],
        success = function(code, body, headers)
            local response = util.JSONToTable(body)
            
            if response and response.choices and response.choices[1] and response.choices[1].message and response.choices[1].message.content then
                local gptResponse = response.choices[1].message.content
                this:ChatPrint("[GPT]: "..gptResponse)
            else
                this:ChatPrint((response and response.error and response.error.message) and "Error! "..response.error.message or 'Unknown error!')
            end
        end,
        failed = function(err)
            ErrorNoHalt('HTTP Error: '..err)
        end
    })
end

hook.Add("PlayerSay", "PlayerChatHandler", function(ply, text, team)
    local cmd = string.sub(text,1,4)
    local txt = string.sub(text,5)
    if cmd == "/gpt" then
        ply:ChatPrint("One moment, please...")
        ply:sendGPTRequest(txt)
        return ""
    end
end)

function PLUGIN:OnNPCKilled(ent, ply)
    local config = self.config[ent:GetClass()]

    if not ( config and config.items ) then
        return
    end

    local randomChance = math.random(1, 100)
    if not ( randomChance >= config.rarity ) then
        return
    end

    if ( config.randomItems ) then
        ix.item.Spawn(table.Random(config.items), ent:GetPos() + Vector(0, 0, 16), nil, ent:GetAngles())
    else
        for k, v in pairs(config.items) do
            ix.item.Spawn(v, ent:GetPos() + Vector(0, 0, 16), nil, ent:GetAngles())
        end
    end
end