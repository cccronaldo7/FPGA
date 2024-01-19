----------------------------------------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
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

entity svc_entity is
port (
	reset              : in    std_logic;
	clk                : in    std_logic;
	
	vol_phase_i        : in     std_logic_vector(15 downto 0);     -- 电网电压相位

	-- SVC控制指令
	f_svc_alpha_i      : in    std_logic_vector(15  downto 0);  -- 触发角
	f_svc_a_run_i      : in    std_logic;   -- A相连续运行
	f_svc_b_run_i      : in    std_logic;   -- B相连续运行
	f_svc_c_run_i      : in    std_logic;   -- C相连续运行
	
	-- SVC输出
	svc_a_o            : out   std_logic;
	svc_b_o            : out   std_logic;
	svc_c_o            : out   std_logic);
end svc_entity;

architecture Behavioral of svc_entity is

signal svc_a_cnt, svc_b_cnt, svc_c_cnt : std_logic_vector(15 downto 0);
signal f_svc_a_run, f_svc_b_run, f_svc_c_run : std_logic;
signal f_svc_a_alpha  : std_logic_vector(15 downto 0);
signal f_svc_a_beta  : std_logic_vector(15 downto 0);
signal f_svc_b_alpha, f_svc_b_beta : std_logic_vector(15 downto 0);
signal f_svc_c_alpha, f_svc_c_beta : std_logic_vector(15 downto 0);

signal vol_phase_s : std_logic_vector(15 downto 0);
	
begin

	process(reset, clk)
	begin
		if (reset='1') then
			f_svc_a_alpha  <= X"28B1";  -- 默认120°触发角 31250(7A12)表示360°
		elsif rising_edge(clk) then
			if(f_svc_a_run='0' and f_svc_b_run='0' and f_svc_c_run='0') then
				f_svc_a_alpha <= f_svc_alpha_i;
			end if;
		end if;
	end process;

	process(reset,clk)
	begin
		if (reset='1') then
			f_svc_a_beta <= X"65BA";  --默认120°+180°(X"3D09")  300°
			
			f_svc_b_alpha <= X"5161";  --默认120°+120°(X"28B1") 240°  B相触发角滞后120°
			f_svc_b_beta  <= X"1458";  --默认120°+300°(X"65BA") 60°
			
			f_svc_c_alpha <= X"0000";  --默认120°+240°(X"5161") 360°  C相触发角超前120°
			f_svc_c_beta  <= X"3D09";  --默认120°+60°(X"1458")  180° 
		elsif rising_edge(clk) then
			-- A相
			if(f_svc_a_alpha + X"3D09" >= X"7A12") then
				f_svc_a_beta <= f_svc_a_alpha + X"3D09" - X"7A12";  -- +180°
			else
				f_svc_a_beta <= f_svc_a_alpha + X"3D09";
			end if;
			
			-- B相
			f_svc_b_alpha <= f_svc_a_alpha + X"28B1";
			if(f_svc_a_alpha + X"65BA" >= X"7A12") then
				f_svc_b_beta <= f_svc_a_alpha + X"65BA" - X"7A12";  -- +180°
			else
				f_svc_b_beta <= f_svc_a_alpha + X"65BA";
			end if;
			
			-- C相
			if(f_svc_a_alpha + X"5161" >= X"7A12") then
				f_svc_c_alpha <= f_svc_a_alpha + X"5161" - X"7A12";  -- +180°
			else
				f_svc_c_alpha <= f_svc_a_alpha + X"5161";
			end if;
			f_svc_c_beta <= f_svc_a_alpha + X"1458";
		end if;
	end process;

	process(reset,clk)
	begin
		if (reset='1') then
			vol_phase_s <= X"0000";
		elsif rising_edge(clk) then
			vol_phase_s <= vol_phase_i;
		end if;
	end process;

	------------------------------------------------- SVC控制指令 ----------------------------------------------------
	-- A相SVC
	process(reset,clk)
	begin
		if (reset='1') then
			f_svc_a_run <= '0';
		elsif rising_edge(clk) then
			if (f_svc_a_run_i='1') then
				if(vol_phase_i = f_svc_a_alpha and vol_phase_s /= f_svc_a_alpha) then
					f_svc_a_run <= '1';
				elsif(vol_phase_i = f_svc_a_beta and vol_phase_s /= f_svc_a_beta) then
					f_svc_a_run <= '1';
				else
					f_svc_a_run <= '0';
				end if;
			else
				f_svc_a_run <= '0';
			end if;
		end if;
	end process;
	
	process(reset,clk)
	begin
		if (reset='1') then
			svc_a_cnt <= (others => '1');
			svc_a_o <= '0';
		elsif rising_edge(clk) then
			if (f_svc_a_run = '1') then
				svc_a_cnt <= X"0000";
				svc_a_o <= '1';
			elsif (svc_a_cnt < X"1194") then -- 90us
				svc_a_cnt <= svc_a_cnt + '1';
				svc_a_o <= '1';
			elsif (svc_a_cnt >= X"1194") then
				svc_a_cnt <= X"FFFF";
				svc_a_o <= '0';
			end if;
		end if;
	end process;
	
	-- B相SVC
	process(reset,clk)
	begin
		if (reset='1') then
			f_svc_b_run <= '0';
		elsif rising_edge(clk) then
			if (f_svc_b_run_i='1') then
				if(vol_phase_i = f_svc_b_alpha and vol_phase_s /= f_svc_b_alpha) then
					f_svc_b_run <= '1';
				elsif(vol_phase_i = f_svc_b_beta and vol_phase_s /= f_svc_b_beta) then
					f_svc_b_run <= '1';
				else
					f_svc_b_run <= '0';
				end if;
			else
				f_svc_b_run <= '0';
			end if;
		end if;
	end process;
	
	process(reset,clk)
	begin
		if (reset='1') then
			svc_b_cnt <= (others => '1');
			svc_b_o <= '0';
		elsif rising_edge(clk) then
			if (f_svc_b_run = '1') then
				svc_b_cnt <= X"0000";
				svc_b_o <= '1';
			elsif (svc_b_cnt < X"1194") then -- 90us
				svc_b_cnt <= svc_b_cnt + '1';
				svc_b_o <= '1';
			elsif (svc_b_cnt >= X"1194") then
				svc_b_cnt <= X"FFFF";
				svc_b_o <= '0';
			end if;
		end if;
	end process;
	
	-- C相SVC
	process(reset,clk)
	begin
		if (reset='1') then
			f_svc_c_run <= '0';
		elsif rising_edge(clk) then
			if (f_svc_c_run_i='1') then
				if(vol_phase_i = f_svc_c_alpha and vol_phase_s /= f_svc_c_alpha) then
					f_svc_c_run <= '1';
				elsif(vol_phase_i = f_svc_c_beta and vol_phase_s /= f_svc_c_beta) then
					f_svc_c_run <= '1';
				else
					f_svc_c_run <= '0';
				end if;
			else
				f_svc_c_run <= '0';
			end if;
		end if;
	end process;
	
	process(reset,clk)
	begin
		if (reset='1') then
			svc_c_cnt <= (others => '1');
			svc_c_o <= '0';
		elsif rising_edge(clk) then
			if (f_svc_c_run = '1') then
				svc_c_cnt <= X"0000";
				svc_c_o <= '1';
			elsif (svc_c_cnt < X"1194") then -- 90us
				svc_c_cnt <= svc_c_cnt + '1';
				svc_c_o <= '1';
			elsif (svc_c_cnt >= X"1194") then
				svc_c_cnt <= X"FFFF";
				svc_c_o <= '0';
			end if;
		end if;
	end process;

end Behavioral;
