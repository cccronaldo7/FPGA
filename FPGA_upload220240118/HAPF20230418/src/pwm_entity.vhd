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

entity pwm_entity is
port (
	reset               : in    std_logic;
	clk                 : in    std_logic;
	
	-- 系统指令
	sys_opera_i         : in    std_logic_vector(15 downto 0);
	discharge_flag_i    : in    std_logic;  -- 放电
	
	-- PWM输入
	pwm_4a_i            : in    std_logic;
	pwm_4b_i            : in    std_logic;
	pwm_5a_i            : in    std_logic;
	pwm_5b_i            : in    std_logic;
	pwm_6a_i            : in    std_logic;
	pwm_6b_i            : in    std_logic;
	
	-- PWM输出
	pwm_en_o            : out   std_logic;
	pwm_au_o            : out   std_logic;
	pwm_al_o            : out   std_logic;
	pwm_bu_o            : out   std_logic;
	pwm_bl_o            : out   std_logic;
	pwm_cu_o            : out   std_logic;
	pwm_cl_o            : out   std_logic;
	pwm_discharge_o     : out   std_logic;
	pwm_fault_o         : out   std_logic);
end pwm_entity;

architecture Behavioral of pwm_entity is

	signal pwm_fault, pwm_fault_s : std_logic;

	
begin

	-- PWM使能控制
	process(reset, clk)
	begin
		if (reset='1') then
			pwm_en_o  <= '0';  -- 低电平有效
		elsif rising_edge(clk) then
			if(sys_opera_i = X"A5A5") then
				pwm_en_o <= '1';
			else
				pwm_en_o <= '0';
			end if;
		end if;
	end process;
	
    -- 放电控制
	process(reset, clk)
	begin
		if (reset='1') then
			pwm_discharge_o  <= '0';
		elsif rising_edge(clk) then
			if(discharge_flag_i = '1') then
				pwm_discharge_o <= '1';
			else
				pwm_discharge_o <= '0';
			end if;
		end if;
	end process;
	
	-- PWM控制
	process(reset, clk)
	begin
		if (reset='1') then
			pwm_au_o  <= '0'; pwm_al_o  <= '0';
			pwm_bu_o  <= '0'; pwm_bl_o  <= '0';
			pwm_cu_o  <= '0'; pwm_cl_o  <= '0';
			pwm_fault <= '0';
		elsif rising_edge(clk) then
			if(pwm_4a_i = '1' and pwm_4b_i = '1') then
				pwm_au_o  <= '0'; pwm_al_o  <= '0';
				pwm_bu_o  <= '0'; pwm_bl_o  <= '0';
				pwm_cu_o  <= '0'; pwm_cl_o  <= '0';
				pwm_fault <= '1';
			elsif(pwm_5a_i = '1' and pwm_5b_i = '1') then
				pwm_au_o  <= '0'; pwm_al_o  <= '0';
				pwm_bu_o  <= '0'; pwm_bl_o  <= '0';
				pwm_cu_o  <= '0'; pwm_cl_o  <= '0';
				pwm_fault <= '1';
			elsif(pwm_6a_i = '1' and pwm_6b_i = '1') then
				pwm_au_o  <= '0'; pwm_al_o  <= '0';
				pwm_bu_o  <= '0'; pwm_bl_o  <= '0';
				pwm_cu_o  <= '0'; pwm_cl_o  <= '0';
				pwm_fault <= '1';
			elsif(sys_opera_i = X"AAAA") then
				pwm_au_o  <= '0'; pwm_al_o  <= '0';
				pwm_bu_o  <= '0'; pwm_bl_o  <= '0';
				pwm_cu_o  <= '0'; pwm_cl_o  <= '0';
				pwm_fault <= '0';
			elsif(sys_opera_i = X"5555") then
				pwm_au_o  <= pwm_4a_i; pwm_al_o  <= pwm_4b_i;
				pwm_bu_o  <= pwm_5a_i; pwm_bl_o  <= pwm_5b_i;
				pwm_cu_o  <= pwm_6a_i; pwm_cl_o  <= pwm_6b_i;
				pwm_fault <= '0';
			end if;
		end if;
	end process;
	
	-- PWM故障输出
	process(reset, clk)
	begin
		if (reset='1') then
			pwm_fault_s  <= '0';
		elsif rising_edge(clk) then
			pwm_fault_s <= pwm_fault;
		end if;
	end process;
	
	process(reset, clk)
	begin
		if (reset='1') then
			pwm_fault_o  <= '0';
		elsif rising_edge(clk) then
			if(pwm_fault = '1' and pwm_fault_s = '0') then
				pwm_fault_o  <= '1';
			else
				pwm_fault_o  <= '0';
			end if;
		end if;
	end process;

end Behavioral;
