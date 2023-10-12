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

entity round_constant is
	Generic ( d    : integer := 8;
				 n    : integer := 8;
				 m    : integer := 8;
				 Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101");
	Port ( clk   : in  std_logic;
			 en    : in  std_logic;
			 rst   : in  std_logic;
			 start : in  std_logic;
			 rc    : out std_logic_vector(d+n-1 downto 0));
end round_constant;

architecture Behavioral of round_constant is

	component RegFDE_srst is
		 Generic (SIZE : POSITIVE := n+d);
		 Port ( CLK : in std_logic;
				  EN  : in std_logic;
				  RST : in std_logic;
				  D   : in std_logic_vector ((SIZE-1) downto 0);
				  Q   : out std_logic_vector ((SIZE-1) downto 0));
	end component;

	component MatrixMultiplication is
		 Generic (n : integer := d+n;
					 m : integer := d+m;
					 C : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001");
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

	signal rc_state_init, rc_state_selected, rc_state, rc_state_multiplied : std_logic_vector(d+n-1 downto 0);

begin

	-- init
	rc_state_init(d+n-1 downto 1) <= (others => '0');
	rc_state_init(0)					<= '1';
	
	-- loop select
	rc_state_selected <= rc_state_init when (start = '1') else rc_state_multiplied;
	
	-- sync
	RegIn_inst_state0 : RegFDE_srst Generic Map (SIZE => 16) Port Map (clk, en, rst, rc_state_selected, rc_state);
	rc <= rc_state;
	
	-- mul by 2
	matrix_mul_inst0: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul2 )
		port map ( x => rc_state, y => rc_state_multiplied );

end Behavioral;

