
local interpreter = {}

function interpreter.cast (circuit, nodes)
  for j,slot in ipairs(circuit.layers[1]) do
    table.insert(slot.manas, { amount = 1 })
  end
  for i,layer in ipairs(circuit.layers) do
    for j,slot in ipairs(layer) do
      if slot.type and slot.to then
        local to_i, to_j = unpack(slot.to)
        if to_i > i then
          local node = nodes[slot.type]
          table.insert(circuit.layers[to_i][to_j].manas, node.action(unpack(slot.manas)))
        end
        slot.manas = {}
      end
    end
  end
end

return interpreter
