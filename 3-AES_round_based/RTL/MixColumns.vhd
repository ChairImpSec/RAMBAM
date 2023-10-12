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

entity MixColumns is
    Generic ( d    : integer := 8;
				  n    : integer := 8;
				  m    : integer := 8;
				  Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101";
				  Mul3 : std_logic_vector := "1001011000000000110010110000000001100101000000000010010000000000000100100000000010011111000000000101100100000000001011000000000000000000100101100000000011001011000000000110010100000000001001000000000000010010000000001001111100000000010110010000000000101100");
    Port ( x0 : in  std_logic_vector(0 to 16*n-1);
           x1 : in  std_logic_vector(0 to 16*n-1);
           z0 : out std_logic_vector(0 to 16*n-1);
           z1 : out std_logic_vector(0 to 16*n-1));
end MixColumns;

architecture Behavioral of MixColumns is

	component MixColumn is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  Mul2 : std_logic_vector := Mul2;
					  Mul3 : std_logic_vector := Mul3);
		 Port ( E1_in  : in  std_logic_vector(0 to d+n-1);
				  E2_in  : in  std_logic_vector(0 to d+n-1);
				  E3_in  : in  std_logic_vector(0 to d+n-1);
				  E4_in  : in  std_logic_vector(0 to d+n-1);
				  E1_out : out std_logic_vector(0 to d+n-1);
				  E2_out : out std_logic_vector(0 to d+n-1);
				  E3_out : out std_logic_vector(0 to d+n-1);
				  E4_out : out std_logic_vector(0 to d+n-1));
	end component;
	
	type E_array_type is array (0 to 3) of std_logic_vector(0 to d+n-1);
	
	signal E1_in,  E2_in,  E3_in,  E4_in  : E_array_type;
	signal E1_out, E2_out, E3_out, E4_out : E_array_type;

begin

	gen1: for i in 0 to 3 generate
	
		E1_in(i) <= x1(4*d*i+0*d to 4*d*i+(1*d-1)) & x0(4*n*i+0*n to 4*n*i+(1*n-1));
		E2_in(i) <= x1(4*d*i+1*d to 4*d*i+(2*d-1)) & x0(4*n*i+1*n to 4*n*i+(2*n-1));
		E3_in(i) <= x1(4*d*i+2*d to 4*d*i+(3*d-1)) & x0(4*n*i+2*n to 4*n*i+(3*n-1));
		E4_in(i) <= x1(4*d*i+3*d to 4*d*i+(4*d-1)) & x0(4*n*i+3*n to 4*n*i+(4*n-1));
		
		MixColumn_inst : MixColumn
			Generic Map ( d => d, n => n, m => m, Mul2 => Mul2, Mul3 => Mul3 )
			Port Map ( E1_in  => E1_in(i),  E2_in  => E2_in(i),  E3_in  => E3_in(i),  E4_in  => E4_in(i),
						  E1_out => E1_out(i), E2_out => E2_out(i), E3_out => E3_out(i), E4_out => E4_out(i) );
			
		z1(4*n*i+0*n to 4*n*i+(1*n-1)) <= E1_out(i)(0 to   n-1);
		z0(4*d*i+0*d to 4*d*i+(1*d-1)) <= E1_out(i)(n to d+n-1);
		z1(4*n*i+1*n to 4*n*i+(2*n-1)) <= E2_out(i)(0 to   n-1);
		z0(4*d*i+1*d to 4*d*i+(2*d-1)) <= E2_out(i)(n to d+n-1);
		z1(4*n*i+2*n to 4*n*i+(3*n-1)) <= E3_out(i)(0 to   n-1);
		z0(4*d*i+2*d to 4*d*i+(3*d-1)) <= E3_out(i)(n to d+n-1);
		z1(4*n*i+3*n to 4*n*i+(4*n-1)) <= E4_out(i)(0 to   n-1);
		z0(4*d*i+3*d to 4*d*i+(4*d-1)) <= E4_out(i)(n to d+n-1);
	
	end generate;

end Behavioral;

