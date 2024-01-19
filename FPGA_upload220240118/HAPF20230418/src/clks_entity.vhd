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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity clks_entity is
generic (DIV_N : std_logic_vector(15 downto 0) := X"000A");  -- 分频系数
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	clks_i     : in    std_logic;  -- 离散时钟输入

	clks_o     : out   std_logic); -- 离散时钟输出
end clks_entity;

architecture Behavioral of clks_entity is
	signal clks_cnt : std_logic_vector(15 downto 0);
begin

	process(reset, clk)
	begin
		if (reset='1') then
			clks_cnt <= (others=>'0');
			clks_o   <= '0';
		elsif rising_edge(clk) then
			if (clks_i='1') then
				if (clks_cnt<DIV_N) then
					clks_cnt <= clks_cnt + '1';
					clks_o   <= '0';
				else
					clks_cnt <= (others=>'0');
					clks_o   <= '1';
				end if;
			else
				clks_o <= '0';
			end if;
		end if;
	end process;

end Behavioral;
