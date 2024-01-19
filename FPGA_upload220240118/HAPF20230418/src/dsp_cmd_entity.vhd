----------------------------------------------------------------------------------
-- 版权(copyright)：国家电能变换与控制工程技术研究中心(NECC)
-- 项目名：
-- 模块名: 
-- 文件名: 
-- 作者:   张凯
-- 功能和特点概述: 。
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

entity dsp_cmd_entity is
port (
	reset          : in    std_logic;
	clk            : in    std_logic;

	cmd_flag_i     : in    std_logic;
	cmd_addr_i     : in    std_logic_vector(7  downto 0);
	cmd_data_i     : in    std_logic_vector(15 downto 0);

	-- SVC控制指令
	svc_alpha_o    : out   std_logic_vector(15  downto 0));  -- 触发角
end dsp_cmd_entity;

architecture Behavioral of dsp_cmd_entity is

	signal svc_alpha : std_logic_vector(15 downto 0);

	
begin

	------------------------------------------------- SVC控制指令 ----------------------------------------------------
	-- SVC触发角
	-- process(reset,clk)
	-- begin
	-- 	if (reset='1') then
	-- 		svc_alpha <= X"28B1";  -- 默认120°触发角 31250(7A12)表示360°;
	-- 	elsif rising_edge(clk) then
	-- 		if (cmd_flag_i='1' and cmd_addr_i=X"06") then
	-- 			if(cmd_data_i > X"37F3") then         -- 电网电压采样为线电压。
	-- 				svc_alpha <= X"37F3";             -- 保证触发角工作在110°(254D)-165°(37F3)
	-- 			elsif(cmd_data_i < X"254D") then
	-- 				svc_alpha <= X"254D";
	-- 			else
	-- 				svc_alpha <= cmd_data_i;
	-- 			end if;
	-- 		end if;
	-- 	end if;
	-- end process;
	
	process(reset,clk)
	begin
		if (reset='1') then
			svc_alpha <= X"28B1";  -- 默认120°触发角 31250(7A12)表示360°;
		elsif rising_edge(clk) then
			if (cmd_flag_i='1' and cmd_addr_i=X"06") then
				if(cmd_data_i > X"37F3") then         -- 电网电压采样为线电压。
	 				svc_alpha <= X"37F3";             -- 保证触发角工作在90°(1E85)-165°(37F3)
	 			elsif(cmd_data_i < X"1E85") then
	 				svc_alpha <= X"1E85";
	 			else
	 				svc_alpha <= cmd_data_i;
	 			end if;
			end if;
		end if;
	end process;
	
	svc_alpha_o <= svc_alpha + X"0A2C"; --星接时，角度滞后30°
	
end Behavioral;
