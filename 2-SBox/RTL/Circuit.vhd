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
				  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
				  T    : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011";
				  poly : std_logic_vector := "10000000000000011";
				  A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
				  Q0	 : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
				  Q1	 : std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
				  Q3	 : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
				  C	 : std_logic_vector := x"009b");
    Port ( clk 	: in std_logic;
			  rst 	: in std_logic;
			  en_in  : in std_logic;
			  en_out : in std_logic;
			  x0 		: in  std_logic_vector(n-1 downto 0);
           x1 		: in  std_logic_vector(n-1 downto 0);
			  
			  reshare0_m : in  std_logic_vector(n-1 downto 0);
			  reshare1_m : in  std_logic_vector(n-1 downto 0);
			  reshare2_m : in  std_logic_vector(n-1 downto 0);
			  reshare3_m : in  std_logic_vector(n-1 downto 0);
			  reshare4_m : in  std_logic_vector(n-1 downto 0);
			  reshare5_m : in  std_logic_vector(n-1 downto 0);
			  reshare6_m : in  std_logic_vector(n-1 downto 0);
			  
           z0 		: out std_logic_vector(n-1 downto 0);
           z1 		: out std_logic_vector(n-1 downto 0));
end Circuit;

architecture Behavioral of Circuit is

	component TransformInputDomain is
		 Generic ( n    : integer := n;
					  m    : integer := m;
					  TInv : std_logic_vector := TInv);
		 Port ( x0 : in  std_logic_vector(  n-1 downto 0);
				  x1 : in  std_logic_vector(  n-1 downto 0);
				  x  : out std_logic_vector(d+n-1 downto 0));
	end component;

	component VectorMultiplicationMod is
		 Generic ( n    : integer := n+d;
					  poly : std_logic_vector := poly);
		 Port ( x 		: in  std_logic_vector(n-1 downto 0);
				  y 		: in  std_logic_vector(n-1 downto 0);
				  z 		: out std_logic_vector(n-1 downto 0));
	end component;

	component MatrixMultiplication is
		 Generic (n : integer := d+n;
					 m : integer := d+m;
					 C: std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001");
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

	component TransformOutputDomain is
		 Generic ( n : integer := n;
					  m : integer := m;
					  T : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011");
		 Port ( x  : in  std_logic_vector(d+n-1 downto 0);
				  x0 : out std_logic_vector(  n-1 downto 0);
				  x1 : out std_logic_vector(  n-1 downto 0));
	end component;

	component RegFDE_srst is
		 Generic (SIZE : POSITIVE := n+d);
		 Port ( CLK : in STD_LOGIC;
				  EN : in STD_LOGIC;
				  RST : in STD_LOGIC;
				  D : in STD_LOGIC_VECTOR ((SIZE-1) downto 0);
				  Q : out STD_LOGIC_VECTOR ((SIZE-1) downto 0));
	end component;

	constant Matrix_C : std_logic_vector(0 to 15) := C;

	signal x,    z     : std_logic_vector(d+n-1 downto 0);
	signal x_in, z_out : std_logic_vector(d+n-1 downto 0);

	signal t2, t3, t12, t14, t15, t240, t254, r : std_logic_vector(d+n-1 downto 0);
	signal t2_reshared, t3_reshared, t12_reshared, t14_reshared, t15_reshared, t240_reshared, t254_reshared : std_logic_vector(d+n-1 downto 0);

	signal reshare0_in, reshare1_in, reshare2_in, reshare3_in, reshare4_in, reshare5_in, reshare6_in : std_logic_vector(d+n-1 downto 0);
	signal reshare0, reshare1, reshare2, reshare3, reshare4, reshare5, reshare6 : std_logic_vector(d+n-1 downto 0);

begin

	-- transform inputs
	-- x
	TransformInput_inst0: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => x0, x1 => x1, x => x_in );
	
	-- reshares
	TransformInput_inst1: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare0_m, x1 => reshare0_m, x => reshare0_in );

	TransformInput_inst2: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare1_m, x1 => reshare1_m, x => reshare1_in );
		
	TransformInput_inst3: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare2_m, x1 => reshare2_m, x => reshare2_in );
		
	TransformInput_inst4: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare3_m, x1 => reshare3_m, x => reshare3_in );
		
	TransformInput_inst5: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare4_m, x1 => reshare4_m, x => reshare4_in );
		
	TransformInput_inst6: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare5_m, x1 => reshare5_m, x => reshare5_in );
		
	TransformInput_inst7: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare6_m, x1 => reshare6_m, x => reshare6_in );

	-- sync barrier
	RegIn_instX : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, x_in, x);
	RegIn_inst0 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare0_in, reshare0);
	RegIn_inst1 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare1_in, reshare1);
	RegIn_inst2 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare2_in, reshare2);
	RegIn_inst3 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare3_in, reshare3);
	RegIn_inst4 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare4_in, reshare4);
	RegIn_inst5 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare5_in, reshare5);
	RegIn_inst6 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, reshare6_in, reshare6);

	-----------------------------------------------------------------------------------------------------------
	-- S-box
	
	matrix_mul_inst0: MatrixMultiplication
	generic map (
		n => d+n,
		m => d+m,
		C => Q0
	)
	port map (
		x => x,
		y => t2
	);
	
	t2_reshared <= t2 xor reshare0;
		
	poly_mul_inst0: VectorMultiplicationMod
		generic map ( n => n+d, poly => poly )
		port map ( x => x, y => t2_reshared, z => t3 );
		
	t3_reshared <= t3 xor reshare1;
	
	matrix_mul_inst1: MatrixMultiplication
	generic map (
		n => d+n,
		m => d+m,
		C => Q1
	)
	port map (
		x => t3_reshared,
		y => t12
	);
	
	t12_reshared <= t12 xor reshare2;
	
	poly_mul_inst1: VectorMultiplicationMod
	generic map ( n => n+d, poly => poly )
	port map ( x => t2_reshared, y => t12_reshared, z => t14 );
		
	t14_reshared <= t14 xor reshare3;
	
	poly_mul_inst2: VectorMultiplicationMod
	generic map ( n => n+d, poly => poly )
	port map ( x => t3_reshared, y => t12_reshared, z => t15 );
		
	t15_reshared <= t15 xor reshare4;
	
	matrix_mul_inst2: MatrixMultiplication
	generic map (
		n => d+n,
		m => d+m,
		C => Q3
	)
	port map (
		x => t15_reshared,
		y => t240
	);
	
	t240_reshared <= t240 xor reshare5;
	
	poly_mul_inst3: VectorMultiplicationMod
	generic map ( n => n+d, poly => poly )
	port map ( x => t14_reshared, y => t240_reshared, z => t254 );
	
	t254_reshared <= t254 xor reshare6;

	matrix_mul_inst3: MatrixMultiplication
	generic map (
		n => d+n,
		m => d+m,
		C => A
	)
	port map (
		x => t254_reshared,
		y => r
	);
	
	z <= r xor C;
	
	-----------------------------------------------------------------------------------------------------------
	-- sync barrier
	RegOut_inst : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_out, rst, z, z_out);
	
	-- transform output
	TransformOutput_inst: TransformOutputDomain
		generic map ( n => n, m => m, T => T )
		port map ( x => z_out, x0 => z0, x1 => z1 );

end Behavioral;

