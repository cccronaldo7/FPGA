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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pulse_entity is
generic (POLAR : std_logic := '0');  -- ���Ա�־��0-�����壬1-������
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	length_i   : in    std_logic_vector(15 downto 0);

	sof_i      : in    std_logic;
	clks_i     : in    std_logic;

	pulse_o    : out   std_logic);
end pulse_entity;

architecture Behavioral of pulse_entity is
	-- ����ģ��
	component dff_entity
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		ce         : in    std_logic;
		clr        : in    std_logic;

		o          : out   std_logic);
	end component;

	signal pul_en, pul_end : std_logic;
	signal pul_cnt : std_logic_vector(15 downto 0);
begin

	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>sof_i, clr=>pul_end, o=>pul_en);

	-- ����
	process(reset, clk)
	begin
		if (reset='1') then
			pul_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (pul_en='0') then
				pul_cnt <= (others=>'0');
			else
				if (clks_i='1') then
					pul_cnt <= pul_cnt + '1';
				end if;
			end if;
		end if;
	end process;

	-- ������־
	process(reset, clk)
	begin
		if (reset='1') then
			pul_end <= '0';
		elsif rising_edge(clk) then
			if (pul_cnt=length_i) then
				pul_end <= '1';
			else
				pul_end <= '0';
			end if;
		end if;
	end process;

	-- ���
	pulse_o <= pul_en when (POLAR='1') else (not pul_en);

end Behavioral;
