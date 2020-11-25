class Component
  attr_accessor :ports

  def initialize(port1, port2)
    @ports = [ port1, port2 ]
  end

  def fits?(n)
    @ports.include?(n)
  end

  def other(n)
    n == @ports[0] ? @ports[1] : @ports[0]
  end

  def length
    @ports.reduce(:+)
  end

  def inspect
    "#{@ports[0]}/#{@ports[1]}"
  end

  def to_s
    inspect
  end
end

def run(f)
  components = []
  File.readlines(f).each do |line|
    line.strip!
    p = line.match(/(\d+)\/(\d+)/)
    components << Component.new(p[1].to_i, p[2].to_i)
  end
  components
end


def bridges_from(port, components)
  bridges = []
  
  next_components = components.filter { |c| c.fits? port }
  next_components.each do |n|
    bridges << [n]

    other_port = n.other port
    next_bridges = bridges_from(other_port, components - [n])
    next_bridges.each do |next_bridge|
      bridges << [n] + next_bridge
    end
  end
  
  bridges
end

def strongest(bridges)
    (bridges.map { |b| b.map(&:length).reduce(:+) }).max
end

def longest(bridges)
  bridges.group_by(&:length).max.last
end

# components = run('input.txt')
# bridges = bridges_from(0, components)
# 1 strongest(bridges)
# 2 strongest(longest(bridges))
