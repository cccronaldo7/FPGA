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

entity rly_entity is
port (
	reset          : in    std_logic;
	clk            : in    std_logic;

	-- 继电器控制指令
	rly_dc_on_i    : in    std_logic;   -- 直流侧继电器导通
	rly_dc_off_i   : in    std_logic;   -- 直流侧继电器关断
	rly_ac_on_i    : in    std_logic;   -- 交流侧继电器导通
	rly_ac_off_i   : in    std_logic;   -- 交流侧继电器关断
	rly_svc_on_i   : in    std_logic;   -- SVC继电器导通
	rly_svc_off_i  : in    std_logic;   -- SVC继电器关断
	
	-- 继电器输出
	rly_dc_o       : out   std_logic;
	rly_ac_o       : out   std_logic;
	rly_svc_o      : out   std_logic);
end rly_entity;

architecture Behavioral of rly_entity is

	
begin

	------------------------------------------------- SVC控制指令 ----------------------------------------------------
	-- 直流侧继电器
	process(reset,clk)
	begin
		if (reset='1') then
			rly_dc_o <= '0';
		elsif rising_edge(clk) then
			if (rly_dc_on_i='1') then
				rly_dc_o <= '1';
			elsif (rly_dc_off_i='1') then
				rly_dc_o <= '0';
			end if;
		end if;
	end process;
	
	-- 交流侧继电器
	process(reset,clk)
	begin
		if (reset='1') then
			rly_ac_o <= '0';
		elsif rising_edge(clk) then
			if (rly_ac_on_i='1') then
				rly_ac_o <= '1';
			elsif (rly_ac_off_i='1') then
				rly_ac_o <= '0';
			end if;
		end if;
	end process;
	
	-- SVC继电器
	process(reset,clk)
	begin
		if (reset='1') then
			rly_svc_o <= '0';
		elsif rising_edge(clk) then
			if (rly_svc_on_i='1') then
				rly_svc_o <= '1';
			elsif (rly_svc_off_i='1') then
				rly_svc_o <= '0';
			end if;
		end if;
	end process;

end Behavioral;
