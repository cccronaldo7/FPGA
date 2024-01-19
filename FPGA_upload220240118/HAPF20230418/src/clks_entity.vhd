----------------------------------------------------------------------------------
-- ��Ȩ(copyright)�����ҵ��ܱ任����ƹ��̼����о�����(NECC)
-- ��Ŀ����
-- ģ����: 
-- �ļ���: 
-- ����:   �ſ�
-- ���ܺ��ص����: 
-- ��ʼ�汾�ͷ���ʱ��: 1.00��2022-04-16
---------------------------------------------------
-- ������ʷ:
---------------------------------------------------
-- ���İ汾�͸���ʱ�䣺 
-- ������Ա����
-- ��������: �� 
-- ���İ汾�͸���ʱ�䣺 
-- ������Ա����
-- ��������: �� 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity clks_entity is
generic (DIV_N : std_logic_vector(15 downto 0) := X"000A");  -- ��Ƶϵ��
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	clks_i     : in    std_logic;  -- ��ɢʱ������

	clks_o     : out   std_logic); -- ��ɢʱ�����
end clks_entity;

architecture Behavioral of clks_entity is
	signal clks_cnt : std_logic_vector(15 downto 0);
begin

	process(reset, clk)
	begin
		if (reset='1') then
			clks_cnt <= (others=>'0');
			clks_o   <= '0';
		elsif rising_edge(clk) then
			if (clks_i='1') then
				if (clks_cnt<DIV_N) then
					clks_cnt <= clks_cnt + '1';
					clks_o   <= '0';
				else
					clks_cnt <= (others=>'0');
					clks_o   <= '1';
				end if;
			else
				clks_o <= '0';
			end if;
		end if;
	end process;

end Behavioral;
