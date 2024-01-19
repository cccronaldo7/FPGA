----------------------------------------------------------------------------------
-- ��Ȩ(copyright)��
-- ��Ŀ����
-- ģ����: 
-- �ļ���: 
-- ����:   �ſ�
-- ���ܺ��ص����: 
-- ��ʼ�汾�ͷ���ʱ��: 
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

entity sci_rx_entity is
generic (DIV_N   : std_logic_vector(15 downto 0) := X"0063";
		SUM_FLAG : std_logic_vector(1  downto 0) := "11");  -- ��Ƶϵ����У���־��00/11-��У�飬01-��У�飬10-żУ��
port (
	reset       : in    std_logic;
	clk         : in    std_logic;

	rxd_i       : in    std_logic;  -- ��������

	sci_data_o  : out   std_logic_vector(7  downto 0);  -- ת���ֽ�

	sci_flag_o  : out   std_logic);  -- ת����־
end sci_rx_entity;

architecture Behavioral of sci_rx_entity is
	---------------------------------------------------------------------
	-------------------------    �� ֵ �� ��    -------------------------
	---------------------------------------------------------------------
	signal bit1_c1 : std_logic;
	---------------------------------------------------------------------
	---------------------------------------------------------------------

	-- �˲�ģ��
	component flt_entity
	generic (INIT : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		clks_i     : in    std_logic;
		length_i   : in    std_logic_vector(15 downto 0);

		i          : in    std_logic;
		o          : out   std_logic);
	end component;

	-- ����ģ��
	component edge_entity
	generic (INIT  : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		i          : in    std_logic;

		r          : out   std_logic;
		f          : out   std_logic);
	end component;

	-- ����ģ��
	component dff_entity
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		ce         : in    std_logic;
		clr        : in    std_logic;

		o          : out   std_logic);
	end component;

	signal flt_rxd, built_flag, built_bit, built_rxd, mid_flag, rx_sof, rx_en, rx_eof, rx_jy, dat_jy, dat_sum : std_logic;  -- �������ź�
	signal flt_length, div_cnt, mid_time : std_logic_vector(15 downto 0);  -- ��Ƶ������
	signal bit_cnt : std_logic_vector(3  downto 0);  -- λ������
	signal rx_dat  : std_logic_vector(7  downto 0);  -- �����ֽ�
	
	-- ����ģ��
	component pulse_entity
	generic (POLAR : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		length_i   : in    std_logic_vector(15 downto 0);

		sof_i      : in    std_logic;
		clks_i     : in    std_logic;

		pulse_o    : out   std_logic);
	end component;
begin
	-------------------------    �� ֵ �� ��    -------------------------
	bit1_c1 <= '1';
	---------------------------------------------------------------------

	-- �˲�����
	flt_length <= "000" & DIV_N(15 downto 3);  -- ��422���ؿ�ȵ�12.5%�˲�

	flt_inst1 : flt_entity
	generic map (INIT=>'1')
	port map (
		reset        => reset, 
		clk          => clk, 

		clks_i       => bit1_c1, 
		length_i     => flt_length, 

		i            => rxd_i, 

		o            => flt_rxd);

	-- ����ʹ�ܿ���
	process(reset, clk)
	begin
		if (reset='1') then
			built_rxd <= '0';
		elsif rising_edge(clk) then
			built_rxd <= flt_rxd or built_bit;  -- �ⲿ������ֹͣλ����ֵ���
		end if;
	end process;

	ed_inst1  : edge_entity generic map (INIT=>'1') port map (reset=>reset, clk=>clk, i=>built_rxd, r=>open, f=>rx_sof);  -- ��⵽��ʵ����ʼλ
	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>rx_sof, clr=>rx_eof, o=>rx_en);

	-- ��Ƶ
	process(reset, clk)
	begin
		if (reset='1') then
			div_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (rx_en='0') then
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

	mid_time <= '0' & DIV_N(15 downto 1);  -- ȡ��������

	-- λ����
	process(reset, clk)
	begin
		if (reset='1') then
			bit_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (rx_en='0') then
				bit_cnt <= (others=>'0');
			else
				if (div_cnt=DIV_N) then
					bit_cnt <= bit_cnt + '1';
				end if;
			end if;
		end if;
	end process;

	-- ȡ�е�
	process(reset, clk)
	begin
		if (reset='1') then
			mid_flag <= '0';
		elsif rising_edge(clk) then
			if (div_cnt=mid_time) then
				mid_flag <= '1';
			else
				mid_flag <= '0';
			end if;
		end if;
	end process;

	-- ����ת��
	process(reset, clk)
	begin
		if (reset='1') then
			rx_dat <= (others=>'0');
		elsif rising_edge(clk) then
			if (mid_flag='1') then
				if (bit_cnt="0000") then
					rx_dat <= (others=>'0');
				elsif (bit_cnt<"1001") then
					rx_dat <= flt_rxd & rx_dat(7 downto 1);
				end if;
			end if;
		end if;
	end process;

	-- ȡУ��λ
	process(reset, clk)
	begin
		if (reset='1') then
			rx_jy <= '1';
		elsif rising_edge(clk) then
			if (mid_flag='1' and bit_cnt="1001") then
				rx_jy <= flt_rxd;  -- ����У��ʱ��У��λ=ֹͣλ
			end if;
		end if;
	end process;

	-- ����У���
	process(reset, clk)
	begin
		if (reset='1') then
			dat_sum <= '0';
		elsif rising_edge(clk) then
			dat_sum <= rx_dat(7) xor rx_dat(6) xor rx_dat(5) xor rx_dat(4) xor rx_dat(3) xor rx_dat(2) xor rx_dat(1) xor rx_dat(0);
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

	-- ������־���
	process(reset, clk)
	begin
		if (reset='1') then
			rx_eof <= '0';
		elsif rising_edge(clk) then
			if (mid_flag='1') then
				case bit_cnt is
					when "0000" =>
						if (flt_rxd/='0') then  -- ����ʼλ������0��ر�ʹ��
							rx_eof <= '1';
						else
							rx_eof <= '0';
						end if;
					when "1001" =>  -- ����У��
						if (SUM_FLAG(0)=SUM_FLAG(1)) then
							rx_eof <= '1';
						else
							rx_eof <= '0';
						end if;
					when "1010" =>  -- ��У��
						if (SUM_FLAG(0)/=SUM_FLAG(1)) then
							rx_eof <= '1';
						else
							rx_eof <= '0';
						end if;
					when others => rx_eof <= '0';
				end case;
			else
				rx_eof <= '0';
			end if;
		end if;
	end process;

	-- ����ֹͣλ
	process(reset, clk)
	begin
		if (reset='1') then
			built_flag <= '0';
		elsif rising_edge(clk) then
			if (rx_eof='1' and bit_cnt(3)='1' and flt_rxd/='1') then  -- ֹͣλ������1ʱ������������ֹ��1֡���մ���
				built_flag <= '1';
			else
				built_flag <= '0';
			end if;
		end if;
	end process;

	pul_inst1  : pulse_entity
	generic map (POLAR=>'1')
	port map (
		reset        => reset, 
		clk          => clk, 

		length_i     => mid_time, 

		sof_i        => built_flag, 
		clks_i       => bit1_c1, 

		pulse_o      => built_bit);  -- �������λ��ȵ�Ĭ�ϵ�ƽ

	-- �����Ч����
	process(reset, clk)
	begin
		if (reset='1') then
			sci_flag_o <= '0';
			sci_data_o <= (others=>'0');
		elsif rising_edge(clk) then
			if (rx_eof='1' and bit_cnt(3)='1' and flt_rxd='1' and rx_jy=dat_jy) then  -- �ж�ֹͣλ��У��λ
				sci_flag_o <= '1';
				sci_data_o <= rx_dat;
			else
				sci_flag_o <= '0';
			end if;
		end if;
	end process;

end Behavioral;
