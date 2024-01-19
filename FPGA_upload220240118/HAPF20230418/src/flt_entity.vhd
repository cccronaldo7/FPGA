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

entity flt_entity is
generic (INIT : std_logic := '0');
port (
	reset      : in    std_logic;
	clk        : in    std_logic;

	clks_i     : in    std_logic;
	length_i   : in    std_logic_vector(15 downto 0);  -- �˲����	

	i          : in    std_logic;   -- �ⲿ����
	o          : out   std_logic);  -- �˲����
end flt_entity;

architecture Behavioral of flt_entity is
	-- ͬ��ָ��
	component syn_entity
	generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');
	port (
		reset    : in    std_logic;
		clk      : in    std_logic;

		i        : in    std_logic;
		o        : out   std_logic);
	end component;

	signal i_s, dat_reg : std_logic;
	signal cnt : std_logic_vector(15 downto 0);
begin

	-- �첽�ź�ͬ������
	syn_inst1 : syn_entity generic map (INIT=>INIT, LEVEL=>'1') port map (reset=>reset, clk=>clk, i=>i, o=>i_s);

	process(reset, clk)
	begin
		if (reset='1') then
			cnt <= (others=>'0');
			dat_reg <= INIT;
		elsif rising_edge(clk) then
			if (clks_i='1') then
				if (i_s/=dat_reg) then
					if (cnt<length_i) then
						cnt <= cnt + '1';
					else
						cnt <= (others=>'0');
						dat_reg <= i_s;
					end if;
				else
					cnt <= (others=>'0');
				end if;
			end if;
		end if;
	end process;

	o <= dat_reg;

end Behavioral;