
# Clock constraints

create_clock -name "clk" -period 20.000ns [get_ports {clk}] -waveform {0.000 10.000}

