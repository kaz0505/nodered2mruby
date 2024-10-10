#
# by nodered2mruby code generator
#
injects = [{:id=>:n_8d654ae0b42fab98,
  :delay=>0.0,
  :repeat=>2.0,
  :payload=>"",
  :wires=>[:n_935a89a7869a387a, :n_1715ea0b47afd678]}]
nodes = [{:id=>:n_1715ea0b47afd678,
  :type=>:gpiowrite,
  :WriteType=>"digital_write",
  :targetPort_digital=>"0",
  :targetPort_mode=>"1",
  :targetPort_PWM=>"",
  :PWM_num=>"",
  :cycle=>"0",
  :double=>nil,
  :time=>"",
  :rate=>"",
  :wires=>[]}]

# global variable
$gpioNum = {}       #number of pin
gpioValue = 0       #value for gpio
$payLoad = 0        #value of payload in inject-node
$gpioArray[targetPort] = {:gpio => gpio, :value => gpioValue}

#
# node dependent implementation
#

#gpio-node
def process_node_gpio(node, msg)
  targetPort = node[:targetPort]
  $payLoad = msg[:payload]

  if $gpioArray[targetPort].nil? || !($gpioArray.key?(targetPort))
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = { gpio: gpio, value: 0}
    puts "Setting up pinMode for pin #{$gpioArray[targetPort][:gpio]}"
  else
    gpio = $gpioArray[targetPort][:gpio]
    puts "------------------------------------------------------------------------"
    puts "Reusing pinMode for pin #{$gpioArray[targetPort][:gpio]}"
    puts "$payLoad = #{$payLoad}, $gpioValue = #{$gpioArray[targetPort][:value]}"
  end


  if $payLoad == ""
    if $gpioArray[targetPort][:value] == 0
      $gpioArray[targetPort][:value] = 1
      puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
      puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
      gpio.write 1
    else
      $gpioArray[targetPort][:value] = 0
      puts "$gpioArray[targetPort][:gpio] = #{$gpioArray[targetPort][:gpio]}"
      puts "$gpioArray[targetPort][:value] = #{$gpioArray[targetPort][:value]}"
      gpio.write 0
    end
  else                                            # payload!=nil
    if $gpioArray[targetPort][:value] == 0
      gpio.write 1
      $gpioArray[targetPort][:value] = $payLoad
    elsif $gpioArray[targetPort][:value] == $payLoad
      gpio.write 0
      $gpioArray[targetPort][:value] = 0
    end
  end
end

def process_node_gpioread(node, msg)
  puts "Processing GPIO read for node: #{node[:id]}"
  gpioReadType = node[:readtype]
  targetPortDigital = node[:targetPortDigital]

  if gpioReadType == "digital_read"
    if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPortDigital))
      gpioReadPin = GPIO.new(targetPortDigital)
      $gpioArray[targetPort][:gpio] = gpioReadPin
    else
      gpioReadPin = $gpioArray[targetPort][:gpio]
    end

    gpioReadValue = digitalRead(targetPortDigital)

    if gpioReadValue.nil?
      msg[:payload] = gpioReadValue
      node[:wires].each do |nextNodeId|
      $queue << { id: nextNodeId, payload: gpioReadValue }
    else
      puts "No GPIO configured for pin #{targetPortDigital}"
    end

  if gpioReadType == "ADC"
    if $gpioArray.nil? || !($gpioArray[targetPort].key?(targetPortDigital))
      gpioReadPin = GPIO.new(targetPortDigital)
      $gpioArray[targetPort][:gpio] = gpioReadPin
    else
      gpioReadPin = $gpioArray[targetPort][:gpio]
    end

    gpioReadPin.start
    gpioReadValue = gpioReadPin.read_v
    gpioreadPin.stop

    if gpioReadValue.nil?
      msg[:payload] = gpioReadValue
      node[:wires].each do |nextNodeId|
      $queue << { id: nextNodeId, payload: gpioReadValue }
    else
      puts "No GPIO configured for pin #{targetPortDigital}"
    end
end


def process_node_gpiowrite(node, msg)
  puts "Processing GPIO write for node: #{node[:id]}"

  # ノードから書き込み対象のピンと値を取得
  targetPort = node[:targetPort]
  gpioWriteValue = msg[:payload]  # 書き込む値はmsgのpayloadから取得（通常は0か1）

  if $gpioArray[targetPort].nil? || !($gpioArray.key?(targetPort))
    # GPIOインスタンスを作成し、出力モードで初期化
    gpio = GPIO.new(targetPort)
    $gpioArray[targetPort] = { gpio: gpio, value: 0 }
    puts "Setting up GPIO for pin #{targetPort} as output"
  else
    # 既存のGPIOインスタンスを再利用
    gpio = $gpioArray[targetPort][:gpio]
    puts "Reusing existing GPIO for pin #{targetPort}"
  end

  # GPIOピンに値を書き込み
  if gpioWriteValue == 1
    gpio.write(1)
    puts "Writing HIGH to GPIO pin #{targetPort}"
  elsif gpioWriteValue == 0
    gpio.write(0)
    puts "Writing LOW to GPIO pin #{targetPort}"
  else
    puts "Invalid value for GPIO write: #{gpioWriteValue}. Expected 0 or 1."
  end

  # ハッシュに最新の書き込み状態を記録
  $gpioArray[targetPort][:value] = gpioWriteValue
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
#  when :debug
#    puts msg[:payload]
  when :gpio
    process_node_gpio node, msg
  when :gpioread
    process_node_gpioread node, msg
  when :gpiowrite
    process_node_gpiowrite node, msg
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
    if injects[idx][:cnt] == 0 then
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
