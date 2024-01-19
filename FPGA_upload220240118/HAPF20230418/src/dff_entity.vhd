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

entity dff_entity is
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	ce         : in    std_logic;  -- 置位
	clr        : in    std_logic;  -- 清零

	o          : out   std_logic);
end dff_entity;

architecture Behavioral of dff_entity is
begin

	process(reset, clk)
	begin
		if (reset='1') then
			o <= '0';
		elsif rising_edge(clk) then
			if (clr='1') then  -- 清零有效时，门控无效，优先级高
				o <= '0';
			elsif (ce='1') then  -- 置位有效时，门控有效
				o <= '1';
			end if;
		end if;
	end process;

end Behavioral;