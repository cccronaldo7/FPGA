--------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
-- 项目名:
-- 模块名:  
-- 文件名:
-- 作者:  张凯
-- 功能和特点概述: 
-- 初始版本和发布时间: 1.00，2022-03-30
---------------------------------------------------
-- 更改历史:
---------------------------------------------------
-- 更改版本和更改时间： 
-- 更改人员： 
-- 更改描述:  
-- 更改版本和更改时间： 
-- 更改人员：无
-- 更改描述: 无 
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity protect_entity is
port (
	reset               : in     std_logic;
	clk                 : in     std_logic;

	drive_fault_i       : in     std_logic;
	
	drive_fault_o       : out    std_logic);
end protect_entity;

architecture Behavioral of protect_entity is

	signal vol_phase : std_logic_vector(20 downto 0);
	
	-- 滤波模块
	component flt_entity
	generic (INIT : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		clks_i     : in    std_logic;
		length_i   : in    std_logic_vector(15 downto 0);

		i          : in    std_logic;
		o          : out   std_logic);
	end component;
	
	signal bit1_c1 : std_logic;
	signal flt_length : std_logic_vector(15 downto 0);  -- 滤波宽度
	
	signal drive_fault_s : std_logic;
	
	component edge_entity
	generic (INIT  : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		i          : in    std_logic;

		r          : out   std_logic;
		f          : out   std_logic);
	end component;
	
begin
	
	---------------------------------------------------------------------
	-------------------------    常 值 信 号    -------------------------
	---------------------------------------------------------------------
	bit1_c1 <= '1';
	flt_length <= X"03E8";  -- 滤波宽度20us

	-- 输入滤波模块
	flt_inst : flt_entity
	generic map (INIT=>'0')
	port map (
		reset        => reset, 
		clk          => clk, 

		clks_i       => bit1_c1, 
		length_i     => flt_length, 

		i            => drive_fault_i, 

		o            => drive_fault_s);
	
	edge_inst1 : edge_entity
	generic map (INIT => '1')
	port map(
		reset      => reset,
		clk        => clk,

		i          => drive_fault_s,

		r          => open,
		f          => drive_fault_o);
	
end Behavioral;
