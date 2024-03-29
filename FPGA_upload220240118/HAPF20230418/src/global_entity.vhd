----------------------------------------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
-- 项目名：
-- 模块名: 全局文件
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

entity global_entity is
port (
	n_rst_i        : in    std_logic;
	clk_i          : in    std_logic;

	rst_o          : out   std_logic);
end global_entity;

architecture Behavioral of global_entity is
	---------------------------------------------------------------------
	-------------------------    常 值 信 号    -------------------------
	---------------------------------------------------------------------
	signal bit1_c0, bit1_c1 : std_logic;
	signal flt_length : std_logic_vector(15 downto 0);  -- 滤波宽度
	---------------------------------------------------------------------
	---------------------------------------------------------------------

	-- 时钟，复位
	signal rst_flt, rst_gen : std_logic;

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
begin

	---------------------------------------------------------------------
	-------------------------    常 值 信 号    -------------------------
	---------------------------------------------------------------------
	bit1_c0 <= '0';  bit1_c1 <= '1';
	flt_length <= X"4E20";  -- 滤波宽度0.4ms
	---------------------------------------------------------------------
	---------------------------------------------------------------------

	-- 时钟
	-- clk_o <= clk_i;

	-- 复位模块
	rstf_inst : flt_entity
	generic map (INIT=>'0')
	port map (
		reset        => bit1_c0, 
		clk          => clk_i, 

		clks_i       => bit1_c1, 
		length_i     => flt_length, 

		i            => n_rst_i, 

		o            => rst_flt);

	rst_gen   <= not rst_flt;
	rst_o <= rst_gen;

end Behavioral;
