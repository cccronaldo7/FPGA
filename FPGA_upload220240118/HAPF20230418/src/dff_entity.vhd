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

entity dff_entity is
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	ce         : in    std_logic;  -- ��λ
	clr        : in    std_logic;  -- ����

	o          : out   std_logic);
end dff_entity;

architecture Behavioral of dff_entity is
begin

	process(reset, clk)
	begin
		if (reset='1') then
			o <= '0';
		elsif rising_edge(clk) then
			if (clr='1') then  -- ������Чʱ���ſ���Ч�����ȼ���
				o <= '0';
			elsif (ce='1') then  -- ��λ��Чʱ���ſ���Ч
				o <= '1';
			end if;
		end if;
	end process;

end Behavioral;