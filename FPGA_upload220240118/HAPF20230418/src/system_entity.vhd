----------------------------------------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
-- 项目名：
-- 模块名: 
-- 文件名: 
-- 作者:   张凯
-- 功能和特点概述: 
-- 初始版本和发布时间: 1.00，2022-05-17
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity system_entity is
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
end system_entity;

architecture Behavioral of system_entity is


	
begin

	-- 系统状态输出
	process(reset, clk)
	begin
		if (reset='1') then
			sys_opera_o  <= X"AAAA";
		elsif rising_edge(clk) then
			if(pwm_fault_i = '1') then
				sys_opera_o <= X"AAAA";
			elsif(drive_fault_i = '1') then
				sys_opera_o <= X"AAAA";
			elsif(protect_flag_i = '1') then
				sys_opera_o <= X"A5A5";
			elsif(f_sys_flag_i = '1') then
				sys_opera_o <= f_sys_opera_i;
			end if;
		end if;
	end process;
	
    -- 系统状态回传
	process(reset, clk)
	begin
		if (reset='1') then
			sys_tx_flag_o  <= '0';
			sys_tx_data01_o <= X"00";
			sys_tx_data02_o <= X"00";
		elsif rising_edge(clk) then
			if(pwm_fault_i = '1') then
				sys_tx_flag_o  <= '1';
				sys_tx_data01_o <= X"00";
				sys_tx_data02_o <= X"01";
			elsif(protect_flag_i = '1') then
				sys_tx_flag_o  <= '1';
				sys_tx_data01_o <= X"00";
				sys_tx_data02_o <= X"02";
			elsif(drive_fault_i = '1') then
				sys_tx_flag_o  <= '1';
				sys_tx_data01_o <= X"00";
				sys_tx_data02_o <= X"03";
			else
				sys_tx_flag_o  <= '0';
			end if;
		end if;
	end process;
	
end Behavioral;
