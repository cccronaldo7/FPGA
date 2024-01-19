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

entity syn_entity is
generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');  -- 复位初值、同步次数
port (
	reset     : in    std_logic;  -- 复位
	clk       : in    std_logic;  -- 时钟

	i         : in    std_logic;  -- 外部输入
	o         : out   std_logic); -- 同步输出
end syn_entity;

architecture Behavioral of syn_entity is
	signal i_1, i_2 : std_logic;
begin

	process(reset, clk)
	begin
		if (reset='1') then
			i_1 <= INIT;
			i_2 <= INIT;
		elsif rising_edge(clk) then
			i_1 <= i;
			i_2 <= i_1;
		end if;
	end process;

	o <= i_1 when (LEVEL='0') else i_2;

end Behavioral;
