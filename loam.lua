_addon.name     = 'LOAM'
_addon.author   = 'Bee'
_addon.description = 'Low Overhead Associative Magic'
_addon.version  = '1.0'
_addon.commands = {'loam', 'lo'}

res = require('resources')
config = require('config')
require('metadata')

local defaults = {
    nindrk = {'Stun', 'Aspir', 'Bind', 'Sleep'},
    ninrdm = {'Dispel', 'Sleep', 'Blind', 'Bind'},
    rdmnin = {'Sleep', 'Sleep II', 'Bind', 'Dispel', 'Blind'},
    ninjutsu = {'Hyoton', 'Huton', 'Suiton', 'Doton', 'Raiton', 'Katon'}
}
settings_path = 'data\\settings.xml'
sequences = config.load(settings_path, defaults)

local function message(message_text)
	windower.add_to_chat(CHAT_COLOR,'[' .. _addon.name .. '] ' .. message_text)
end

local function count_item(target_item_id, bag_cache)
    if(not bag_cache) then
        bag_cache = windower.ffxi.get_items(0)
    end
    local target_item_count = 0
    for _,item in pairs(bag_cache) do
        if type(item) == 'table' and item.status == 0 and (item.id == target_item_id) then
            target_item_count = target_item_count + item.count
        end
    end
    return target_item_count
end

function get_sequence(sequence_name)
    if(sequences[sequence_name]) then
        return sequences[sequence_name]
    else
        return nil
    end
end

function cast_sequence(sequence_name)
    local sequence = get_sequence(sequence_name)
    if(not sequence) then
        message('Sequence \"' .. sequence_name .. '\" not recognized!')
    end
    local minimum_recast = nil
    local minimum_recast_spell = nil
    for _,spell_name in ipairs(sequence) do
        local recast = windower.ffxi.get_spell_recasts()[res.spells:with('name',spell_name)['id']]/60.0
        if(recast == 0) then
            windower.send_command('input /ma \"' .. spell_name .. '\" <t>')
            return
        end
        if(not minimum_recast) or recast < minimum_recast then
            minimum_recast = recast
            minimum_recast_spell = spell_name
        end
    end
    minimum_recast = math.floor(minimum_recast*10)/10
    windower.send_command('input /echo None in sequence off CD! (next is ' .. minimum_recast_spell .. ' in ' .. minimum_recast .. ' sec!)')
end

function elemental_wheel(tier)
	--send_command('input /echo Using wheel!')
	if(tier == 'ni') then
		tier = 'Ni'
	elseif(tier == 'ichi') then
		tier = 'Ichi'
    elseif(tier == 'both') then
        tier = 'Both'
	elseif(tier ~= 'Ichi' and tier ~= 'Ni' and tier ~= 'Both') then
		windower.send_command('input /echo WARNING: Tier \"' .. tier .. '\" not recognized!')
		return
	end
	local minimum_recast = nil
	local minimum_recast_spell = nil
    local bag = windower.ffxi.get_items()['inventory']
    local ninjutsu_sequence = get_sequence('ninjutsu')
    local sequence = get_sequence("ninjutsu")
    if(not sequence) then
        message('Sequence \"ninjutsu\" not recognized!')
    end

    local spell_names = {}
    for i,spell_prefix in ipairs(ninjutsu_sequence) do
        if(tier == 'Ni' or tier == 'Ichi') then
            table.insert(spell_names, spell_prefix .. ': ' .. tier)
        else
            spell_names[i] = spell_prefix .. ': Ni'
            spell_names[i+6] = spell_prefix .. ': Ichi'
        end
    end

	for _,spell_name in ipairs(spell_names) do
		local recast = windower.ffxi.get_spell_recasts()[ninjutsu_metadata[spell_name]['id']]/60.0
		local tools_remaining = count_item(ninjutsu_metadata[spell_name]['item_id'], bag)
		if(recast == 0 and tools_remaining > 0) then
			windower.send_command('input /ma \"' .. spell_name .. '\" <t>')
            return
		end
		if(not minimum_recast) or recast < minimum_recast then
			minimum_recast = recast
			minimum_recast_spell = spell_name
		end
	end
	minimum_recast = math.floor(minimum_recast*10)/10
	windower.send_command('input /echo No Elemental ' .. tier .. ' spells off CD! (next is ' .. minimum_recast_spell .. ' in ' .. minimum_recast .. ' sec!)')
end


handlers = {}
handlers['wheel'] = elemental_wheel
handlers['sequence'] = cast_sequence

local function handle_command(cmd, ...)
    local cmd = cmd or 'help'
    if handlers[cmd] then
        local msg = handlers[cmd](unpack({...}))
        if msg then
            error(msg)
        end
    else
        error("Unknown command %s":format(cmd))
    end
end

windower.register_event('addon command', handle_command)
