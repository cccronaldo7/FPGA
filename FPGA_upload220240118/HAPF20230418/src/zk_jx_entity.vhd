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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity zk_jx_entity is
generic (C_FRAM_OVR : std_logic_vector(23 downto 0) := X"100000");  -- 指令超时时间
port (
	reset           : in    std_logic;
	clk             : in    std_logic;

	sci_flag_i      : in    std_logic;
	sci_data_i      : in    std_logic_vector(7  downto 0);

	-- 指令标志、代码、数据

	cmd_flag_o      : out   std_logic;
	cmd_code_o      : out   std_logic_vector(7  downto 0);
	cmd_data01_o    : out   std_logic_vector(7  downto 0);
	cmd_data02_o    : out   std_logic_vector(7  downto 0));
end zk_jx_entity;

architecture Behavioral of zk_jx_entity is
	-- 触发模块
	component dff_entity
	port (
		reset    : in    std_logic;
		clk      : in    std_logic;

		ce       : in    std_logic;
		clr      : in    std_logic;

		o        : out   std_logic);
	end component;

	-- 同步模块
	component syn_entity
	generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');
	port (
		reset    : in    std_logic;
		clk      : in    std_logic;

		i        : in    std_logic;

		o        : out   std_logic);
	end component;

	-- 定义数据缓冲区
	type darray is array(0 to 4) of std_logic_vector(7 downto 0);
	signal dbuffer : darray;

	-- 内部标志
	signal fram_sof, fram_en, fram_eof : std_logic;
	signal cmd_flag1   : std_logic;
	signal cmd_flag1_s : std_logic;
	signal cmd_flag_s  : std_logic;

	signal fram_time : std_logic_vector(23 downto 0);  -- 帧计时
	signal byte_cnt  : std_logic_vector(7  downto 0);  -- 字节计数器
	signal rx_state  : std_logic_vector(7  downto 0);  -- 接收状态
begin

	-- 将数据移入缓冲区
	process(reset, clk)
	begin
		if (reset='1') then
			for i in 0 to 4 loop
				dbuffer(i) <= (others=>'0');
			end loop;
		elsif rising_edge(clk) then
			if (fram_eof='1') then  -- 接收到新的指令或超时，清除缓冲区
				for i in 0 to 4 loop
					dbuffer(i) <= (others=>'0');
				end loop;
			elsif (sci_flag_i='1') then
				dbuffer(0) <= sci_data_i;
				for i in 1 to 4 loop
					dbuffer(i) <= dbuffer(i-1);
				end loop;
			end if;
		end if;
	end process;

	-- 检测帧起始标志
	process(reset, clk)
	begin
		if (reset='1') then
			fram_sof <= '0';
		elsif rising_edge(clk) then
			if (sci_flag_i='1' and sci_data_i=X"EB") then
				fram_sof <= '1';
			else
				fram_sof <= '0';
			end if;
		end if;
	end process;

	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>fram_sof, clr=>fram_eof, o=>fram_en);

	-- 计算帧传输时间
	process(reset, clk)
	begin
		if (reset='1') then
			fram_time <= (others=>'0');
		elsif rising_edge(clk) then
			if (fram_en='0') then
				fram_time <= (others=>'0');
			else
				if (fram_time<C_FRAM_OVR) then
					fram_time <= fram_time + '1';
				else
					fram_time <= (others=>'1');
				end if;
			end if;
		end if;
	end process;

	-- 指令结束标志
	process(reset, clk)
	begin
		if (reset='1') then
			cmd_flag_s <= '0';
			fram_eof   <= '0';
		elsif rising_edge(clk) then
			cmd_flag_s <= cmd_flag1_s;

			if (cmd_flag_s='1' or fram_time>=C_FRAM_OVR) then
				fram_eof <= '1';
			else
				fram_eof <= '0';
			end if;
		end if;
	end process;

	-- 字节计数
	process(reset, clk)
	begin
		if (reset='1') then
			byte_cnt <= (others=>'1');
		elsif rising_edge(clk) then
			if (sci_flag_i='1') then
				byte_cnt <= (others=>'0');
			else
				if (byte_cnt<X"1F") then
					byte_cnt <= byte_cnt + '1';
				else
					byte_cnt <= (others=>'1');
				end if;
			end if;
		end if;
	end process;

	-------------------------------------------------------------------------------------
	-----------------------------------  短 指 令 1  ------------------------------------
	-------------------------------------------------------------------------------------
	-- 接收状态机1
	process(reset, clk)
	begin
		if (reset='1') then
			rx_state <= X"00";
		elsif rising_edge(clk) then
			case rx_state is
				when X"00"  =>
					if (byte_cnt=X"01" and dbuffer(4)=X"EB") then
						rx_state <= X"01";
					end if;
				when X"01"  =>
					if (byte_cnt>=X"1F") then
						rx_state <= X"00";
					else
					    if(dbuffer(3) = X"90") then
							rx_state <= X"02";
						end if;
					end if;
				when X"02"  =>
					if (byte_cnt>=X"1F") then
						rx_state <= X"00";
					end if;
				when others => rx_state <= X"00";
			end case;
		end if;
	end process;

	-- 指令标志1
	process(reset, clk)
	begin
		if (reset='1') then
			cmd_flag1 <= '0';
		elsif rising_edge(clk) then
			if (byte_cnt=X"19" and rx_state=X"02") then
				cmd_flag1 <= '1';
			else
				cmd_flag1 <= '0';
			end if;
		end if;
	end process;

	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	syn_inst1 : syn_entity generic map (INIT=>'0', LEVEL=>'1') port map (reset=>reset, clk=>clk, i=>cmd_flag1, o=>cmd_flag1_s);

	------------------------------------------------------------------------------------------
	-----------------------------------    指 令 输 出    ------------------------------------
	------------------------------------------------------------------------------------------
	-- 指令标志、代码输出
	process(reset, clk)
	begin
		if (reset='1') then
			cmd_flag_o   <= '0';
			cmd_code_o   <= (others=>'0');
			cmd_data01_o <= (others=>'0');
			cmd_data02_o <= (others=>'0');
		elsif rising_edge(clk) then
			if (cmd_flag1='1') then
				cmd_flag_o   <= '1';
				cmd_code_o   <= dbuffer(2);
				cmd_data01_o <= dbuffer(1);
				cmd_data02_o <= dbuffer(0);
			else
				cmd_flag_o <= '0';
			end if;
		end if;
	end process;

end Behavioral;
