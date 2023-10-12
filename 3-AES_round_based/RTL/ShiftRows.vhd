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

entity ShiftRows is
    Generic ( d : integer := 8;
				  n : integer := 8);
	 Port ( x0 : in  std_logic_vector(0 to 16*n-1);
		     x1 : in  std_logic_vector(0 to 16*d-1);
		     z0 : out std_logic_vector(0 to 16*n-1);
		     z1 : out std_logic_vector(0 to 16*d-1));
end ShiftRows;

architecture Behavioral of ShiftRows is

begin

	z0( 0*n to  0*n+n-1) <= x0( 0*n to  0*n+n-1);
	z1( 0*d to  0*d+d-1) <= x1( 0*d to  0*d+d-1);
	z0(13*n to 13*n+n-1) <= x0( 1*n to  1*n+n-1);
	z1(13*d to 13*d+d-1) <= x1( 1*d to  1*d+d-1);
	z0(10*n to 10*n+n-1) <= x0( 2*n to  2*n+n-1);
	z1(10*d to 10*d+d-1) <= x1( 2*d to  2*d+d-1);
	z0( 7*n to  7*n+n-1) <= x0( 3*n to  3*n+n-1);
	z1( 7*d to  7*d+d-1) <= x1( 3*d to  3*d+d-1);
	z0( 4*n to  4*n+n-1) <= x0( 4*n to  4*n+n-1);
	z1( 4*d to  4*d+d-1) <= x1( 4*d to  4*d+d-1);
	z0( 1*n to  1*n+n-1) <= x0( 5*n to  5*n+n-1);
	z1( 1*d to  1*d+d-1) <= x1( 5*d to  5*d+d-1);
	z0(14*n to 14*n+n-1) <= x0( 6*n to  6*n+n-1);
	z1(14*d to 14*d+d-1) <= x1( 6*d to  6*d+d-1);
	z0(11*n to 11*n+n-1) <= x0( 7*n to  7*n+n-1);
	z1(11*d to 11*d+d-1) <= x1( 7*d to  7*d+d-1);
	z0( 8*n to  8*n+n-1) <= x0( 8*n to  8*n+n-1);
	z1( 8*d to  8*d+d-1) <= x1( 8*d to  8*d+d-1);
	z0( 5*n to  5*n+n-1) <= x0( 9*n to  9*n+n-1);
	z1( 5*d to  5*d+d-1) <= x1( 9*d to  9*d+d-1);
	z0( 2*n to  2*n+n-1) <= x0(10*n to 10*n+n-1);
	z1( 2*d to  2*d+d-1) <= x1(10*d to 10*d+d-1);
	z0(15*n to 15*n+n-1) <= x0(11*n to 11*n+n-1);
	z1(15*d to 15*d+d-1) <= x1(11*d to 11*d+d-1);
	z0(12*n to 12*n+n-1) <= x0(12*n to 12*n+n-1);
	z1(12*d to 12*d+d-1) <= x1(12*d to 12*d+d-1);
	z0( 9*n to  9*n+n-1) <= x0(13*n to 13*n+n-1);
	z1( 9*d to  9*d+d-1) <= x1(13*d to 13*d+d-1);
	z0( 6*n to  6*n+n-1) <= x0(14*n to 14*n+n-1);
	z1( 6*d to  6*d+d-1) <= x1(14*d to 14*d+d-1);
	z0( 3*n to  3*n+n-1) <= x0(15*n to 15*n+n-1);
	z1( 3*d to  3*d+d-1) <= x1(15*d to 15*d+d-1);

end Behavioral;

