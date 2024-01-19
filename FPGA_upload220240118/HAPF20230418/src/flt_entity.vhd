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

entity flt_entity is
generic (INIT : std_logic := '0');
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	clks_i     : in    std_logic;
	length_i   : in    std_logic_vector(15 downto 0);  -- 滤波宽度	

	i          : in    std_logic;   -- 外部输入
	o          : out   std_logic);  -- 滤波输出
end flt_entity;

architecture Behavioral of flt_entity is
	-- 同步指令
	component syn_entity
	generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');
	port (
		reset    : in    std_logic;
		clk      : in    std_logic;

		i        : in    std_logic;
		o        : out   std_logic);
	end component;

	signal i_s, dat_reg : std_logic;
	signal cnt : std_logic_vector(15 downto 0);
begin

	-- 异步信号同步处理
	syn_inst1 : syn_entity generic map (INIT=>INIT, LEVEL=>'1') port map (reset=>reset, clk=>clk, i=>i, o=>i_s);

	process(reset, clk)
	begin
		if (reset='1') then
			cnt <= (others=>'0');
			dat_reg <= INIT;
		elsif rising_edge(clk) then
			if (clks_i='1') then
				if (i_s/=dat_reg) then
					if (cnt<length_i) then
						cnt <= cnt + '1';
					else
						cnt <= (others=>'0');
						dat_reg <= i_s;
					end if;
				else
					cnt <= (others=>'0');
				end if;
			end if;
		end if;
	end process;

	o <= dat_reg;

end Behavioral;