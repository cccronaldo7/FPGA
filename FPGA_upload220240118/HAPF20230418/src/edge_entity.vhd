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

entity edge_entity is
generic (INIT : std_logic := '0');  -- ��λ��ֵ
port (
	reset     : in    std_logic;
	clk       : in    std_logic;

	i         : in    std_logic;  -- �ⲿ����

	r         : out   std_logic;  -- ���������
	f         : out   std_logic); -- �½������
end edge_entity;

architecture Behavioral of edge_entity is
	signal i_s : std_logic;  -- �м����
begin
	process(reset,clk)
	begin
		if (reset='1') then
			i_s <= INIT;
		elsif rising_edge(clk) then
			i_s <= i;
		end if;
	end process;

	r  <= (not i_s) and i;  -- ���������
	f  <= (not i) and i_s;  -- �½������

end Behavioral;