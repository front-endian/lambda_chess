# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './test_setup'
require './../data'
require './../board'
require 'tet'

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

  group 'DISTANCE' do
    position_1 = PAIR[2.to_peano, 10.to_peano]
    position_2 = PAIR[5.to_peano, 15.to_peano]
    expected   = [3, 5]

    assert 'returns distance of the X and Y coordinates' do
      result = DISTANCE[position_1, position_2]

      expected == [LEFT[result], RIGHT[result]].map(&:to_i)
    end

    assert 'argument order does not matter' do
      result = DISTANCE[position_2, position_1]

      expected == [LEFT[result], RIGHT[result]].map(&:to_i)
    end
  end

  group 'GET_POSITION' do
    assert 'gets data at the given position' do
      board = [0, 1, 2,  3,  4,  5,  6,  7,
               8, 9, 10, 11, 12, 13, 14, 15].to_linked_list

      10 == GET_POSITION[board, PAIR[2.to_peano, 1.to_peano]]
    end
  end

  group 'FREE_PATH' do
    center = PAIR[3.to_peano, 3.to_peano]

    def shifted delta_x, delta_y
      PAIR[(3 + delta_x).to_peano, (3 + delta_y).to_peano]
    end

    group 'returns FIRST if there are no pieces in the way' do
      example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 1, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0]
                      .map(&:to_peano)
                      .to_linked_list

      assert 'horizontally' do
        FREE_PATH[example_board, center, shifted(3, 0), DECREMENT][true, false]
      end

      assert 'vertically' do
        FREE_PATH[example_board, center, shifted(0, -3), DECREMENT][true, false]
      end

      assert 'diagonally' do
        FREE_PATH[example_board, center, shifted(-3, 3), DECREMENT][true, false]
      end
    end

    group 'if the only piece in the way is at the TO location' do
      group 'returns FIRST if told to DECREMENT length' do
        assert 'horizontally' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           7, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(-3, 0), DECREMENT][true, false]
        end

        assert 'vertically' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(0, 4), DECREMENT][true, false]
        end

        assert 'diagonally' do
          example_board = [0, 0, 0, 0, 0, 0, 7, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(3, -3), DECREMENT][true, false]
        end
      end

      group 'returns SECOND if told to not alter the length' do
        assert 'horizontally' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           7, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(-3, 0), IDENTITY][false, true]
        end

        assert 'vertically' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(0, 4), IDENTITY][false, true]
        end

        assert 'diagonally' do
          example_board = [0, 0, 0, 0, 0, 0, 7, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(3, -3), IDENTITY][false, true]
        end
      end
    end

    group 'returns SECOND if there is a piece in the way' do
      assert 'horizontally' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 7, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

        FREE_PATH[example_board, center, shifted(4, 0), DECREMENT][false, true]
      end

      assert 'vertically' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

        FREE_PATH[example_board, center, shifted(0, -3), DECREMENT][false, true]
      end

      assert 'diagonally' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 7, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

        FREE_PATH[example_board, center, shifted(-3, 3), DECREMENT][false, true]
      end
    end
  end

  group 'MOVE' do
    example_board = index_array.map(&:to_peano).to_linked_list

    from  = PAIR[2.to_peano, 2.to_peano]
    to    = PAIR[3.to_peano, 7.to_peano]
    moved = MOVE[example_board, from, to]

    assert 'moves the piece at the "from" position to the "to" position' do
      expected = TO_MOVED_PIECE[GET_POSITION[example_board, from]].to_i

      expected == GET_POSITION[moved, to].to_i
    end

    assert 'puts a zero in the "from" position' do
      0 == GET_POSITION[moved, from].to_i
    end
  end

  group 'INITIAL_BOARD' do
    assert 'is initialized to the correct values' do
      INITIAL_BOARD.to_a(64).map(&:to_i) == [5,  3,  4,  9,  10, 4,  3,  5,
                                             1,  1,  1,  1,  1,  1,  1,  1,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             11, 11, 11, 11, 11, 11, 11, 11,
                                             15, 13, 14, 19, 20, 14, 13, 15]
    end
  end
end
