 -- 
 -- Copyright (c) 2023, Daniel Lammers, Amir Moradi, Nicolai Müller, Aein Rezaei Shahmirzadi
 -- 
 -- All rights reserved.
 -- 
 -- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 -- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 -- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 -- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTERS BE LIABLE FOR ANY
 -- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 -- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 -- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 -- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 -- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 -- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 -- 
 -- Please see LICENSE and README for license and further instructions.
 -- 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AES_Round is
    Generic ( d    : integer := 8;
				  n    : integer := 8;
				  m    : integer := 8;
				  Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101";
				  Mul3 : std_logic_vector := "1001011000000000110010110000000001100101000000000010010000000000000100100000000010011111000000000101100100000000001011000000000000000000100101100000000011001011000000000110010100000000001001000000000000010010000000001001111100000000010110010000000000101100";
				  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
				  poly : std_logic_vector := "10000000000000011";
				  A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
				  Q0	 : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
				  Q1	 : std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
				  Q3	 : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
				  C	 : std_logic_vector := x"009b");
    Port ( clk 	: in std_logic;
			  rst 	: in std_logic;
			  en     : in std_logic;
			  
			  last_round : in std_logic;
			  take_input : in std_logic;
			  
			  x0 		: in  std_logic_vector(127 downto 0);
           x1 		: in  std_logic_vector(127 downto 0);
			  key0 	: in  std_logic_vector(127 downto 0);
           key1 	: in  std_logic_vector(127 downto 0);
			  
			  randomness : in  std_logic_vector(895 downto 0); -- 8*7*16
			  
           z0 		: out std_logic_vector(127 downto 0);
           z1 		: out std_logic_vector(127 downto 0));
end AES_Round;

architecture Behavioral of AES_Round is

	component RegFDE_srst is
		 Generic (SIZE : POSITIVE := n+d);
		 Port ( CLK : in STD_LOGIC;
				  EN : in STD_LOGIC;
				  RST : in STD_LOGIC;
				  D : in STD_LOGIC_VECTOR ((SIZE-1) downto 0);
				  Q : out STD_LOGIC_VECTOR ((SIZE-1) downto 0));
	end component;

	component AddRoundKey is
		Generic ( d    : integer := 8;
					 n    : integer := 8);
		Port ( x0 		: in  std_logic_vector(16*n-1 downto 0);
				 x1 		: in  std_logic_vector(16*d-1 downto 0);
				 key0 	: in  std_logic_vector(16*n-1 downto 0);
				 key1 	: in  std_logic_vector(16*d-1 downto 0);
				 z0      : out std_logic_vector(16*n-1 downto 0);
				 z1      : out std_logic_vector(16*d-1 downto 0));
	end component;

	component Sbox is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
					  poly : std_logic_vector := "10000000000000011";
					  A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
					  Q0	 : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
					  Q1	 : std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
					  Q3	 : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
					  C	 : std_logic_vector := x"009b");
		 Port ( x0 		: in std_logic_vector(n-1 downto 0);
				  x1 		: in std_logic_vector(d-1 downto 0);
				  
				  reshare0_m : in std_logic_vector(n-1 downto 0);
				  reshare1_m : in std_logic_vector(n-1 downto 0);
				  reshare2_m : in std_logic_vector(n-1 downto 0);
				  reshare3_m : in std_logic_vector(n-1 downto 0);
				  reshare4_m : in std_logic_vector(n-1 downto 0);
				  reshare5_m : in std_logic_vector(n-1 downto 0);
				  reshare6_m : in std_logic_vector(n-1 downto 0);
				  
				  z0 		: out std_logic_vector(n-1 downto 0);
				  z1 		: out std_logic_vector(d-1 downto 0));
	end component;

	component ShiftRows is
		 Generic ( d : integer := 8;
					  n : integer := 8);
		 Port ( x0 : in  std_logic_vector(16*n-1 downto 0);
				  x1 : in  std_logic_vector(16*d-1 downto 0);
				  z0 : out std_logic_vector(16*n-1 downto 0);
				  z1 : out std_logic_vector(16*d-1 downto 0));
	end component;

	component MixColumns is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  Mul2 : std_logic_vector := Mul2;
					  Mul3 : std_logic_vector := Mul3);
		 Port ( x0 : in  std_logic_vector(16*n-1 downto 0);
				  x1 : in  std_logic_vector(16*d-1 downto 0);
				  z0 : out std_logic_vector(16*n-1 downto 0);
				  z1 : out std_logic_vector(16*d-1 downto 0));
	end component;

	signal state0_in, state0, state0_key, state0_sbox, state0_sr, state0_mc, state0_final : std_logic_vector(16*n-1 downto 0);
	signal state1_in, state1, state1_key, state1_sbox, state1_sr, state1_mc, state1_final : std_logic_vector(16*d-1 downto 0);

begin

	-- select round input
	state0_in <= x0 when (take_input = '1') else state0_final;
	state1_in <= x1 when (take_input = '1') else state1_final;
	
	-- sync barrier
	RegIn_inst_state0 : RegFDE_srst Generic Map (SIZE => 16*n) Port Map (clk, en, rst, state0_in, state0);
	RegIn_inst_state1 : RegFDE_srst Generic Map (SIZE => 16*d) Port Map (clk, en, rst, state1_in, state1);
	
	-- add round key
	AddRoundKey_inst: AddRoundKey
		generic map ( d => d, n => n )
		port map ( x0 => state0, x1 => state1, key0 => key0, key1 => key1, z0 => state0_key, z1 => state1_key );
	
	-- s-boxes
	gen_sboxes: for i in 0 to 15 generate
	
		Sbox_inst: Sbox
			generic map ( d => d, n => n, m => m, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
			port map ( x0 => state0_key(i*n+n-1 downto i*n), x1 => state1_key(i*d+d-1 downto i*d),  
						  reshare0_m => randomness( 7+i*56 downto  0+i*56), --randomness(895 downto 0);
						  reshare1_m => randomness(15+i*56 downto  8+i*56),
						  reshare2_m => randomness(23+i*56 downto 16+i*56),
						  reshare3_m => randomness(31+i*56 downto 24+i*56),
						  reshare4_m => randomness(39+i*56 downto 32+i*56),
						  reshare5_m => randomness(47+i*56 downto 40+i*56),
						  reshare6_m => randomness(55+i*56 downto 48+i*56),
						  z0 => state0_sbox(i*n+n-1 downto i*n), z1 => state1_sbox(i*d+d-1 downto i*d));
	end generate;
	
	-- shift rows
	ShiftRows_inst: ShiftRows
		generic map ( d => d, n => n )
		port map ( x0 => state0_sbox, x1 => state1_sbox, z0 => state0_sr, z1 => state1_sr );
	
	-- mix columns
	MixColumns_inst: MixColumns
		generic map ( d => d, n => n, m => m, Mul2 => Mul2, Mul3 => Mul3 )
		port map ( x0 => state0_sr, x1 => state1_sr, z0 => state0_mc, z1 => state1_mc );
	
	state0_final <= state0_sr when (last_round = '1') else state0_mc;
	state1_final <= state1_sr when (last_round = '1') else state1_mc;
	
	-- map state to output
	z0 <= state0_key;
	z1 <= state1_key;

end Behavioral;

