library ieee;
use ieee.std_logic_1164.all;
use work.alu_pkg.all;

entity alu_VIO is
  generic (
    N : integer := 8
  );
  port(
    clk : in std_logic
  );
end entity;

architecture alu_VIO_arq of alu_VIO is
  -- Señales
  signal A, B : std_logic_vector(N-1 downto 0);
  signal OP   : std_logic_vector(3 downto 0);
  signal Y    : std_logic_vector(N-1 downto 0);
  signal Z, C, V, Nf : std_logic;

  -- Vectores de 1 bit para el VIO
  signal Z_vec  : std_logic_vector(0 downto 0);
  signal C_vec  : std_logic_vector(0 downto 0);
  signal V_vec  : std_logic_vector(0 downto 0);
  signal Nf_vec : std_logic_vector(0 downto 0);

  -- Declaración del VIO
  component vio
    port (
      clk : in  std_logic;
      probe_in0 : in  std_logic_vector(N-1 downto 0);
      probe_in1 : in  std_logic_vector(0 downto 0);
      probe_in2 : in  std_logic_vector(0 downto 0);
      probe_in3 : in  std_logic_vector(0 downto 0);
      probe_in4 : in  std_logic_vector(0 downto 0);
      probe_out0 : out std_logic_vector(N-1 downto 0);
      probe_out1 : out std_logic_vector(N-1 downto 0);
      probe_out2 : out std_logic_vector(3 downto 0)
    );
  end component;
begin
  -- ALU parametrizada
  alu_inst: entity work.alu
    generic map (N => N)
    port map (
      A  => A,
      B  => B,
      OP => OP,
      Y  => Y,
      Z  => Z,
      C  => C,
      V  => V,
      Nf => Nf
    );

  -- Adaptación de señales escalares a vectores
  Z_vec(0)  <= Z;
  C_vec(0)  <= C;
  V_vec(0)  <= V;
  Nf_vec(0) <= Nf;

  -- VIO
  vio_inst : vio
    port map (
      clk        => clk,
      probe_in0  => Y,
      probe_in1  => Z_vec,
      probe_in2  => C_vec,
      probe_in3  => V_vec,
      probe_in4  => Nf_vec,
      probe_out0 => A,
      probe_out1 => B,
      probe_out2 => OP
    );
end architecture;
