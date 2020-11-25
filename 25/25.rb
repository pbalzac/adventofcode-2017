class Machine
  attr_accessor :start
  attr_accessor :steps
end

class Case
  attr_accessor :from_value
  attr_accessor :write_value
  attr_accessor :move_direction
  attr_accessor :next_state

  def initialize(from_value)
    @from_value = from_value
  end
end

class State
  attr_accessor :state
  attr_accessor :case_0
  attr_accessor :case_1

  def initialize(state, case_0, case_1)
    @state = state
    @case_0 = case_0
    @case_1 = case_1
  end
end

$states = Hash.new
$memory = Hash.new { |h, k| h[k] = 0 }
$machine = Machine.new

def run(f)
  state = case_0 = case_1 = current_case = nil

  File.readlines(f).each do |line|
    line.strip!
    case line
    when /Begin in state ([A-Z])\./
      $machine.start = $1.to_sym
    when /Perform a diagnostic checksum after (\d+) steps\./
      $machine.steps = $1.to_i
    when /In state ([A-Z]):/
      if !state.nil?
        $states[state] = State.new(state, case_0, case_1)
      end
      state = $1.to_sym
      case_0 = Case.new(0)
      case_1 = Case.new(1)
    when /If the current value is (\d):/
      v = $1.to_i
      current_case = (v == 0) ? case_0 : case_1
    when /- Write the value (\d)\./
      current_case.write_value = $1.to_i
    when /- Move one slot to the (\w+)\./
      current_case.move_direction = $1.to_sym
    when /- Continue with state ([A-Z])\./
      current_case.next_state = $1.to_sym
    end
  end

  $states[state] = State.new(state, case_0, case_1)
end

def execute
  current_state = $machine.start
  cursor = 0
  $machine.steps.times do
    instruction = $memory[cursor] == 0 ? $states[current_state].case_0 : $states[current_state].case_1

    $memory[cursor] = instruction.write_value
    cursor += (instruction.move_direction == :left) ? -1 : 1
    current_state = instruction.next_state
  end
end

def checksum
  $memory.values.reduce(:+)
end
