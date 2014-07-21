
local interpreter = {}

function interpreter.cast (circuit, nodes)
  if not spendMana(1) then return end
  for j,slot in ipairs(circuit.layers[1]) do
    table.insert(slot.manas, { type = 'substance:mana', amount = 1 })
  end
  for i,layer in ipairs(circuit.layers) do
    for j,slot in ipairs(layer) do
      if #slot.manas > 0 and slot.type and slot.to then
        local to_i, to_j = unpack(slot.to)
        if to_i > i then
          local node = nodes[slot.type]
          local result = node.action(unpack(slot.manas))
          if result then
            table.insert(circuit.layers[to_i][to_j].manas, result)
          end
        end
        slot.manas = {}
      end
    end
  end
  local result = {}
  for j,slot in ipairs(circuit.layers[#circuit.layers]) do
    if slot.manas and #slot.manas > 0 then
      table.insert(result, unpack(slot.manas))
    end
    slot.manas = {}
  end
  return result
end

return interpreter
