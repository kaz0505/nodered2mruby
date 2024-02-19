#
# by nodered2mruby code generator
#
injects = [{:id=>:n_934017e3524b2bdd,
  :delay=>0.1,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_4ae12f0c5c520655]}]
nodes = [{:id=>:n_4ae12f0c5c520655,
  :type=>:gpio,
  :LEDtype=>"GPIO",
  :onBoardLED=>"",
  :targetPort=>"15",
  :targetPort_mode=>"0",
  :wires=>[]}]

#
# class GPIO
#
#=begin
class GPIO
  IN = "in"
  OUT = "out"

  def initialize(type = nil, pin = nil, onboardled = nil, direction = nil)
    @type = type
    @pin = pin
    @onboardled = onboardled
    @direction = direction
  end

  def write(value)
    if @type == "onBoardLED"
      puts "Writing #{value} to GPIO #{@onboardled}"
    elsif @type == "GPIO"
      puts "Writing #{value} to GPIO #{@pin} at #{@direction}"
    end
  end
end
#=end


#
# node dependent implementation
#

def process_node_gpio(node, msg)
  puts "node=#{node}"
    if node[:LEDtype] == "onBoardLED"
      puts "pin_num = #{node[:onBoardLED]}"
=begin
      led = GPIO.new(node[:onBoardLED].to_i)
      pinMode(node[:onBoardLED], 0)
      while true
        digitalWrite(node[:onBoardLED],1)
        sleep 1
        digitalWrite(node[:onBoardLED],0)
        sleep 0
      end
=end

# test GPIO ########################################################
      led = GPIO.new("onBoardLED", nil, node[:onBoardLED], nil)
      led.write 1
      sleep 1
      led.write 0
      sleep 0
      puts "LED Write"
####################################################################

    elsif node[:LEDtype] == "GPIO"
=begin
    # LED-chika
      pinMode(node[:targetPort], 0)
      while true
        digitalWrite(node[:targetPort],1)
        sleep(1)
        digitalWrite(node[:targetPort],0)
        sleep(0)
      end

      #led = GPIO.new(node[:targetPort].to_i, GPIO::OUT)
=end

# test GPIO ######################################################
      led = GPIO.new("GPIO", node[:targetPort], nil, GPIO::OUT)
      led.write 1
##################################################################
    end
end

def process_node_gpioread(node, msg)
  gpioread[:wires].each { |node|
  msg = {:id => node,
         :GPIOType => gpioread[:GPIOType],
         :digital => gpioread[:targetPort_digital],
         :ADC => gpioread[:targetPort_ADC]

        }
  $queue << msg

}
end

def process_node_gpiowrite(node, msg)
  gpiowrite[:wires].each { |node|
  msg = {:WriteType => gpiowrite[:WriteType],
        :GPIOType => gpiowrite[:GPIOType],
        :targetPort_digital => gpiowrite[:targetPort_digital],
        :targetPort_mode => gpiowrite[:targetPort_mode],
        :targetPort_PWM => gpiowrite[:targetPort_PWM],
        :PWM_num => gpiowrite[:PWM_num],
        :cycle => gpiowrite[:cycle],
        :double => gpiowrite[:doube],
        :time => gpiowrite[:time],
        :rate => gpiowrite[:rate]
        }
  $queue << msg
}
end

#
# inject
#
def process_inject(inject)
  inject[:wires].each { |node|
    msg = {:id => node, :payload => inject[:payload]}
    $queue << msg
  }
end

#
# node
#
def process_node(node,msg)
  case node[:type]
  when :debug
    puts msg[:payload]
  when :switch
    process_node_switch node, msg
  when :gpio
    process_node_gpio node, msg
  when :constant
    process_node_constant node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
  when :i2c
    process_node_i2c node, msg
  when :parameter
    process_node_parameter node, msg
  when :function_code
    process_node_function_code node, msg
  else
    puts "#{node[:type]} is not supported"
  end
end


injects = injects.map { |inject|
  inject[:cnt] = inject[:repeat]
  inject
}

LoopInterval = 0.05

$queue = []

#process node
while true do
  # process inject
  injects.each_index { |idx|
    injects[idx][:cnt] -= LoopInterval
    if injects[idx][:cnt] < 0 then
      injects[idx][:cnt] = injects[idx][:repeat]
      process_inject injects[idx]
    end
  }

  # process queue
  msg = $queue.first
  if msg then
    $queue.delete_at 0
    idx = nodes.index { |v| v[:id]==msg[:id] }
    if idx then
      process_node nodes[idx], msg
    end
  end

  # next
  # puts "q=#{$queue}"
  sleep LoopInterval
end
