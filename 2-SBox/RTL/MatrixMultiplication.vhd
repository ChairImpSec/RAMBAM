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

entity MatrixMultiplication is
    Generic (n : integer := 8;
	          m : integer := 8;
				 C : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001");
    Port ( x : in  std_logic_vector(m-1 downto 0);
	        y : out std_logic_vector(n-1 downto 0));
end MatrixMultiplication;

architecture Behavioral of MatrixMultiplication is

  type array_m is array (integer range <>) of std_logic_vector(0 to m);
  
  constant Matrix : std_logic_vector(0 to (n*m-1)) := C;
  
  signal Result : array_m(0 to n-1);
  
begin

  Gen1: for i in 0 to n-1 generate
  
    Result(i)(0) <= '0';
	 
    Gen2: for j in 0 to m-1 generate
	   Result(i)(j+1) <= Result(i)(j) XOR (x(j) AND Matrix(i*m + j));
    end generate;
	 
	 y(i) <= Result(i)(m);
  end generate;

end Behavioral;

