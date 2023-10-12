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

entity AES_Key_Schedule_Round is
	Generic ( d    : integer := 8;
				 n    : integer := 8;
				 m    : integer := 8;
				 TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
				 Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101";
				 poly : std_logic_vector := "10000000000000011";
				 A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
				 Q0	: std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
				 Q1	: std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
				 Q3	: std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
				 C	   : std_logic_vector := x"009b");
	Port ( clk        : in  std_logic;
			 en         : in  std_logic;
			 rst        : in  std_logic;
			 take_input : in  std_logic;
			 key0			: in  std_logic_vector(16*n-1 downto 0);
			 key1			: in  std_logic_vector(16*d-1 downto 0);
			 round_key0 : out std_logic_vector(16*n-1 downto 0);
			 round_key1 : out std_logic_vector(16*d-1 downto 0);
			 randomness : in  std_logic_vector(   223 downto 0));
end AES_Key_Schedule_Round;

architecture Behavioral of AES_Key_Schedule_Round is

	component RegFDE_srst is
		 Generic (SIZE : POSITIVE := n+d);
		 Port ( CLK : in STD_LOGIC;
				  EN  : in STD_LOGIC;
				  RST : in STD_LOGIC;
				  D   : in STD_LOGIC_VECTOR ((SIZE-1) downto 0);
				  Q   : out STD_LOGIC_VECTOR ((SIZE-1) downto 0));
	end component;

	component round_constant is
		Generic ( d    : integer := 8;
					 n    : integer := 8;
					 m    : integer := 8;
					 Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101");
		Port ( clk   : in  std_logic;
				 en    : in  std_logic;
				 rst   : in  std_logic;
				 start : in  std_logic;
				 rc    : out std_logic_vector(d+n-1 downto 0));
	end component;

	component g_function is
		Generic ( d    : integer := 8;
					 n    : integer := 8;
					 m    : integer := 8;
					 TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
					 poly : std_logic_vector := "10000000000000011";
					 A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
					 Q0	: std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
					 Q1	: std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
					 Q3   : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
					 C	   : std_logic_vector := x"009b");
		Port ( g0_func_in 	: in  std_logic_vector(0 to 4*n-1);
				 g1_func_in 	: in  std_logic_vector(0 to 4*d-1);
				 rc            : in  std_logic_vector(d+n-1 downto 0);
				 randomness    : in  std_logic_vector(  223 downto 0);
				 g0_func_out 	: out std_logic_vector(0 to 4*n-1);
				 g1_func_out 	: out std_logic_vector(0 to 4*d-1));
	end component;

	signal rc : std_logic_vector(d+n-1 downto 0);
	
	signal key0_state_selected, key0_state, key0_state_derivated : std_logic_vector(0 to 16*n-1);
	signal key1_state_selected, key1_state, key1_state_derivated : std_logic_vector(0 to 16*d-1);

	signal g0_func_out : std_logic_vector(0 to 4*n-1);
	signal g1_func_out : std_logic_vector(0 to 4*d-1);
	
begin

	-- round constant loop
	round_constant_inst: round_constant
		generic map ( d => d, n => n, m => m, Mul2 => Mul2 )
		port map ( clk => clk, en => en, rst => rst, start => take_input, rc => rc );
	
	-- round key derivation
	key0_state_selected <= key0 when (take_input = '1') else key0_state_derivated;
	key1_state_selected <= key1 when (take_input = '1') else key1_state_derivated;
	
	RegIn_inst_state1 : RegFDE_srst Generic Map (SIZE => 16*n) Port Map (clk, en, rst, key0_state_selected, key0_state);
	RegIn_inst_state2 : RegFDE_srst Generic Map (SIZE => 16*d) Port Map (clk, en, rst, key1_state_selected, key1_state);
	round_key0 <= key0_state;
	round_key1 <= key1_state;
	
	-- g-function
	g_function_inst: g_function
		generic map ( d => d, n => n, m => m, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( g0_func_in => key0_state(3*4*n+0*n to 3*4*n+4*n-1),
					  g1_func_in => key1_state(3*4*d+0*d to 3*4*d+4*d-1),
					  rc => rc,
					  randomness => randomness,
					  g0_func_out => g0_func_out,
					  g1_func_out => g1_func_out );

    -- assemble subkey
	key0_state_derivated(0*4*n to 1*4*n-1) <= key0_state(0*4*n to 1*4*n-1) xor g0_func_out;
	key1_state_derivated(0*4*d to 1*4*d-1) <= key1_state(0*4*d to 1*4*d-1) xor g1_func_out;
	
	key0_state_derivated(1*4*n to 2*4*n-1) <= key0_state_derivated(0*4*n to 1*4*n-1) xor key0_state(1*4*n to 2*4*n-1);
	key1_state_derivated(1*4*d to 2*4*d-1) <= key1_state_derivated(0*4*d to 1*4*d-1) xor key1_state(1*4*d to 2*4*d-1);
	
	key0_state_derivated(2*4*n to 3*4*n-1) <= key0_state_derivated(1*4*n to 2*4*n-1) xor key0_state(2*4*n to 3*4*n-1);
	key1_state_derivated(2*4*d to 3*4*d-1) <= key1_state_derivated(1*4*d to 2*4*d-1) xor key1_state(2*4*d to 3*4*d-1);

	key0_state_derivated(3*4*n to 4*4*n-1) <= key0_state_derivated(2*4*n to 3*4*n-1) xor key0_state(3*4*n to 4*4*n-1);
	key1_state_derivated(3*4*d to 4*4*d-1) <= key1_state_derivated(2*4*d to 3*4*d-1) xor key1_state(3*4*d to 4*4*d-1);

end Behavioral;

