# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './data'
require './board'
require 'tet'

class Proc
  def to_i
    self.call(proc { |x| x + 1 }, 0)
  end
end

class Fixnum
  def to_peano
    proc do |func, result|
      self.times { result = func.call(result) }
      result
    end
  end
end

group 'Choice Functions' do
  group 'AND' do
    assert 'returns a FIRST when given two FIRSTs' do
      AND[FIRST, FIRST][true, false]
    end

    assert 'returns a SECOND when given a FIRST and a SECOND' do
      AND[FIRST, SECOND][false, true]
    end

    assert 'returns a SECOND when given two SECONDs' do
      AND[SECOND, SECOND][false, true]
    end
  end
end

group 'Pair Functions' do
  group 'NTH' do
    example = PAIR[:A, PAIR[:B, PAIR[:C, :END]]]

    assert 'gets the first element when given 0' do
      NTH[example, 0.to_peano] == :A
    end

    assert 'gets the third element when given 2' do
      NTH[example, 2.to_peano] == :C
    end
  end
end

group 'Math Functions' do
  group 'ADD' do
    assert 'adds two numbers together' do
      11 == ADD[8.to_peano, 3.to_peano].to_i
    end

    assert 'works with zero' do
      36 == ADD[0.to_peano, 36.to_peano].to_i
    end
  end

  group 'DECREMENT' do
    assert 'subtracts one from the given number' do
      99 == DECREMENT[100.to_peano].to_i
    end

    assert 'given zero returns zero' do
      0 == DECREMENT[0.to_peano].to_i
    end
  end

  group 'SUBTRACT' do
    assert 'subtracts the second number from the first number' do
      10 == SUBTRACT[20.to_peano, 10.to_peano].to_i
    end

    assert 'floors at zero' do
      0 == SUBTRACT[3.to_peano, 5.to_peano].to_i
    end
  end

  group 'MULTIPLY' do
    assert 'multiplies two numbers together' do
      8 == MULTIPLY[2.to_peano, 4.to_peano].to_i
    end

    assert 'works with zero' do
      0 == MULTIPLY[0.to_peano, 23.to_peano].to_i
    end
  end

  group 'DIVIDE' do
    assert 'divides two integers' do
     6 == DIVIDE[30.to_peano, 5.to_peano].to_i
    end

    assert 'rounds down' do
     6 == DIVIDE[32.to_peano, 5.to_peano].to_i
    end
  end

  group 'MODULUS' do
    assert 'returns the remainder of division' do
     2 == MODULUS[12.to_peano, 5.to_peano].to_i
    end

    assert 'returns the first argument when the second argument is larger' do
     4 == MODULUS[4.to_peano, 10.to_peano].to_i
    end
  end
end

group 'Comparison Functions' do
  group 'IF_ZERO' do
    assert 'returns FIRST when given zero' do
      IF_ZERO[0.to_peano][true, false]
    end

    assert 'returns SECOND when given a non-zero number' do
      IF_ZERO[9.to_peano][false, true]
    end
  end

  group 'GREATER_OR_EQUAL' do
    assert 'returns FIRST when greater' do
      GREATER_OR_EQUAL[2.to_peano, 1.to_peano][true, false]
    end

    assert 'returns FIRST when equal' do
      GREATER_OR_EQUAL[5.to_peano, 5.to_peano][true, false]
    end

    assert 'returns SECOND when less' do
      GREATER_OR_EQUAL[4.to_peano, 9.to_peano][false, true]
    end
  end

  group 'EQUAL' do
    assert 'returns FIRST when equal' do
      EQUAL[6.to_peano, 6.to_peano][true, false]
    end

    assert 'returns SECOND when greater' do
      EQUAL[7.to_peano, 2.to_peano][false, true]
    end

    assert 'returns SECOND when less' do
      EQUAL[4.to_peano, 1.to_peano][false, true]
    end
  end
end

group 'Board Functions' do
  group 'POSITION_TO_INDEX' do
    assert 'translates X/Y pair into an array index' do
      POSITION_TO_INDEX[PAIR[2.to_peano, 4.to_peano]].to_i == 34
    end

    assert 'works with zero' do
      POSITION_TO_INDEX[PAIR[6.to_peano, 0.to_peano]].to_i == 6
    end
  end

  group 'INDEX_TO_POSITION' do
    assert 'translates array index into an X/Y pair' do
      30 == POSITION_TO_INDEX[INDEX_TO_POSITION[30.to_peano]].to_i
    end

    assert 'works with zero' do
      0 == POSITION_TO_INDEX[INDEX_TO_POSITION[0.to_peano]].to_i
    end
  end
end
