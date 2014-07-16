
local function accumulator(n)
  local total = 0
  return function (mana)
    total = total + mana.amount
    if total >= n then
      total = 0
      return { amount = 10 }
    end
  end
end

return {
  {
    action = accumulator(10)
  },
  {
    action = function (mana)
      print(mana.amount)
    end
  }
}