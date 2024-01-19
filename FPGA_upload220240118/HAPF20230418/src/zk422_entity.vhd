----------------------------------------------------------------------------------
-- 版权(copyright): 
-- 项目名: 
-- 模块名: 
-- 文件名: 
-- 作者: 张凯
-- 功能和特点概述: 
-- 初始版本和发布时间: 1.00，2022-05-17
---------------------------------------------------
-- 更改历史:
---------------------------------------------------
-- 更改版本和更改时间： 
-- 更改人员: 无
-- 更改描述: 无
-- 更改版本和更改时间： 
-- 更改人员: 无
-- 更改描述: 无
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity zk422_entity is
port (
	reset            : in    std_logic;
	clk              : in    std_logic;

	rxd_i            : in    std_logic;
	txd_o            : out   std_logic;
	
	-- 系统状态回传
	sys_tx_flag_i    : in    std_logic;
	sys_tx_data01_i  : in    std_logic_vector(7  downto 0);
	sys_tx_data02_i  : in    std_logic_vector(7  downto 0);
	
	-- 系统指令
	sys_flag_o       : out   std_logic;
	sys_opera_o      : out   std_logic_vector(15 downto 0);
	discharge_flag_o : out   std_logic;
	protect_clr_o    : out   std_logic;
	
	-- SVC指令
	svc_alpha_o      : out   std_logic_vector(15  downto 0);  -- 触发角
	svc_a_run_o      : out   std_logic;   -- A相连续运行
	svc_b_run_o      : out   std_logic;   -- B相连续运行
	svc_c_run_o      : out   std_logic;   -- C相连续运行
	
	-- 继电器控制指令
	rly_dc_on_o      : out   std_logic;   -- 直流侧继电器导通
	rly_dc_off_o     : out   std_logic;   -- 直流侧继电器关断
	rly_ac_on_o      : out   std_logic;   -- 交流侧继电器导通
	rly_ac_off_o     : out   std_logic;   -- 交流侧继电器关断
	rly_svc_on_o     : out   std_logic;   -- SVC继电器导通
	rly_svc_off_o    : out   std_logic);  -- SVC继电器关断
end zk422_entity;

architecture Behavioral of zk422_entity is
	-- 串口接收模块
	component sci_rx_entity
	generic (DIV_N   : std_logic_vector(15 downto 0) := X"0063";
			SUM_FLAG : std_logic_vector(1  downto 0) := "11");
	port (
		reset        : in    std_logic;
		clk          : in    std_logic;

		rxd_i        : in    std_logic;

		sci_data_o   : out   std_logic_vector(7  downto 0);
		sci_flag_o   : out   std_logic);
	end component;

	signal sci_data  : std_logic_vector(7  downto 0);
	signal sci_flag  : std_logic;

	-- 指令解析模块
	component zk_jx_entity
	generic (C_FRAM_OVR : std_logic_vector(23 downto 0) := X"100000");  -- 指令超时时间
	port (
		reset           : in    std_logic;
		clk             : in    std_logic;

		sci_flag_i      : in    std_logic;
		sci_data_i      : in    std_logic_vector(7  downto 0);

		-- 指令标志、代码、数据
		
		cmd_flag_o      : out   std_logic;
		cmd_code_o      : out   std_logic_vector(7  downto 0);
		cmd_data01_o    : out   std_logic_vector(7  downto 0);
		cmd_data02_o    : out   std_logic_vector(7  downto 0));
	end component;

	-- 指令标志、代码、数据
	signal cmd_flag      : std_logic;
	signal cmd_code      : std_logic_vector(7  downto 0);
	signal cmd_data01    : std_logic_vector(7  downto 0);
	signal cmd_data02    : std_logic_vector(7  downto 0);

	-- 主控指令模块
	component zk_cmd_entity
	port (
		reset            : in    std_logic;
		clk              : in    std_logic;

		-- 指令标志、代码、数据
		cmd_flag_i       : in    std_logic;
		cmd_code_i       : in    std_logic_vector(7  downto 0);
		cmd_data01_i     : in    std_logic_vector(7  downto 0);
		cmd_data02_i     : in    std_logic_vector(7  downto 0);

		----------------  指令输出  ----------------
		-- 系统指令
		sys_flag_o       : out   std_logic;
		sys_opera_o      : out   std_logic_vector(15 downto 0);
		discharge_flag_o : out   std_logic;
		protect_clr_o    : out   std_logic;
		
		-- SVC指令
		svc_alpha_o      : out   std_logic_vector(15  downto 0);  -- 触发角
		svc_a_run_o      : out   std_logic;   -- A相连续运行
		svc_b_run_o      : out   std_logic;   -- B相连续运行
		svc_c_run_o      : out   std_logic;   -- C相连续运行
		
		-- 继电器控制指令
		rly_dc_on_o      : out   std_logic;   -- 直流侧继电器导通
		rly_dc_off_o     : out   std_logic;   -- 直流侧继电器关断
		rly_ac_on_o      : out   std_logic;   -- 交流侧继电器导通
		rly_ac_off_o     : out   std_logic;   -- 交流侧继电器关断
		rly_svc_on_o     : out   std_logic;   -- SVC继电器导通
		rly_svc_off_o    : out   std_logic);  -- SVC继电器关断
	end component;
	
	-- 遥测模块
	component zk_tm_entity
	port (
		reset            : in    std_logic;
		clk              : in    std_logic;

		cmd_flag_i       : in    std_logic;
		cmd_code_i       : in    std_logic_vector(7  downto 0);
		cmd_data01_i     : in    std_logic_vector(7  downto 0);
		cmd_data02_i     : in    std_logic_vector(7  downto 0);
		
		-- 系统状态回传
		sys_tx_flag_i    : in    std_logic;
		sys_tx_data01_i  : in    std_logic_vector(7  downto 0);
		sys_tx_data02_i  : in    std_logic_vector(7  downto 0);
		
		tm_flag_o        : out   std_logic;
		tm_code_o        : out   std_logic_vector(7  downto 0);
		tm_data01_o      : out   std_logic_vector(7  downto 0);
		tm_data02_o      : out   std_logic_vector(7  downto 0));
	end component;
	
	signal tx_flag : std_logic;
	signal tx_code, tx_data01, tx_data02 : std_logic_vector(7  downto 0);
	
	-- 主控发送模块
	component zk_tx_entity
	port (
		reset            : in    std_logic;
		clk              : in    std_logic;

		tx_flag_i        : in    std_logic;
		tx_code_i        : in    std_logic_vector(7  downto 0);
		tx_data01_i      : in    std_logic_vector(7  downto 0);
		tx_data02_i      : in    std_logic_vector(7  downto 0);

		txd_end_o        : out   std_logic;  -- 发送结束标志
		txd_o            : out   std_logic);
	end component;
begin

	-- 串口接收模块,115200，无校验
	rx_inst  : sci_rx_entity
	generic map (DIV_N=>X"01B2", SUM_FLAG=>"00")
	port map (
		reset        => reset, 
		clk          => clk, 

		rxd_i        => rxd_i, 

		sci_data_o   => sci_data, 
		sci_flag_o   => sci_flag);

	-- 指令解析模块
	jx_inst : zk_jx_entity
	generic map (C_FRAM_OVR=>X"16E360")  -- 指令超时时间60ms
	port map (
		reset           => reset, 
		clk             => clk, 

		sci_data_i      => sci_data, 
		sci_flag_i      => sci_flag, 

		-- 指令标志、代码、数据

		cmd_flag_o      => cmd_flag,
		cmd_code_o      => cmd_code, 
		cmd_data01_o    => cmd_data01, 
		cmd_data02_o    => cmd_data02);

	-- 主控指令模块
	cmd_inst : zk_cmd_entity
	port map (
		reset            => reset, 
		clk              => clk,

		-- 指令标志、代码、数据
		cmd_flag_i       => cmd_flag, 
		cmd_code_i       => cmd_code,
		cmd_data01_i     => cmd_data01, 
		cmd_data02_i     => cmd_data02,

		----------------  指令输出  ----------------
		-- 系统指令
		sys_flag_o       => sys_flag_o,
		sys_opera_o      => sys_opera_o,
		discharge_flag_o => discharge_flag_o,  -- 放电
		protect_clr_o    => protect_clr_o,
		
		-- SVC指令
		svc_alpha_o      => svc_alpha_o,
		svc_a_run_o      => svc_a_run_o,
		svc_b_run_o      => svc_b_run_o,
		svc_c_run_o      => svc_c_run_o,
		
		-- 继电器控制指令
		rly_dc_on_o      => rly_dc_on_o,  
		rly_dc_off_o     => rly_dc_off_o, 
		rly_ac_on_o      => rly_ac_on_o,  
		rly_ac_off_o     => rly_ac_off_o, 
		rly_svc_on_o     => rly_svc_on_o, 
		rly_svc_off_o    => rly_svc_off_o);

	-- 遥测模块
	tm_inst : zk_tm_entity
	port map (
		reset            => reset,        
		clk              => clk,          
          
		cmd_flag_i       => cmd_flag,      
		cmd_code_i       => cmd_code,   
		cmd_data01_i     => cmd_data01, 
		cmd_data02_i     => cmd_data02,

		-- 系统状态回传
		sys_tx_flag_i    => sys_tx_flag_i,  
		sys_tx_data01_i  => sys_tx_data01_i,
		sys_tx_data02_i  => sys_tx_data02_i,
  
		tm_flag_o        => tx_flag,    
		tm_code_o        => tx_code,    
		tm_data01_o      => tx_data01,  
		tm_data02_o      => tx_data02);  
		
	-- 主控发送模块
	tx_inst : zk_tx_entity
	port map (
		reset            => reset, 
		clk              => clk, 

		-------------------------------------------------------------------------- 
		tx_flag_i        => tx_flag, 
		tx_code_i        => tx_code, 
		tx_data01_i      => tx_data01, 
		tx_data02_i      => tx_data02, 
		
		txd_end_o        => open, 
		txd_o            => txd_o);

end Behavioral;
