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

entity zk_cmd_entity is
port (
	reset            : in    std_logic;
	clk              : in    std_logic;

	-- 指令标志、代码、数据
	cmd_flag_i       : in    std_logic;
	cmd_code_i       : in    std_logic_vector(7  downto 0);
	cmd_data01_i     : in    std_logic_vector(7  downto 0);
	cmd_data02_i     : in    std_logic_vector(7  downto 0);
	
	----------------  指令输出  ----------------
	-- 系统指令
	sys_flag_o       : out   std_logic;
	sys_opera_o      : out   std_logic_vector(15 downto 0);
	discharge_flag_o : out   std_logic;
	protect_clr_o    : out   std_logic;
	
	-- SVC指令
	svc_alpha_o      : out   std_logic_vector(15  downto 0);  -- 触发角
	svc_a_run_o      : out   std_logic;   -- A相连续运行
	svc_b_run_o      : out   std_logic;   -- B相连续运行
	svc_c_run_o      : out   std_logic;   -- C相连续运行
	
	-- 继电器控制指令
	rly_dc_on_o      : out   std_logic;   -- 直流侧继电器导通
	rly_dc_off_o     : out   std_logic;   -- 直流侧继电器关断
	rly_ac_on_o      : out   std_logic;   -- 交流侧继电器导通
	rly_ac_off_o     : out   std_logic;   -- 交流侧继电器关断
	rly_svc_on_o     : out   std_logic;   -- SVC继电器导通
	rly_svc_off_o    : out   std_logic);  -- SVC继电器关断
end zk_cmd_entity;

architecture Behavioral of zk_cmd_entity is
	signal svc_alpha : std_logic_vector(15 downto 0);
	
begin

	---------------------  指令输出  ---------------------	
	-- 系统指令
	process(reset, clk)
	begin
		if (reset='1') then
			sys_flag_o  <= '0';
			sys_opera_o <= X"AAAA";
		elsif rising_edge(clk) then
			if (cmd_flag_i='1' and cmd_code_i=X"00") then
				sys_flag_o  <= '1';
				sys_opera_o <= cmd_data01_i & cmd_data02_i;
			else
				sys_flag_o <= '0';
			end if;
		end if;
	end process;
	
	-- 触发角
	process(reset, clk)
	begin
		if (reset='1') then
			svc_alpha  <= X"28B1";  -- 默认120°触发角 31250(7A12)表示360°
		elsif rising_edge(clk) then
			if(cmd_flag_i='1') then
				if (cmd_code_i=X"01") then
					if((cmd_data01_i & cmd_data02_i) > X"37F3") then         -- 电网电压采样为线电压。
						svc_alpha <= X"37F3";                              -- 保证触发角工作在110°(254D)-165°(37F3)
					elsif((cmd_data01_i & cmd_data02_i) < X"254D") then
						svc_alpha <= X"254D";
					else
						svc_alpha <= cmd_data01_i & cmd_data02_i;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- svc_alpha_o <= svc_alpha;
	svc_alpha_o <= svc_alpha + X"0A2C"; --星接时，角度滞后30°
	
	-- 放电指令
	process(reset, clk)
	begin
		if (reset='1') then
			discharge_flag_o  <= '0';
		elsif rising_edge(clk) then
			if(cmd_flag_i='1') then
				if (cmd_code_i=X"20") then
					if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
						discharge_flag_o  <= '1';
					elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
						discharge_flag_o  <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- 保护清零
	process(reset, clk)
	begin
		if (reset='1') then
			protect_clr_o  <= '0';
		elsif rising_edge(clk) then
			if(cmd_flag_i='1') then
				if (cmd_code_i=X"21") then
					if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
						protect_clr_o  <= '1';
					end if;
				end if;
			else
				protect_clr_o <= '0';
			end if;
		end if;
	end process;
	
	---------------------  SVC连续运行  ---------------------
	-- A相连续运行
	process(reset, clk)
	begin
		if (reset='1') then
			svc_a_run_o  <= '0';
		elsif rising_edge(clk) then
			if(cmd_flag_i='1') then
				if (cmd_code_i=X"05" or cmd_code_i=X"08") then
					if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
						svc_a_run_o  <= '1';
					elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
						svc_a_run_o  <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- B相连续运行
	process(reset, clk)
	begin
		if (reset='1') then
			svc_b_run_o  <= '0';
		elsif rising_edge(clk) then
			if(cmd_flag_i='1') then
				if (cmd_code_i=X"06" or cmd_code_i=X"08") then
					if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
						svc_b_run_o  <= '1';
					elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
						svc_b_run_o  <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- C相连续运行
	process(reset, clk)
	begin
		if (reset='1') then
			svc_c_run_o  <= '0';
		elsif rising_edge(clk) then
			if(cmd_flag_i='1') then
				if (cmd_code_i=X"07" or cmd_code_i=X"08") then
					if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
						svc_c_run_o  <= '1';
					elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
						svc_c_run_o  <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	---------------------  继电器控制指令  ---------------------	
	-- 直流侧继电器
	process(reset, clk)
	begin
		if (reset='1') then
			rly_dc_on_o  <= '0';
			rly_dc_off_o <= '0';
		elsif rising_edge(clk) then
			if (cmd_flag_i='1' and cmd_code_i=X"10") then
				if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
				    rly_dc_on_o  <= '1';
				elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
					rly_dc_off_o <= '1';
				else
					rly_dc_on_o  <= '0';
					rly_dc_off_o <= '0';
				end if;
			else
				rly_dc_on_o  <= '0';
				rly_dc_off_o <= '0';
			end if;
		end if;
	end process;
	
	-- 交流侧继电器
	process(reset, clk)
	begin
		if (reset='1') then
			rly_ac_on_o  <= '0';
			rly_ac_off_o <= '0';
		elsif rising_edge(clk) then
			if (cmd_flag_i='1' and cmd_code_i=X"11") then
				if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
				    rly_ac_on_o  <= '1';
				elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
					rly_ac_off_o <= '1';
				else
					rly_ac_on_o  <= '0';
					rly_ac_off_o <= '0';
				end if;
			else
				rly_ac_on_o  <= '0';
				rly_ac_off_o <= '0';
			end if;
		end if;
	end process;
	
	-- SVC继电器
	process(reset, clk)
	begin
		if (reset='1') then
			rly_svc_on_o  <= '0';
			rly_svc_off_o <= '0';
		elsif rising_edge(clk) then
			if (cmd_flag_i='1' and cmd_code_i=X"12") then
				if(cmd_data01_i = X"55" and cmd_data02_i = X"55") then
				    rly_svc_on_o  <= '1';
				elsif(cmd_data01_i = X"AA" and cmd_data02_i = X"AA") then
					rly_svc_off_o <= '1';
				else
					rly_svc_on_o  <= '0';
					rly_svc_off_o <= '0';
				end if;
			else
				rly_svc_on_o  <= '0';
				rly_svc_off_o <= '0';
			end if;
		end if;
	end process;
	
end Behavioral;
