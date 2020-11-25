$pc = 0
$registers = {
  :a => 0, :b => 0, :c => 0, :d => 0,
  :e => 0, :f => 0, :g => 0, :h => 0
}
$memory = []

class Instruction
  attr_accessor :opcode
  attr_accessor :r1
  attr_accessor :v1
  attr_accessor :r2
  attr_accessor :v2

  def initialize(opcode, r1: nil, v1: nil, r2: nil, v2: nil)
    @opcode = opcode
    @r1 = r1
    @v1 = v1
    @r2 = r2
    @v2 = v2
  end

  def op1
    @v1.nil? ? $registers[@r1] : @v1
  end

  def op2
    @v2.nil? ? $registers[@r2] : @v2
  end

  def inspect
    "#{@opcode} #{r1 || v1} #{r2 || v2}"
  end

  def to_s
    inspect
  end
end

def execute(verbose = false)
  instruction = $memory[$pc]
  p instruction if verbose
  offset = 1
  case instruction.opcode
  when :set
    $registers[instruction.r1] = instruction.op2()
  when :jnz
    offset = instruction.op2() if !instruction.op1().zero?
  when :mul
    $registers[instruction.r1] *= instruction.op2()
  when :sub
    $registers[instruction.r1] -= instruction.op2()
  end
  $pc += offset
  p $registers if verbose
  if (instruction.opcode == :set || instruction.opcode == :sub) && instruction.r1 == :b
    p $registers[:b]
  end
  $pc < 0 || $pc >= $memory.length
end

def run_til_halt
  halted = false
  while !halted
    halted = execute
  end
  p $registers
end

def clear
  $registers.keys.each do |k|
    $registers[k] = 0
  end
  $pc = 0
  $memory = []
end

def run(f)
  File.readlines(f).each do |line|
    line.strip!
    o = line.match(/(?<opcode>\w+) ((?<r1>[a-h])|(?<v1>[+-]?\d+)) ((?<r2>[a-h])|(?<v2>[+-]?\d+))/)
    $memory << Instruction.new(o[:opcode].to_sym, r1: (o[:r1] ? o[:r1].to_sym : nil), v1: (o[:v1] ? o[:v1].to_i : nil),
                              r2: (o[:r2] ? o[:r2].to_sym : nil), v2: (o[:v2] ? o[:v2].to_i : nil))
  end
end
