class CK2DynastyTXTChoice
  attr_accessor :when_processing, :index
  attr_reader :line

  def initialize(line)
    @line = line
  end

  def output_line
    @when_processing.call(self)
  end
end

SEPARATION_DYNASTY_ID = lambda do | context |
    #pp "Input Line: #{context.line}"
    context.index = 0
    return  context.line.slice(/^\d+/)
end

SEPARATION_DYNASTY_NAME = lambda do | context |
  return context.line.encode('UTF-8').match(/^\s*name\s*=\s*\"*(([a-z]|\-|[A-Z]|\s|['Š¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+)\"*/).to_a[1]
end

SEPARATION_DYNASTY_CULTURE = lambda do | context |
  return context.line.match(/^culture\s*=\s*"*([\w-]+)"*/).to_a[1]
end

SEPARATION_DYNASTY_RANDOM = lambda do | context |
  return 'FALSE'
end