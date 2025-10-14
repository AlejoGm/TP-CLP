library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_pkg.all;

entity tb_alu is
end entity;

architecture tb_alu_arq of tb_alu is
  constant N : integer := 8;

  signal A, B : std_logic_vector(N-1 downto 0);
  signal OP   : std_logic_vector(3 downto 0);
  signal Y    : std_logic_vector(N-1 downto 0);
  signal Z, C, V, Nf : std_logic;
begin
  -- Instancia de la ALU
  dut: entity work.alu
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

  process
  begin
    -------------------------------------------------------------------
    -- ADD overflow: 0x7F + 0x01 = 0x80  V=1 (overflow)
    -------------------------------------------------------------------
    A <= x"7F"; B <= x"01"; OP <= OP_ADD; wait for 10 ns;
    assert (Y = x"80" and ( V = '1')  and ( Nf = '1' ) )
      report "Fallo ADD overflow positivo" severity failure;

    -------------------------------------------------------------------
    -- ADD no overflow negativo
    -------------------------------------------------------------------
    A <= x"C0"; B <= x"C0"; OP <= OP_ADD; wait for 10 ns;
    assert (Y = x"80" and V = '0' and C = '1')
      report "Fallo ADD overflow negativo" severity failure;

    -------------------------------------------------------------------
    -- ADD máximo
    -------------------------------------------------------------------
    A <= x"FF"; B <= x"FF"; OP <= OP_ADD; wait for 10 ns;
    assert (Y = x"FE" and C = '1')
      report "Fallo ADD máximo" severity failure;

    -------------------------------------------------------------------
    -- SUB sin borrow
    -------------------------------------------------------------------
    A <= x"05"; B <= x"01"; OP <= OP_SUB; wait for 10 ns;
    assert (Y = x"04" and C = '1' and V = '0')
      report "Fallo SUB sin borrow" severity failure;

    -------------------------------------------------------------------
    -- SUB con borrow
    -------------------------------------------------------------------
    A <= x"00"; B <= x"01"; OP <= OP_SUB; wait for 10 ns;
    assert (Y = x"FF" and C = '0')
      report "Fallo SUB con borrow" severity failure;

    -------------------------------------------------------------------
    -- SUB igual negativo
    -------------------------------------------------------------------
    A <= x"80"; B <= x"80"; OP <= OP_SUB; wait for 10 ns;
    assert (Y = x"00" and Z = '1')
      report "Fallo SUB igual negativo" severity failure;
      
    -------------------------------------------------------------------
    -- AND con cero
    -------------------------------------------------------------------
    A <= x"AA"; B <= x"00"; OP <= OP_AND; wait for 10 ns;
    assert (Y = x"00" and Z = '1')
      report "Fallo AND con cero" severity failure;

    -------------------------------------------------------------------
    -- OR
    -------------------------------------------------------------------
    A <= x"A0"; B <= x"0F"; OP <= OP_OR; wait for 10 ns;
    assert (Y = x"AF")
      report "Fallo OR" severity failure;

    -------------------------------------------------------------------
    -- XOR complementario
    -------------------------------------------------------------------
    A <= x"AA"; B <= x"55"; OP <= OP_XOR; wait for 10 ns;
    assert (Y = x"FF")
      report "Fallo XOR complementario" severity failure;

    -------------------------------------------------------------------
    -- Zero flag
    -------------------------------------------------------------------
    A <= x"5A"; B <= x"5A"; OP <= OP_XOR; wait for 10 ns;
    assert (Z = '1' and Y = x"00")
      report "Fallo bandera Zero" severity failure;

    -------------------------------------------------------------------
    -- SLL total
    -------------------------------------------------------------------
    A <= x"01"; B <= std_logic_vector(to_unsigned(7,N)); OP <= OP_SLL; wait for 10 ns;
    assert (Y = x"80")
      report "Fallo SLL total" severity failure;

    -------------------------------------------------------------------
    -- SRL total
    -------------------------------------------------------------------
    A <= x"80"; B <= std_logic_vector(to_unsigned(7,N)); OP <= OP_SRL; wait for 10 ns;
    assert (Y = x"01")
      report "Fallo SRL total" severity failure;

    -------------------------------------------------------------------
    -- SRA con extensión de signo
    -------------------------------------------------------------------
    A <= x"F0"; B <= std_logic_vector(to_unsigned(4,N)); OP <= OP_SRA; wait for 10 ns;
    assert (Y = x"FF")
      report "Fallo SRA extensión de signo" severity failure;

    -------------------------------------------------------------------
    -- SLT signed negativo < positivo
    -------------------------------------------------------------------
    A <= x"F0"; B <= x"10"; OP <= OP_SLT; wait for 10 ns;
    assert (Y = x"01")
      report "Fallo SLT signed negativo < positivo" severity failure;

    -------------------------------------------------------------------
    -- SLT signed positivo >= negativo
    -------------------------------------------------------------------
    A <= x"10"; B <= x"F0"; OP <= OP_SLT; wait for 10 ns;
    assert (Y = x"00")
      report "Fallo SLT signed positivo >= negativo" severity failure;

    -------------------------------------------------------------------
    -- SLTU unsigned (255 > 1)
    -------------------------------------------------------------------
    A <= x"FF"; B <= x"01"; OP <= OP_SLTU; wait for 10 ns;
    assert (Y = x"00")
      report "Fallo SLTU unsigned mayor" severity failure;

    -------------------------------------------------------------------
    report "Todas las pruebas completadas correctamente" severity note;
    wait;
  end process;
end architecture;
