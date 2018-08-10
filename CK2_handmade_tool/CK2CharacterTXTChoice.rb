class CK2CharacterTXTChoice
  attr_accessor :when_processing, :index
  attr_reader :line

  def initialize(line)
    @line = line
  end

  def output_value
    @when_processing.call(self)
  end
end

SEPARATION_CHARACTER_ANY_ID = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.slice(/\d+/).to_i
end

SEPARATION_CHARACTER_ID = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.slice(/\d+/).to_i
end

SEPARATION_CHARACTER_DATE = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.slice(/^\d+\.\d+\.\d+/)
end

SEPARATION_CHARACTER_NAME = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.encode('UTF-8').sub(/name\s*=\s*/, '').slice(/(\w|\-|\s|['¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+/)
end

SEPARATION_CHARACTER_DYNASTY_ID = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.slice(/\d+/).to_i
end

SEPARATION_CHARACTER_FATHER_ID = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.slice(/\d+/).to_i
end

SEPARATION_CHARACTER_FEMALE = lambda do | context |
  #pp "Input Line: #{context.line}"
  return 'TRUE'
end

SEPARATION_CHARACTER_RANDOM_TRAITS = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.sub(/random_traits=/, '').slice(/([a-z]|-|[A-Z])+/)
end

SEPARATION_CHARACTER_SET_REAL_FATHER_ID = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.sub(/^\s*effect\s*=\s*\{\s*c_/, '').slice(/^\d+/)
end

SEPARATION_CHARACTER_RELIGION = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.sub(/religion=/, '').slice(/([a-z]|-|[A-Z])+/)
end

SEPARATION_CHARACTER_CULTURE = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.sub(/culture=/, '').slice(/([a-z]|-|_|[A-Z])+/)
end

SEPARATION_CHARACTER_DNA = lambda do | context |
  #pp "Input Line: #{context.line}"
  return context.line.sub(/dna=/, '').slice(/\w+/)
end

SEPARATION_CHARACTER_PROPERTIES = lambda do | context |
  pp "Input Line: #{context.line}"
  return context.line.sub(/properties=/, '').slice(/\w+/)
end