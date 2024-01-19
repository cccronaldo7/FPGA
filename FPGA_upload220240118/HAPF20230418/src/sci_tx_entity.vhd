----------------------------------------------------------------------------------
-- ��Ȩ(copyright)��
-- ��Ŀ����
-- ģ����: 
-- �ļ���: 
-- ����:   �ſ�
-- ���ܺ��ص����: 
-- ��ʼ�汾�ͷ���ʱ��: 1.00��2022-05-17
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

entity sci_tx_entity is
generic (DIV_N   : std_logic_vector(15 downto 0) := X"0063";
		SUM_FLAG : std_logic_vector(1  downto 0) := "11");  -- У���־��00-��У�飬01-��У�飬10-żУ��
port (
	reset     : in    std_logic;
	clk       : in    std_logic;

	tx_sof_i  : in    std_logic;  -- ���ͱ�־
	tx_dat_i  : in    std_logic_vector(7  downto 0);  -- �����ֽ�

	txd_eof_o : out   std_logic;  -- ���ͽ�����־
	txd_o     : out   std_logic); -- ����BIT
end sci_tx_entity;

architecture Behavioral of sci_tx_entity is
	-- ������ģ��
	component dff_entity
	port (
		reset     : in  std_logic;
		clk       : in  std_logic;

		ce        : in  std_logic;
		clr       : in  std_logic;

		o         : out std_logic);
	end component;

	signal div_flag, tx_en, tx_eof, dat_jy, dat_sum : std_logic;
	signal div_cnt  : std_logic_vector(15 downto 0);
	signal bit_cnt  : std_logic_vector(3  downto 0);
begin

	-- ʹ�ܷ���
	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>tx_sof_i, clr=>tx_eof, o=>tx_en);

	process(reset, clk)
	begin
		if (reset='1') then
			div_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (tx_en='0') then
				div_cnt <= (others=>'0');
			else
				if (div_cnt<DIV_N) then
					div_cnt <= div_cnt + '1';
				else
					div_cnt <= (others=>'0');
				end if;
			end if;
		end if;
	end process;

	div_flag <= '1' when (div_cnt=DIV_N) else '0';  -- ��������־

	process(reset, clk)
	begin
		if (reset='1') then
			bit_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (tx_en='0') then
				bit_cnt <= (others=>'0');
			else
				if (div_flag='1') then
					bit_cnt <= bit_cnt + '1';
				end if;
			end if;
		end if;
	end process;

	-- ��������
	process(reset, clk)
	begin
		if (reset='1') then
			dat_sum <= '0';
		elsif rising_edge(clk) then
			dat_sum  <= tx_dat_i(0) xor tx_dat_i(1) xor tx_dat_i(2) xor tx_dat_i(3) xor tx_dat_i(4) xor tx_dat_i(5) xor tx_dat_i(6) xor tx_dat_i(7);
		end if;
	end process;

	-- У��λѡ��
	process(reset, clk)
	begin
		if (reset='1') then
			dat_jy <= '1';
		elsif rising_edge(clk) then
			if (SUM_FLAG="10") then
				dat_jy <= dat_sum;
			elsif (SUM_FLAG="01") then
				dat_jy <= not dat_sum;
			else
				dat_jy <= '1';
			end if;
		end if;
	end process;

	-- ����ֹͣ��־
	process(reset, clk)
	begin
		if (reset='1') then
			tx_eof <= '0';
		elsif rising_edge(clk) then
			if (SUM_FLAG(0)=SUM_FLAG(1)) then
				if (div_flag='1' and bit_cnt="1001") then  -- ��У��ʱ
					tx_eof <= '1';
				else
					tx_eof <= '0';
				end if;
			else
				if (div_flag='1' and bit_cnt="1010") then  -- ��У��ʱ
					tx_eof <= '1';
				else
					tx_eof <= '0';
				end if;
			end if;
		end if;
	end process;

	-- ���ͽ���
	process(reset, clk)
	begin
		if (reset='1') then
			txd_o <= '1';
		elsif rising_edge(clk) then
			if (tx_en='0') then
				txd_o <= '1';
			else
				case bit_cnt is
					when "0000" => txd_o <= '0';          -- ��ʼλ
					when "0001" => txd_o <= tx_dat_i(0);
					when "0010" => txd_o <= tx_dat_i(1);
					when "0011" => txd_o <= tx_dat_i(2);
					when "0100" => txd_o <= tx_dat_i(3);
					when "0101" => txd_o <= tx_dat_i(4);
					when "0110" => txd_o <= tx_dat_i(5);
					when "0111" => txd_o <= tx_dat_i(6);
					when "1000" => txd_o <= tx_dat_i(7);
					when "1001" => txd_o <= dat_jy;  -- У���ֹͣλ
					when others => txd_o <= '1';     -- ֹͣλ
				end case;
			end if;
		end if;
	end process;

	process(reset, clk)
	begin
		if (reset='1') then
			txd_eof_o <= '0';
		elsif rising_edge(clk) then
			txd_eof_o <= tx_eof;
		end if;
	end process;

end Behavioral;
