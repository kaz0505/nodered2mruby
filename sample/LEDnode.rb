#
# by nodered2mruby code generator
#
injects = [{:id=>:n_86fe4264777a905d,
  :delay=>0.1,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_c3f20f4657692edb]}]
nodes = [{:id=>:n_c3f20f4657692edb, :type=>:gpio, :targetPort=>0, :wires=>[]}]
function_ruby = nil

# global variable
$gpioArray = {}
$pwmArray = {}
$pinstatus = {}
$i2cArray = {}

# Myindex class
#=begin
class Myindex
  def myindex(nodes, msg)
    i = 0

    while i < nodes.length
      if nodes[i][:id] == msg[:id]
        return i
      else
        i += 1
      end
    end
    return nil
  end
end

# GPIO Class
=begin
class GPIO
  attr_accessor :pinNum

  def initialize(pinNum)
    @pinNum = pinNum
  end

  def write(value)
    puts "Writing #{value} to GPIO #{@pinNum}"
  end
end
=end

# function-ruby Class
=begin
class DynamicFunctionCreator
  def initialize
    @functions = Module.new
    extend @functions
  end

  # 蜍慕噪縺ｫ髢｢謨ｰ繧剃ｽ懈・
  def create_function(id, code, args = [])
    @functions.module_eval do
      define_method(id) do |*received_args|
        # 蠑墓焚繧偵Ο繝ｼ繧ｫ繝ｫ螟画焚縺ｨ縺励※險ｭ螳・
        args.each_with_index do |arg_name, index|
          instance_variable_set("@#{arg_name}", received_args[index])
        end

        # 貂｡縺輔ｌ縺溘さ繝ｼ繝峨ｒ隧穂ｾ｡
        instance_eval(code)
      end
    end
  end

  # 菴懈・縺励◆髢｢謨ｰ繧貞他縺ｳ蜃ｺ縺・
  def call_function(id, *args)
    if respond_to?(id)
      send(id, *args)
    else
      raise "Function with id :#{id} not found."
    end
  end
end
=end
class DynamicFunctionCreator
  def initialize
    @functions = Module.new
    extend @functions
  end

  # 蜍慕噪縺ｫ髢｢謨ｰ繧剃ｽ懈・
  def create_function(id, proc_object, args = [])
    @functions.module_eval do
      define_method(id) do |*received_args|
        # 蠑墓焚繧偵う繝ｳ繧ｹ繧ｿ繝ｳ繧ｹ螟画焚縺ｨ縺励※險ｭ螳・
        args.each_with_index do |arg_name, index|
          instance_variable_set("@#{arg_name}", received_args[index])
        end

        # 貂｡縺輔ｌ縺蘖roc繧貞他縺ｳ蜃ｺ縺・
        instance_exec(*received_args, &proc_object)
      end
    end
  end

  # 菴懈・縺励◆髢｢謨ｰ繧貞他縺ｳ蜃ｺ縺・
  def call_function(id, *args)
    if respond_to?(id)
      send(id, *args)
    else
      raise "Function with id :#{id} not found."
    end
  end
end

#
# node dependent implementation
#

# GPIO
def process_node_gpio(node, msg)
  puts "Do LED : #{node}"
  puts "msg = #{msg}"
  targetPort = node[:targetPort]
  payLoad = msg[:payload]
  sleepTime = msg[:repeat]
  puts "sleep = #{sleepTime}"

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    gpioValue = 0
    $pinstatus[targetPort] = 0
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{gpio}"
  end

  puts "Current pin state before payload check, gpioValue: #{gpioValue}"

  if payLoad != ""
    if payLoad == 0
      gpio.write(0)
      puts "Setting gpioValue to 0"
    elsif payLoad == 1
      gpio.write(1)
      puts "Setting gpioValue to 1"
    end
  else
    if gpioValue == 0
      gpio.write(1)
      $pinstatus[targetPort] = 1
      puts "Setting gpioValue to 1"
    elsif gpioValue == 1
      gpio.write(0)
      $pinstatus[targetPort] = 0
      puts "Setting gpioValue to 0"
    end
  end
end

# GPIO-Read
def process_node_gpioread(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPortDigital]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{gpio}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{gpio}"
  end

  if gpio.nil?
    puts "No GPIO configured for pin #{gpio}"
  else
    gpioReadValue = gpio.read()
    puts "gpioReadVale = #{gpioReadValue}"

    node[:wires].each do |nextNodeId|
      msg = { id: nextNodeId, payload: gpioReadValue }
      $queue << msg
    end
  end
end

# ADC
def process_node_ADC(node, msg)
  pinNum = node[:targetPort_ADC]

  targetPort = case pinNum
               when "0" then 0
               when "1" then 1
               when "2" then 5
               when "3" then 6
               when "4" then 7
               when "5" then 8
               when "6" then 19
               when "7" then 20
               else
                nil
               end

  if targetPort.nil?
    puts "No GPIO configured for pin"
  end

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  gpio.start
  adcValue = gpio.read_v
  gpio.stop

  if adcValue.nil?
    puts "No GPIO configured for pin #{targetPort}"
  else
    msg[:payload] = adcValue
    node[:wires].each do |nextNodeId|
      msg = { id: nextNodeId, payload: adcValue }
      $queue << msg
    end
  end
end

# GPIO-Write
def process_node_gpiowrite(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  targetPort = node[:targetPort_digital]
  payLoad = msg[:payload]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    gpioValue = nil
    $pinstatus[targetPort] = nil
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if payLoad != ""
    if gpioValue != payLoad
      gpio.write(1)
      $pinstatus[targetPort] = payLoad
    elsif gpioValue == payLoad
      gpio.write(0)
      $pinstatus[targetPort] = nil
    end
  else
    puts "The value of payload is not set."
  end
end

# PWM
def process_node_PWM(node, msg)
  pwmNum = node[:PWM_num]
  cycle = node[:cycle].to_i      #蜻ｨ豕｢謨ｰ
  rate = msg[:payload].to_i      #inject.payload縺ｧ險ｭ螳・
  pinstatus = {}

  targetPort =  case pwmNum
                when "1" then 12
                when "2" then 16
                when "3" then nil
                when "4" then 18
                when "5" then 2
                else
                 nil
                end

  pwmChannel = pwmNum.to_i

  if $pwmArray[targetPort].nil?
    pwm = PWM.new(targetPort)
    $pwmArray[targetPort] = pwm
    puts "pwm start"
  else
    pwm = $pwmArray[targetPort]
    puts "pwm continue"
  end

  pwm.frequency(cycle)
  puts "cycle = #{cycle}"
  pwm.duty(rate)
  puts "rate = #{rate}"
end

# I2C
def process_node_I2C(node, msg)
  puts "Processing I2C for node: #{node[:id]}"

  slaveAddress = node[:ad].to_s
  rules = node[:rules]
  payLoad = msg[:payload]

  if $i2cArray[slaveAddress].nil?
    i2c = I2C.new(slaveAddress)
    $i2cArray[slaveAddress] = i2c
    puts "Setting up pinMode for pin #{i2c}"
  else
    i2c = $i2cArray[slaveAddress]
    puts "Reusing pinMode for pin #{i2c}"
  end

  rules.each do |rule|
    if rule[:t] == "W"
      puts "type W"
      i2c.write(slaveAddress, rule[:v], payLoad)
      puts "write 1"
    elsif rule[:t] == "R"
      puts "R"
      i2c.read(slaveAddress, rule[:b], rule[:v])
      puts "Read I2C(#{i2c})"
    end
  end
end

# Button
def process_node_Button(node, msg)
  puts "Button(Select Pull)"

  targetPort = node[:targetPort]
  selectPull = node[:selectPull]

  if $gpioArray[targetPort].nil?
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = gpio
    gpioValue = 0
    $pinstatus[targetPort] = 0
    puts "Setting up pinMode for pin #{targetPort}"
  else
    gpio = $gpioArray[targetPort]
    gpioValue = $pinstatus[targetPort]
    puts "Reusing pinMode for pin #{targetPort}"
  end

  if selectPull == "0"
    gpio.pull(0)
  elsif selectPull == "1"
    gpio.pull(1)
  elsif selectPull == "2"
    gpio.pull(-1)
  end
end

#Switch
def process_node_switch(node, msg)
  puts "node[:rules] = #{node[:rules]}"

  rules = node[:rules]
  payLoad = msg[:payload]
  puts "payLoad = #{payLoad}"


  rules.each_with_index do |rule, index|
    value = rule[:v]
    value2 = rule[:v2]
    switchCase = rule[:case]

    case rule[:vt]
    when "str"
      puts "stirng"
      value = rule[:v].to_s
    when "num"
      puts "num"
      value = if rule[:v].to_s.include?(".")
        rule[:v].to_f
      else
        rule[:v].to_i
      end
    end

    puts "value = #{value}, value.class = #{value.class}"

    case rule[:t]
    when  "eq"           # ==
      if payLoad == value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "neq"           # !=
      if payLoad != value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "lt"            # <
      if payLoad > value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "lte"           # <=
      if payLoad >= value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "gt"            # >
      if payLoad < value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "gte"           # >=
      if payLoad <= value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "hask"          # 繧ｭ繝ｼ繧貞性繧
      if payLoad.key?(value)
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "btwn"          # 遽・峇蜀・〒縺ゅｋ
      if payLoad >= value && payLoad <= value2
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "cont"          # 隕∫ｴ縺ｫ蜷ｫ繧
      if payLoad == true
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "regex"         # 豁｣隕剰｡ｨ迴ｾ縺ｫ繝槭ャ繝・
      if payLoad =~ value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "true"          # true縺ｧ縺ゅｋ
      if payLoad == true
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "false"         # false縺ｧ縺ゅｋ
      if payLoad == false
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "null"          # null縺ｧ縺ゅｋ
      if payLoad.nil?
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "nnull"         # null縺ｧ縺ｪ縺・
      if !payLoad.nil?
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "istype"        # 謖・ｮ壼梛
      if payLoad.class == value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "empty"         # 遨ｺ縺ｧ縺ゅｋ
      if payLoad.empty
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "nempty"        # 遨ｺ縺ｧ縺ｪ縺・
      if !payLoad.empty
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "head"          # 蜈磯ｭ隕∫ｴ縺ｧ縺ゅｋ
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad.first }
        puts "msg = #{msg}"
    when "index"         # index縺ｮ遽・峇蜀・〒縺ゅｋ
      if payLoad.size >= value.to_i && payLoad.size <= value2.to_i
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad, :repeat => msg[:repeat] }
        puts "msg = #{msg}"
      end
    when "tail"          # 譛ｫ蟆ｾ隕∫ｴ縺ｧ縺ゅｋ
      puts "nextNode = #{node[:wires][index]}, index = #{index}"
      msg = { id: node[:wires][index], payload: payLoad.last }
      puts "msg = #{msg}"
    when "jsonata_exp"   # JSONata蠑・
      if payLoad.class == value
        puts "nextNode = #{node[:wires][index]}, index = #{index}"
        msg = { id: node[:wires][index], payload: payLoad }
        puts "msg = #{msg}"
      end
    when "else"          # 縺昴・莉・
      msg = { id: node[:wires][index], payload: payLoad }
      puts "繝・ヵ繧ｩ繝ｫ繝・sg = #{msg}"
    else                 # 譚｡莉ｶ荳堺ｸ閾ｴ
      puts "The specified condition does not match : #{rule[:t]}"
    end
  end

  $queue << msg

end

#function-ruby
#def process_node_function_code(node, msg)
#  functionName = node[:id]
#  functionCode = node[:func]

#  geneFunction = <<~RUBY
#    def #{functionName}()
#    #{functionCode.lines.map { |line| "  #{line}" }.join}
#    end
#  RUBY

#    return geneFunction
#  else
#    raise "Invalid node type. Expected 'function-ruby'."
#  end

#  node[:wires].each do |nextNodeId|
#    msg = { id: nextNodeId, payload: result }
#    $queue << msg
#  end
#end


#
# inject
#
def process_inject(inject)
  inject[:wires].each { |node|
    msg = { :id => node, :payload => inject[:payload] }
    puts "msg = #{msg}"
    $queue << msg
  }
end

#
# node
#
def process_node(node,msg)
  case node[:type]
  when :debug
    puts "msg[:payload] = #{msg[:payload]}"
  when :switch
    process_node_switch node, msg
  #when :function_code
  #  process_node_function_code node, msg
  when :gpio
    process_node_gpio node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :ADC
    process_node_ADC node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
  when :pwm
    process_node_PWM node, msg
  when :i2c
    process_node_I2C node, msg
  when :button
    process_node_Button node, msg
  else
    puts "#{node[:type]} is not supported"
  end
end

=begin
injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject[:sleep] = inject[:delay]
  inject
}.sort_by { |inject| inject[:delay] }
=end

injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject
}

puts "injects #{injects}"

LoopInterval = 0.05
DelayInterval = 0.05

$queue = []

#process node
while true do
  injects.each_index { |idx|
    injects[idx][:cnt] -= LoopInterval
    if injects[idx][:cnt] <= 0 then
      injects[idx][:cnt] = injects[idx][:repeat]
      process_inject injects[idx]
      puts "Do inject #{idx}"
    end
  }

  # process queue
  indexer = Myindex.new()
  msg = $queue.first
  if msg then
    puts "$queue = #{$queue}"
    $queue.delete_at 0
    puts "$queue = #{$queue}"
    #idx = nodes.myindex { |v| v[:id] == msg[:id] }
    idx = indexer.myindex(nodes, msg)
    puts "node is #{nodes[idx]}"
    if idx then
      process_node nodes[idx], msg
      puts "-----------------------------------------------------------------------------------------"
    else
      puts "node not found: #{msg[:id]}"
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
