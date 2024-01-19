----------------------------------------------------------------------------------
-- 版权(copyright)：
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

entity sci_tx_entity is
generic (DIV_N   : std_logic_vector(15 downto 0) := X"0063";
		SUM_FLAG : std_logic_vector(1  downto 0) := "11");  -- 校验标志：00-无校验，01-奇校验，10-偶校验
port (
	reset     : in    std_logic;
	clk       : in    std_logic;

	tx_sof_i  : in    std_logic;  -- 发送标志
	tx_dat_i  : in    std_logic_vector(7  downto 0);  -- 发送字节

	txd_eof_o : out   std_logic;  -- 发送结束标志
	txd_o     : out   std_logic); -- 发送BIT
end sci_tx_entity;

architecture Behavioral of sci_tx_entity is
	-- 触发器模块
	component dff_entity
	port (
		reset     : in  std_logic;
		clk       : in  std_logic;

		ce        : in  std_logic;
		clr       : in  std_logic;

		o         : out std_logic);
	end component;

	signal div_flag, tx_en, tx_eof, dat_jy, dat_sum : std_logic;
	signal div_cnt  : std_logic_vector(15 downto 0);
	signal bit_cnt  : std_logic_vector(3  downto 0);
begin

	-- 使能发送
	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>tx_sof_i, clr=>tx_eof, o=>tx_en);

	process(reset, clk)
	begin
		if (reset='1') then
			div_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (tx_en='0') then
				div_cnt <= (others=>'0');
			else
				if (div_cnt<DIV_N) then
					div_cnt <= div_cnt + '1';
				else
					div_cnt <= (others=>'0');
				end if;
			end if;
		end if;
	end process;

	div_flag <= '1' when (div_cnt=DIV_N) else '0';  -- 计数满标志

	process(reset, clk)
	begin
		if (reset='1') then
			bit_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (tx_en='0') then
				bit_cnt <= (others=>'0');
			else
				if (div_flag='1') then
					bit_cnt <= bit_cnt + '1';
				end if;
			end if;
		end if;
	end process;

	-- 计算异或和
	process(reset, clk)
	begin
		if (reset='1') then
			dat_sum <= '0';
		elsif rising_edge(clk) then
			dat_sum  <= tx_dat_i(0) xor tx_dat_i(1) xor tx_dat_i(2) xor tx_dat_i(3) xor tx_dat_i(4) xor tx_dat_i(5) xor tx_dat_i(6) xor tx_dat_i(7);
		end if;
	end process;

	-- 校验位选择
	process(reset, clk)
	begin
		if (reset='1') then
			dat_jy <= '1';
		elsif rising_edge(clk) then
			if (SUM_FLAG="10") then
				dat_jy <= dat_sum;
			elsif (SUM_FLAG="01") then
				dat_jy <= not dat_sum;
			else
				dat_jy <= '1';
			end if;
		end if;
	end process;

	-- 发送停止标志
	process(reset, clk)
	begin
		if (reset='1') then
			tx_eof <= '0';
		elsif rising_edge(clk) then
			if (SUM_FLAG(0)=SUM_FLAG(1)) then
				if (div_flag='1' and bit_cnt="1001") then  -- 无校验时
					tx_eof <= '1';
				else
					tx_eof <= '0';
				end if;
			else
				if (div_flag='1' and bit_cnt="1010") then  -- 带校验时
					tx_eof <= '1';
				else
					tx_eof <= '0';
				end if;
			end if;
		end if;
	end process;

	-- 发送进程
	process(reset, clk)
	begin
		if (reset='1') then
			txd_o <= '1';
		elsif rising_edge(clk) then
			if (tx_en='0') then
				txd_o <= '1';
			else
				case bit_cnt is
					when "0000" => txd_o <= '0';          -- 起始位
					when "0001" => txd_o <= tx_dat_i(0);
					when "0010" => txd_o <= tx_dat_i(1);
					when "0011" => txd_o <= tx_dat_i(2);
					when "0100" => txd_o <= tx_dat_i(3);
					when "0101" => txd_o <= tx_dat_i(4);
					when "0110" => txd_o <= tx_dat_i(5);
					when "0111" => txd_o <= tx_dat_i(6);
					when "1000" => txd_o <= tx_dat_i(7);
					when "1001" => txd_o <= dat_jy;  -- 校验或停止位
					when others => txd_o <= '1';     -- 停止位
				end case;
			end if;
		end if;
	end process;

	process(reset, clk)
	begin
		if (reset='1') then
			txd_eof_o <= '0';
		elsif rising_edge(clk) then
			txd_eof_o <= tx_eof;
		end if;
	end process;

end Behavioral;
