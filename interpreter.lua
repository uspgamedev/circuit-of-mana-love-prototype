
local interpreter = {}

function interpreter.cast (circuit, nodes)
  for i,layer in ipairs(circuit.layers) do
    for j,slot in ipairs(layer) do
      slot.manas = {}
    end
  end
  for i,layer in ipairs(circuit.layers) do
    for j,slot in ipairs(layer) do
      if slot.type and slot.to then
        local to_i, to_j = unpack(slot.to)
        if to_i > i then
          local node = nodes[slot.type]
          table.insert(circuit.layers[to_i][to_j].manas, node.action(unpack(slot.manas)))
        end
      end
    end
  end
end

return interpreter
