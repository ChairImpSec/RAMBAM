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
				  poly : std_logic_vector := "10000000000000011");
    Port ( clk 	: in std_logic;
			  rst 	: in std_logic;
			  en_in  : in std_logic;
			  en_out : in std_logic;
			  x0 		: in  std_logic_vector(n-1 downto 0);
           x1 		: in  std_logic_vector(n-1 downto 0);
           y0 		: in  std_logic_vector(n-1 downto 0);
           y1 		: in  std_logic_vector(n-1 downto 0);
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

	signal x,    y,    z     : std_logic_vector(d+n-1 downto 0);
	signal x_in, y_in, z_out : std_logic_vector(d+n-1 downto 0);

begin

	-- transform inputs
	TransformInput_inst0: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => x0, x1 => x1, x => x_in );
		
	TransformInput_inst1: TransformInputDomain
		generic map ( n => n, m => m, TInv => TInv )
		port map ( x0 => y0, x1 => y1, x => y_in );

	-- sync barrier
	RegIn_inst0 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, x_in, x);
	RegIn_inst1 : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_in, rst, y_in, y);

	-- multiplication
	Multiplication_inst: VectorMultiplicationMod
		generic map ( n => n+d, poly => poly )
		port map ( x => x, y => y, z => z );
	
	-- sync barrier
	RegOut_inst : RegFDE_srst Generic Map (SIZE => n+d) Port Map (clk, en_out, rst, z, z_out);
	
	-- transform output
	TransformOutput_inst: TransformOutputDomain
		generic map ( n => n, m => m, T => T )
		port map ( x => z_out, x0 => z0, x1 => z1 );

end Behavioral;

