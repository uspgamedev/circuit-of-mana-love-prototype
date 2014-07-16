
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
          --print("("..i..","..j..") -> ("..to_i..","..to_j..")")
          --print "Input:"
          --for _,mana in ipairs(slot.manas) do
          --  table.foreach(mana, print)
          --end
          local node = nodes[slot.type]
          local result = node.action(unpack(slot.manas))
          --print "Output:"
          if result then
            table.foreach(result, print)
            table.insert(circuit.layers[to_i][to_j].manas, result)
          else
            --print "<Nothing>"
          end
        end
        slot.manas = {}
      end
    end
  end
end

return interpreter
