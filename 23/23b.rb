$h = 0

(106700..106700 + 17000).step(17).each do |n|
  d = 2
  while (d * d) < n do
    if n % d == 0
      $h += 1
      break
    end
    d += 1
  end
end

p $h
