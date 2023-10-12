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

entity Circuit is
    Generic ( d    : integer := 8;
				  n    : integer := 8;
				  m    : integer := 8;
				  Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101";
				  Mul3 : std_logic_vector := "1001011000000000110010110000000001100101000000000010010000000000000100100000000010011111000000000101100100000000001011000000000000000000100101100000000011001011000000000110010100000000001001000000000000010010000000001001111100000000010110010000000000101100";
				  RInv : std_logic_vector := "1011001101101011001110000010101101110110000000110001100100010001";
				  R    : std_logic_vector := "1010011101010000000101110011010000000011010010100011000100110101";
				  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
				  T    : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011";
				  poly : std_logic_vector := "10000000000000011";
				  A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
				  Q0	 : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
				  Q1	 : std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
				  Q3	 : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
				  C	 : std_logic_vector := x"009b");
    Port ( clk 	    : in  std_logic;
			  rst 	    : in  std_logic;
			  en			 : in  std_logic;
			  en_in      : in  std_logic;
			  en_out     : in  std_logic;
			  x0 		    : in  std_logic_vector(127 downto 0);
           x1 		    : in  std_logic_vector(127 downto 0);
			  key0 	    : in  std_logic_vector(127 downto 0);
           key1 	    : in  std_logic_vector(127 downto 0);
			  
			  randomness : in  std_logic_vector(1119 downto 0); -- 8*7*(16+4)
			  
			  prng_en    : out std_logic;
			  done       : out std_logic;
           z0 		    : out std_logic_vector(127 downto 0);
           z1 		    : out std_logic_vector(127 downto 0));
end Circuit;

architecture Behavioral of Circuit is

	component TransformInputBytes is
		Generic ( bytes : integer := 16;
					 d     : integer := 8;
					 n     : integer := 8;
					 m     : integer := 8;
					 R     : std_logic_vector := R;
					 TInv  : std_logic_vector := TInv);
		Port ( x0 				 : in  std_logic_vector(bytes*n-1 downto 0);
				 x1 				 : in  std_logic_vector(bytes*d-1 downto 0);
				 x0_transformed : out std_logic_vector(bytes*n-1 downto 0);
				 x1_transformed : out std_logic_vector(bytes*d-1 downto 0));
	end component;
	
	component TransformInputReshare is
		 Generic ( d     : integer := 8;
					  n     : integer := 8;
					  m     : integer := 8;
					  TInv  : std_logic_vector := TInv);
		 Port ( x0 : in  std_logic_vector(  n-1 downto 0);
				  x1 : in  std_logic_vector(  d-1 downto 0);
				  x  : out std_logic_vector(d+n-1 downto 0));
	end component;

	component TransformOutputBytes is
		 Generic ( bytes : integer := 16;
					  d     : integer := 8;
					  n     : integer := 8;
					  m     : integer := 8;
					  RInv  : std_logic_vector := RInv;
					  T 	  : std_logic_vector := T);
		 Port ( z0_transformed : in  std_logic_vector(bytes*n-1 downto 0);
				  z1_transformed : in  std_logic_vector(bytes*d-1 downto 0);
				  z0  			  : out std_logic_vector(bytes*n-1 downto 0);
				  z1  			  : out std_logic_vector(bytes*d-1 downto 0));
	end component;

	component RegFDE_srst is
		 Generic (SIZE : POSITIVE := n+d);
		 Port ( CLK : in STD_LOGIC;
				  EN : in STD_LOGIC;
				  RST : in STD_LOGIC;
				  D : in STD_LOGIC_VECTOR ((SIZE-1) downto 0);
				  Q : out STD_LOGIC_VECTOR ((SIZE-1) downto 0));
	end component;
	
	component AES_Control is
		Generic ( d    : integer := 8;
				    n    : integer := 8);
		Port ( clk 		   : in  std_logic;
				 rst 		   : in  std_logic;
				 en  		   : in  std_logic;
				 take_input : out std_logic;
				 last_round : out std_logic;
				 en_round   : out std_logic;
				 rst_core   : out std_logic;
				 done  	   : out std_logic);
	end component;
	
	component AES_Round is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  Mul2 : std_logic_vector := Mul2;
				     Mul3 : std_logic_vector := Mul3;
					  TInv : std_logic_vector := TInv;
					  poly : std_logic_vector := poly;
					  A    : std_logic_vector := A;
					  Q0	 : std_logic_vector := Q0;
					  Q1	 : std_logic_vector := Q1;
					  Q3	 : std_logic_vector := Q3;
					  C	 : std_logic_vector := C);
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
	end component;

	component AES_Key_Schedule_Round is
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
			    randomness : in  std_logic_vector(   223 downto 0);
				 round_key0 : out std_logic_vector(16*n-1 downto 0);
				 round_key1 : out std_logic_vector(16*d-1 downto 0));
	end component;
	
	-- inputs in transformed domain
	signal x0_transformed_in, key0_transformed_in : std_logic_vector(16*n-1 downto 0);
	signal x1_transformed_in, key1_transformed_in : std_logic_vector(16*d-1 downto 0);
	
	-- inputs in transformed domain (synchronized)
	signal x0_transformed, key0_transformed : std_logic_vector(16*n-1 downto 0);
	signal x1_transformed, key1_transformed : std_logic_vector(16*d-1 downto 0);
	
	-- AES intermediate states
	signal state0 : std_logic_vector(16*n-1 downto 0);
	signal state1 : std_logic_vector(16*d-1 downto 0);
	
	-- outputs in transformed domain
	signal z0_out : std_logic_vector(16*n-1 downto 0);
	signal z1_out : std_logic_vector(16*d-1 downto 0);
	
	-- control core
	signal take_input, last_round, en_round, rst_core : std_logic := '0';
	
	-- key schedule
	signal round_key0 : std_logic_vector(16*n-1 downto 0);
	signal round_key1 : std_logic_vector(16*d-1 downto 0);
	
begin

	-----------------------------------------------------------------------------------------------------------
	-- transform inputs
	-----------------------------------------------------------------------------------------------------------
	-- x
	TransformInput_inst_x: TransformInputBytes
		generic map ( bytes => 16, d => d, n => n, m => m, R => R, TInv => TInv )
		port map ( x0 => x0, x1 => x1, x0_transformed => x0_transformed_in, x1_transformed => x1_transformed_in );
	
	-- key
	TransformInput_inst_key: TransformInputBytes
		generic map ( bytes => 16, d => d, n => n, m => m, R => R, TInv => TInv )
		port map ( x0 => key0, x1 => key1, x0_transformed => key0_transformed_in, x1_transformed => key1_transformed_in );

	-- sync barrier (inputs)
	RegIn_inst_x0   : RegFDE_srst Generic Map (SIZE => 16*n) Port Map (clk, en_in, rst, x0_transformed_in,   x0_transformed);
	RegIn_inst_x1   : RegFDE_srst Generic Map (SIZE => 16*d) Port Map (clk, en_in, rst, x1_transformed_in,   x1_transformed);
	RegIn_inst_key0 : RegFDE_srst Generic Map (SIZE => 16*n) Port Map (clk, en_in, rst, key0_transformed_in, key0_transformed);
	RegIn_inst_key1 : RegFDE_srst Generic Map (SIZE => 16*d) Port Map (clk, en_in, rst, key1_transformed_in, key1_transformed);

	-----------------------------------------------------------------------------------------------------------
	-- AES
	-----------------------------------------------------------------------------------------------------------
	-- control
	AES_Control_inst: AES_Control
		generic map ( d => d, n => n )
		port map ( clk => clk, rst => rst, en => en, take_input => take_input, last_round => last_round, en_round => en_round, rst_core => rst_core, done => done );
	
	prng_en <= rst or en_round;
	
	-- round function
	AES_Round_inst: AES_Round
		generic map ( d => d, n => n, m => m, Mul2 => Mul2, Mul3 => Mul3, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( clk => clk, rst => rst, en => en_round, last_round => last_round, take_input => take_input, x0 => x0_transformed, x1 => x1_transformed, key0 => round_key0, key1 => round_key1, randomness => randomness(895 downto 0), z0 => state0, z1 => state1 );

	-- key schedule round
	AES_Key_Schedule_Round_inst: AES_Key_Schedule_Round
		generic map ( d => d, n => n, m => m, TInv => TInv, Mul2 => Mul2, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( clk => clk, en => en_round, rst => rst, take_input => take_input, key0 => key0_transformed, key1 => key1_transformed, randomness => randomness(1119 downto 896), round_key0 => round_key0, round_key1 => round_key1 );
	
	-----------------------------------------------------------------------------------------------------------
	-- transform outputs
	-----------------------------------------------------------------------------------------------------------
	-- sync barrier (output)
	RegOut_inst_z0 : RegFDE_srst Generic Map (SIZE => 16*n) Port Map (clk, en_out, rst, state0, z0_out);
	RegOut_inst_z1 : RegFDE_srst Generic Map (SIZE => 16*d) Port Map (clk, en_out, rst, state1, z1_out);
	
	-- transform output
	TransformOutput_inst_z: TransformOutputBytes
		generic map ( bytes => 16, d => d, n => n, m => m, RInv => RInv, T => T )
		port map ( z0_transformed => z0_out, z1_transformed => z1_out, z0 => z0, z1 => z1 );
	

end Behavioral;

