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

entity Sbox is
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
end Sbox;

architecture Behavioral of Sbox is

	component TransformInputReshare is
		 Generic ( d     : integer := 8;
					  n     : integer := 8;
					  m     : integer := 8;
					  TInv  : std_logic_vector := TInv);
		 Port ( x0 : in  std_logic_vector(  n-1 downto 0);
				  x1 : in  std_logic_vector(  d-1 downto 0);
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

	signal x, z : std_logic_vector(d+n-1 downto 0);

	signal t2, t3, t12, t14, t15, t240, t254, r : std_logic_vector(d+n-1 downto 0);
	signal t2_reshared, t3_reshared, t12_reshared, t14_reshared, t15_reshared, t240_reshared, t254_reshared : std_logic_vector(d+n-1 downto 0);

	signal reshare0, reshare1, reshare2, reshare3, reshare4, reshare5, reshare6 : std_logic_vector(d+n-1 downto 0);

begin

	-----------------------------------------------------------------------------------------------------------
	-- transform reshares
	-----------------------------------------------------------------------------------------------------------
	x(  n-1 downto 0) <= x0;
	x(d+n-1 downto n) <= x1;
	
	TransformInput_inst1: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare0_m, x1 => reshare0_m, x => reshare0 );

	TransformInput_inst2: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare1_m, x1 => reshare1_m, x => reshare1 );
		
	TransformInput_inst3: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare2_m, x1 => reshare2_m, x => reshare2 );
		
	TransformInput_inst4: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare3_m, x1 => reshare3_m, x => reshare3 );
		
	TransformInput_inst5: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare4_m, x1 => reshare4_m, x => reshare4 );
		
	TransformInput_inst6: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare5_m, x1 => reshare5_m, x => reshare5 );
		
	TransformInput_inst7: TransformInputReshare
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => reshare6_m, x1 => reshare6_m, x => reshare6 );

	-----------------------------------------------------------------------------------------------------------
	-- S-box
	-----------------------------------------------------------------------------------------------------------
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
	-- transform output
	-----------------------------------------------------------------------------------------------------------
	z0 <= z(  n-1 downto 0);
	z1 <= z(d+n-1 downto n);

end Behavioral;

