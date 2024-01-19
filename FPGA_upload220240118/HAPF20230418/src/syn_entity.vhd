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

entity syn_entity is
generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');  -- ��λ��ֵ��ͬ������
port (
	reset     : in    std_logic;  -- ��λ
	clk       : in    std_logic;  -- ʱ��

	i         : in    std_logic;  -- �ⲿ����
	o         : out   std_logic); -- ͬ�����
end syn_entity;

architecture Behavioral of syn_entity is
	signal i_1, i_2 : std_logic;
begin

	process(reset, clk)
	begin
		if (reset='1') then
			i_1 <= INIT;
			i_2 <= INIT;
		elsif rising_edge(clk) then
			i_1 <= i;
			i_2 <= i_1;
		end if;
	end process;

	o <= i_1 when (LEVEL='0') else i_2;

end Behavioral;
