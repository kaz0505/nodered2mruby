#
# by nodered2mruby code generator
#
injects = [{:id=>:n_89f6013edd93e829,
  :delay=>0.0,
  :repeat=>1.0,
  :payload=>"",
  :wires=>[:n_e5180ab46280d834]}]
nodes = [{:id=>:n_b4f9df93b0ed0ace,
  :type=>:gpio,
  :LEDtype=>"GPIO",
  :onBoardLED=>"6",
  :targetPort=>"0",
  :targetPort_mode=>"1",
  :wires=>[]},
 {:id=>:n_e5180ab46280d834,
  :type=>:constant,
  :C=>"1",
  :wires=>[:n_fb552db01c1edcc0]},
 {:id=>:n_fb552db01c1edcc0,
  :type=>:gpioread,
  :readtype=>"digital_read",
  :GPIOType=>"read",
  :digital=>"1",
  :ADC=>"",
  :wires=>[:n_6b28766a49ef9117]},
 {:id=>:n_6b28766a49ef9117,
  :type=>:switch,
  :payload=>nil,
  :property=>"payload",
  :propertyType=>"msg",
  :outputs=>1,
  :wires=>[:n_b4f9df93b0ed0ace]}]


