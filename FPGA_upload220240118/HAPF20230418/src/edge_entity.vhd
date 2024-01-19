----------------------------------------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
-- 项目名：
-- 模块名: 
-- 文件名: 
-- 作者:   张凯   
-- 功能和特点概述: 
-- 初始版本和发布时间: 1.00，2022-04-16
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

entity edge_entity is
generic (INIT : std_logic := '0');  -- 复位初值
port (
	reset     : in    std_logic;
	clk       : in    std_logic;

	i         : in    std_logic;  -- 外部输入

	r         : out   std_logic;  -- 上升沿输出
	f         : out   std_logic); -- 下降沿输出
end edge_entity;

architecture Behavioral of edge_entity is
	signal i_s : std_logic;  -- 中间变量
begin
	process(reset,clk)
	begin
		if (reset='1') then
			i_s <= INIT;
		elsif rising_edge(clk) then
			i_s <= i;
		end if;
	end process;

	r  <= (not i_s) and i;  -- 上升沿输出
	f  <= (not i) and i_s;  -- 下降沿输出

end Behavioral;