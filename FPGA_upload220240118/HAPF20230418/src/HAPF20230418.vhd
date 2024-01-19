----------------------------------------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
-- 项目名：
-- 模块名: 顶层文件
-- 文件名: 
-- 作者:   张凯
-- 功能和特点概述: 
-- 初始版本和发布时间: 1.00，2023-04-19
---------------------------------------------------
-- 更改历史:
---------------------------------------------------
-- 更改版本和更改时间： 
-- 更改人员：无
-- 更改描述: 无 
-- 更改版本和更改时间： 
-- 更改人员：无
-- 更改描述: 无 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HAPF20230418 is
port(
	-- 全局接口
	n_rst_i             : in    std_logic;
	clk                 : in    std_logic;

	-- 422通信接口
	kz422_rx_i          : in    std_logic;
	kz422_tx_o          : out   std_logic;
	
	-- dsp接口
	dsp_cs_i            : in    std_logic;                         -- 片选
	dsp_wr_i            : in    std_logic;                         -- 写使能
	dsp_rd_i            : in    std_logic;                         -- 读使能       
	dsp_addr_i          : in    std_logic_vector(7 downto 0);      -- 地址总线
	
	dsp_data_io         : inout std_logic_vector(15 downto 0);     -- 数据总线
	
	-- W5300接口
	
	-- 过零比较接口
	vol1_cmp_i          : in    std_logic;
	ecap6_o             : out   std_logic;
	
	-- 保护接口
	drive_fault_i       : in    std_logic;
	
	
	-- PWM接口
	pwm_4a_i            : in    std_logic;
	pwm_4b_i            : in    std_logic;
	pwm_5a_i            : in    std_logic;
	pwm_5b_i            : in    std_logic;
	pwm_6a_i            : in    std_logic;
	pwm_6b_i            : in    std_logic;
	
	pwm_en_o            : out   std_logic;
	pwm_au_o            : out   std_logic;
	pwm_al_o            : out   std_logic;
	pwm_bu_o            : out   std_logic;
	pwm_bl_o            : out   std_logic;
	pwm_cu_o            : out   std_logic;
	pwm_cl_o            : out   std_logic;
	pwm_discharge_o     : out   std_logic;
	
	-- SCR 接口(作为测试接口)
	scr_a_o             : out   std_logic;
	scr_b_o             : out   std_logic;
	
	-- SVC 接口
	svc_a_o             : out   std_logic;
	svc_b_o             : out   std_logic;
	svc_c_o             : out   std_logic;
	
	-- 继电器接口
	rly_dc_o            : out   std_logic;
	rly_ac_o            : out   std_logic;
	rly_svc_o           : out   std_logic
	
	);
end HAPF20230418;

architecture Behavioral of HAPF20230418 is

	signal bit1_c1 : std_logic;

	-- 全局模块
	component global_entity
	port (
		n_rst_i        : in    std_logic;
		clk_i          : in    std_logic;

		rst_o          : out   std_logic);
	end component;

	signal reset  : std_logic;
	
	-- 同步模块
	component syn_entity
	generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');  -- 复位初值、同步次数
	port (
		reset     : in    std_logic;  -- 复位
		clk       : in    std_logic;  -- 时钟

		i         : in    std_logic;  -- 外部输入
		o         : out   std_logic); -- 同步输出
	end component;
	
	signal kz422_rx  : std_logic;
	
	----------------------------------------------------------------------------------------------------
	----------------------------------------------  通信  ----------------------------------------------
	----------------------------------------------------------------------------------------------------	
	-- 422模块
	component zk422_entity
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
	end component;

	signal f_sys_flag    : std_logic;
	signal f_sys_opera   : std_logic_vector(15 downto 0);
	signal discharge_flag : std_logic;
	signal protect_clr : std_logic;
	
	signal f_svc_alpha : std_logic_vector(15 downto 0);  
	signal f_svc_a_run : std_logic;
	signal f_svc_b_run : std_logic;
	signal f_svc_c_run : std_logic;
	signal f_rly_dc_on, f_rly_dc_off, f_rly_ac_on, f_rly_ac_off, f_rly_svc_on, f_rly_svc_off : std_logic;
	
	-- dsp接口模块
	component dsp_intf_entity
	port (
		reset               : in     std_logic;
		clk                 : in     std_logic;

		dsp_cs_i            : in     std_logic;                         -- 片选
		dsp_wr_i            : in     std_logic;                         -- 写使能
		dsp_rd_i            : in     std_logic;                         -- 读使能       
		dsp_addr_i          : in     std_logic_vector(7 downto 0);      -- 地址总线
		
		vol_phase_i         : in     std_logic_vector(15 downto 0);     -- 电网电压相位
		sys_opera_i         : in     std_logic_vector(15 downto 0);     -- 系统运行
		
		dsp_data_io         : inout  std_logic_vector(15 downto 0);     -- 数据总线
	
		cmd_flag_o          : out    std_logic;                         -- 指令输出标志位
		cmd_addr_o          : out    std_logic_vector(7  downto 0);     -- 指令输出地址
		cmd_data_o          : out    std_logic_vector(15 downto 0));    -- 指令输出数据线
	end component;
	
	signal cmd_flag : std_logic;
	signal cmd_addr : std_logic_vector(7  downto 0);
	signal cmd_data : std_logic_vector(15 downto 0);
	
	component dsp_cmd_entity
	port (
		reset          : in    std_logic;
		clk            : in    std_logic;

		cmd_flag_i     : in    std_logic;
		cmd_addr_i     : in    std_logic_vector(7  downto 0);
		cmd_data_i     : in    std_logic_vector(15 downto 0);

		-- SVC控制指令
		svc_alpha_o    : out   std_logic_vector(15  downto 0));  -- 触发角
	end component;
	
	signal d_svc_alpha : std_logic_vector(15  downto 0);
	
	
	----------------------------------------------------------------------------------------------------
	----------------------------------------------  控制  ----------------------------------------------
	----------------------------------------------------------------------------------------------------
	-- 锁相环模块
	component pll_entity
	port (
		reset               : in     std_logic;
		clk                 : in     std_logic;

		ecap_i              : in     std_logic;
		
		ecap_r_o            : out    std_logic;
		vol_phase_o         : out    std_logic_vector(15 downto 0));    -- 电网电压相位
	end component;
	
	signal vol_phase : std_logic_vector(15 downto 0);
	
	-- 产生50hz方波测试
	signal pll_cnt   : std_logic_vector(19 downto 0);
	signal pll_cap   : std_logic;
	
	-- PWM模块
	component pwm_entity
	port (
		reset               : in    std_logic;
		clk                 : in    std_logic;
		
		-- 系统指令
		sys_opera_i         : in    std_logic_vector(15 downto 0);
		discharge_flag_i    : in    std_logic;  -- 放电
		
		-- PWM输入
		pwm_4a_i            : in    std_logic;
		pwm_4b_i            : in    std_logic;
		pwm_5a_i            : in    std_logic;
		pwm_5b_i            : in    std_logic;
		pwm_6a_i            : in    std_logic;
		pwm_6b_i            : in    std_logic;
		
		-- PWM输出
		pwm_en_o            : out   std_logic;
		pwm_au_o            : out   std_logic;
		pwm_al_o            : out   std_logic;
		pwm_bu_o            : out   std_logic;
		pwm_bl_o            : out   std_logic;
		pwm_cu_o            : out   std_logic;
		pwm_cl_o            : out   std_logic;
		pwm_discharge_o     : out   std_logic;
		pwm_fault_o         : out   std_logic);
	end component;
	
	signal pwm_fault : std_logic;
	
	-- 保护模块
	component protect_entity
	port (
		reset               : in     std_logic;
		clk                 : in     std_logic;

		drive_fault_i       : in     std_logic;
		
		drive_fault_o       : out    std_logic);
	end component;
	
	signal protect_flag : std_logic;
	signal drive_fault  : std_logic;
	
	-- 系统模块
	component system_entity
	port (
		reset               : in    std_logic;
		clk                 : in    std_logic;
		
		-- 系统指令
		f_sys_flag_i        : in    std_logic;
		f_sys_opera_i       : in    std_logic_vector(15 downto 0);
		
		--保护指令
		protect_flag_i      : in    std_logic;
		
		-- PWM故障
		pwm_fault_i         : in    std_logic;
		
		-- 驱动故障
		drive_fault_i       : in     std_logic;
		
		-- 系统状态输出
		sys_opera_o         : out   std_logic_vector(15 downto 0);
		
		-- 系统状态回传
		sys_tx_flag_o       : out   std_logic;
		sys_tx_data01_o     : out   std_logic_vector(7  downto 0);
		sys_tx_data02_o     : out   std_logic_vector(7  downto 0));
	end component;
	
	signal sys_opera     : std_logic_vector(15 downto 0);
	signal sys_tx_flag   : std_logic;
	signal sys_tx_data01 : std_logic_vector(7  downto 0);
	signal sys_tx_data02 : std_logic_vector(7  downto 0);

	----------------------------------------------------------------------------------------------------
	---------------------------------------------  开关量  ---------------------------------------------
	----------------------------------------------------------------------------------------------------
	-- svc模块
	component svc_entity
	port (
		reset              : in    std_logic;
		clk                : in    std_logic;

		vol_phase_i        : in     std_logic_vector(15 downto 0);     -- 电网电压相位

		-- SVC控制指令
		f_svc_alpha_i      : in    std_logic_vector(15  downto 0);  -- 触发角
		f_svc_a_run_i      : in    std_logic;   -- A相连续运行
		f_svc_b_run_i      : in    std_logic;   -- B相连续运行
		f_svc_c_run_i      : in    std_logic;   -- C相连续运行
		
		-- SVC输出
		svc_a_o            : out   std_logic;
		svc_b_o            : out   std_logic;
		svc_c_o            : out   std_logic);
	end component;
	
	-- 继电器模块
	component rly_entity
	port (
		reset          : in    std_logic;
		clk            : in    std_logic;

		-- 继电器控制指令
		rly_dc_on_i    : in    std_logic;   -- 直流侧继电器导通
		rly_dc_off_i   : in    std_logic;   -- 直流侧继电器关断
		rly_ac_on_i    : in    std_logic;   -- 交流侧继电器导通
		rly_ac_off_i   : in    std_logic;   -- 交流侧继电器关断
		rly_svc_on_i   : in    std_logic;   -- SVC继电器导通
		rly_svc_off_i  : in    std_logic;   -- SVC继电器关断
		
		-- 继电器输出
		rly_dc_o       : out   std_logic;
		rly_ac_o       : out   std_logic;
		rly_svc_o      : out   std_logic);
	end component;

begin

	bit1_c1 <= '1';

	-- 全局模块
	global_inst : global_entity
	port map (
		n_rst_i        => n_rst_i, 
		clk_i          => clk, 
 
		rst_o          => reset);
	
	----------------------------------------------------------------------------------------------------
	----------------------------------------------  通信  ----------------------------------------------
	----------------------------------------------------------------------------------------------------	
	-- 422模块
	zk422_inst : zk422_entity
	port map (
		reset            => reset,
		clk              => clk,

		rxd_i            => kz422_rx_i,
		txd_o            => kz422_tx_o,
		
		-- 系统状态回传
		sys_tx_flag_i    => sys_tx_flag,
		sys_tx_data01_i  => sys_tx_data01,
		sys_tx_data02_i  => sys_tx_data02,

		-- 系统指令
		sys_flag_o       => f_sys_flag,    
		sys_opera_o      => f_sys_opera,  
		discharge_flag_o => discharge_flag,
		protect_clr_o    => protect_clr,  
		
		-- SVC指令
		svc_alpha_o      => open,     -- 触发角
		svc_a_run_o      => f_svc_a_run,     -- A相连续运行
		svc_b_run_o      => f_svc_b_run,     -- B相连续运行
		svc_c_run_o      => f_svc_c_run,     -- C相连续运行
		
		-- 继电器控制指令
		rly_dc_on_o      => f_rly_dc_on,     -- 直流侧继电器导通
		rly_dc_off_o     => f_rly_dc_off,    -- 直流侧继电器关断
		rly_ac_on_o      => f_rly_ac_on,     -- 交流侧继电器导通
		rly_ac_off_o     => f_rly_ac_off,    -- 交流侧继电器关断
		rly_svc_on_o     => f_rly_svc_on,    -- SVC继电器导通
		rly_svc_off_o    => f_rly_svc_off);  -- SVC继电器关断
	
	-- dsp接口模块
	dsp_intf_inst : dsp_intf_entity
	port map (
		reset               => reset,
		clk                 => clk,  

		dsp_cs_i            => dsp_cs_i,         -- 片选
		dsp_wr_i            => dsp_wr_i,         -- 写使能
		dsp_rd_i            => dsp_rd_i,         -- 读使能       
		dsp_addr_i          => dsp_addr_i,       -- 地址总线
		
		vol_phase_i         => vol_phase,        -- 电网电压相位
		sys_opera_i         => sys_opera,        -- 系统运行
		
		dsp_data_io         => dsp_data_io,      -- 数据总线
		
		cmd_flag_o          => cmd_flag,         -- 指令输出标志位
		cmd_addr_o          => cmd_addr,         -- 指令输出地址
		cmd_data_o          => cmd_data);        -- 指令输出数据线

	dsp_cmd_inst : dsp_cmd_entity
	port map (
		reset          => reset,        
		clk            => clk,          

		cmd_flag_i     => cmd_flag,   
		cmd_addr_i     => cmd_addr,
		cmd_data_i     => cmd_data,

		-- SVC控制指令
		svc_alpha_o    => d_svc_alpha);     -- 触发角
		
	----------------------------------------------------------------------------------------------------
	----------------------------------------------  控制  ----------------------------------------------
	----------------------------------------------------------------------------------------------------	
	-- 锁相环模块
	pll_inst : pll_entity
	port map (
		reset               => reset,
		clk                 => clk,

		ecap_i              => vol1_cmp_i,
		
		ecap_r_o            => scr_a_o,
		vol_phase_o         => vol_phase);    -- 电网电压相位
	
	-- 产生50hz方波测试
	process(reset, clk)
	begin
		if (reset='1') then
			pll_cnt <= (others=>'0');
			pll_cap <= '0';
		elsif rising_edge(clk) then
			if (pll_cnt <= X"7A120") then
				pll_cnt <= pll_cnt + '1';
				pll_cap <= '0';
			elsif (pll_cnt < X"F4240") then
				pll_cnt <= pll_cnt + '1';
				pll_cap <= '1';
			else
				pll_cnt <= X"00001";
				pll_cap <= '0';
			end if;
		end if;
	end process;
	
	scr_b_o <= vol1_cmp_i;  --测试
	
	-- PWM模块
	pwm_inst : pwm_entity
	port map (
		reset               => reset,
		clk                 => clk,
		
		-- 系统指令
		sys_opera_i         => sys_opera,
		discharge_flag_i    => discharge_flag,
		
		-- PWM输入
		pwm_4a_i            => pwm_4a_i,
		pwm_4b_i            => pwm_4b_i,
		pwm_5a_i            => pwm_5a_i,
		pwm_5b_i            => pwm_5b_i,
		pwm_6a_i            => pwm_6a_i,
		pwm_6b_i            => pwm_6b_i,
		
		-- PWM输出
		pwm_en_o            => pwm_en_o,
		pwm_au_o            => pwm_au_o,
		pwm_al_o            => pwm_al_o,
		pwm_bu_o            => pwm_bu_o,
		pwm_bl_o            => pwm_bl_o,
		pwm_cu_o            => pwm_cu_o,
		pwm_cl_o            => pwm_cl_o,
		pwm_discharge_o     => pwm_discharge_o,
		pwm_fault_o         => pwm_fault);
	
	-- 保护模块
	protect_inst : protect_entity
	port map(
		reset               => reset,
		clk                 => clk,  

		drive_fault_i       => drive_fault_i,
		
		drive_fault_o       => drive_fault);
	
	process(reset, clk)
	begin
		if (reset='1') then
			protect_flag <= '0';
		elsif rising_edge(clk) then
			if (protect_clr = '1') then
				protect_flag <= '0';
			end if;
		end if;
	end process;
	
	-- 系统模块
	system_inst : system_entity
	port map (
		reset               => reset,
		clk                 => clk,
		
		-- 系统指令
		f_sys_flag_i        => f_sys_flag,
		f_sys_opera_i       => f_sys_opera,
		
		--保护指令
		protect_flag_i      => protect_flag,
		
		-- PWM故障
		pwm_fault_i         => pwm_fault,
		
		-- 驱动故障
		drive_fault_i       => drive_fault,
		
		-- 系统状态输出
		sys_opera_o         => sys_opera,
		
		-- 系统状态回传
		sys_tx_flag_o       => sys_tx_flag,
		sys_tx_data01_o     => sys_tx_data01,
		sys_tx_data02_o     => sys_tx_data02);
	
	----------------------------------------------------------------------------------------------------
	---------------------------------------------  开关量  ---------------------------------------------
	----------------------------------------------------------------------------------------------------
	-- svc模块
	svc_inst : svc_entity
	port map (
		reset               => reset,     
		clk                 => clk,       

		vol_phase_i         => vol_phase,        -- 电网电压相位

		-- SVC控制指令
		f_svc_alpha_i       => d_svc_alpha,      -- 触发角
		f_svc_a_run_i       => f_svc_a_run,      -- A相连续运行
		f_svc_b_run_i       => f_svc_b_run,      -- B相连续运行
		f_svc_c_run_i       => f_svc_c_run,      -- C相连续运行

		-- SVC输出
		svc_a_o             => svc_a_o,   
		svc_b_o             => svc_b_o,   
		svc_c_o             => svc_c_o);
	
	-- 继电器模块
	rly_inst : rly_entity
	port map (
		reset          => reset,      
		clk            => clk,        

		-- 继电器控制指令
		rly_dc_on_i    => f_rly_dc_on,     -- 直流侧继电器导通
		rly_dc_off_i   => f_rly_dc_off,    -- 直流侧继电器关断
		rly_ac_on_i    => f_rly_ac_on,     -- 交流侧继电器导通
		rly_ac_off_i   => f_rly_ac_off,    -- 交流侧继电器关断
		rly_svc_on_i   => f_rly_svc_on,    -- SVC继电器导通
		rly_svc_off_i  => f_rly_svc_off,   -- SVC继电器关断

		-- 继电器输出
		rly_dc_o       => rly_dc_o,   
		rly_ac_o       => rly_ac_o,   
		rly_svc_o      => rly_svc_o);
		
	----------------------------------------------------------------------------------------------------
	--------------------------------------  主电路控制板接口转换  --------------------------------------
	----------------------------------------------------------------------------------------------------
	
end Behavioral;
