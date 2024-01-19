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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pulse_entity is
generic (POLAR : std_logic := '0');  -- 极性标志，0-低脉冲，1-高脉冲
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	length_i   : in    std_logic_vector(15 downto 0);

	sof_i      : in    std_logic;
	clks_i     : in    std_logic;

	pulse_o    : out   std_logic);
end pulse_entity;

architecture Behavioral of pulse_entity is
	-- 触发模块
	component dff_entity
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		ce         : in    std_logic;
		clr        : in    std_logic;

		o          : out   std_logic);
	end component;

	signal pul_en, pul_end : std_logic;
	signal pul_cnt : std_logic_vector(15 downto 0);
begin

	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>sof_i, clr=>pul_end, o=>pul_en);

	-- 计数
	process(reset, clk)
	begin
		if (reset='1') then
			pul_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (pul_en='0') then
				pul_cnt <= (others=>'0');
			else
				if (clks_i='1') then
					pul_cnt <= pul_cnt + '1';
				end if;
			end if;
		end if;
	end process;

	-- 结束标志
	process(reset, clk)
	begin
		if (reset='1') then
			pul_end <= '0';
		elsif rising_edge(clk) then
			if (pul_cnt=length_i) then
				pul_end <= '1';
			else
				pul_end <= '0';
			end if;
		end if;
	end process;

	-- 输出
	pulse_o <= pul_en when (POLAR='1') else (not pul_en);

end Behavioral;
