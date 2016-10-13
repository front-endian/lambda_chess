# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './test_setup'

group 'Board Functions' do
  group 'POSITION_TO_INDEX' do
    assert 'translates X/Y pair into an array index' do
      34 == POSITION_TO_INDEX[position(2, 4)].to_i
    end

    assert 'works with zero' do
      6 == POSITION_TO_INDEX[position(6, 0)].to_i
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
    position_1 = position(2, 10)
    position_2 = position(5, 15)
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

      10 == GET_POSITION[board, position(2, 1)]
    end
  end

  group 'FREE_PATH' do
    center = position(3, 3)

    group 'returns FIRST if there are no pieces in the way' do
      example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, BP,0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0]
                      .to_board

      assert 'horizontally' do
        expect_truthy(
          FREE_PATH[
            example_board,
            center,
            shift_position(center, 3, 0),
            DECREMENT
          ]
        )
      end

      assert 'vertically' do
        expect_truthy(
          FREE_PATH[
            example_board,
            center,
            shift_position(center, 0, -3),
            DECREMENT
          ]
        )
      end

      assert 'diagonally' do
        expect_truthy(
          FREE_PATH[
            example_board,
            center,
            shift_position(center, -3, 3),
            DECREMENT
          ]
        )
      end
    end

    group 'if the only piece in the way is at the TO location' do
      group 'returns FIRST if told to DECREMENT length' do
        assert 'horizontally' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           WQ,0, 0, BQ,0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .to_board

          expect_truthy(
            FREE_PATH[
              example_board,
              center,
              shift_position(center, -3, 0),
              DECREMENT
            ]
          )
        end

        assert 'vertically' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, BQ,0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, WQ,0, 0, 0, 0]
                          .to_board

          expect_truthy(
            FREE_PATH[
              example_board,
              center,
              shift_position(center, 0, 4),
              DECREMENT
            ]
          )
        end

        assert 'diagonally' do
          example_board = [0, 0, 0, 0, 0, 0, WQ,0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, BQ,0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .to_board

          expect_truthy(
            FREE_PATH[
              example_board,
              center,
              shift_position(center, 3, -3),
              DECREMENT
            ]
          )
        end
      end

      group 'returns SECOND if told to not alter the length' do
        assert 'horizontally' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           WQ,0, 0, BQ,0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .to_board

          expect_falsy(
            FREE_PATH[
              example_board,
              center,
              shift_position(center, -3, 0),
              IDENTITY
            ]
          )
        end

        assert 'vertically' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, BQ,0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, WQ,0, 0, 0, 0]
                          .to_board

          expect_falsy(
            FREE_PATH[
              example_board,
              center,
              shift_position(center, 0, 4),
              IDENTITY
            ]
          )
        end

        assert 'diagonally' do
          example_board = [0, 0, 0, 0, 0, 0, WQ,0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, BQ,0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .to_board

          expect_falsy(
            FREE_PATH[
              example_board,
              center,
              shift_position(center, 3, -3),
              IDENTITY
            ]
          )
        end
      end
    end

    group 'returns SECOND if there is a piece in the way' do
      assert 'horizontally' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, BQ,WQ,0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .to_board

        expect_falsy(
          FREE_PATH[
            example_board,
            center,
            shift_position(center, 4, 0),
            DECREMENT
          ]
        )
      end

      assert 'vertically' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, WQ,0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, BQ,0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .to_board

        expect_falsy(
          FREE_PATH[
            example_board,
            center,
            shift_position(center, 0, -3),
            DECREMENT
          ]
        )
      end

      assert 'diagonally' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, BQ,0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, WQ,0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .to_board

        expect_falsy(
          FREE_PATH[
            example_board,
            center,
            shift_position(center, -3, 3),
            DECREMENT
          ]
        )
      end
    end
  end

  group 'MOVE' do
    example_board = INDEX_ARRAY.to_board

    from  = position(2, 2)
    to    = position(3, 7)
    moved = MOVE[example_board, from, to]

    assert 'moves the piece at the "from" position to the "to" position' do
      expected = TO_MOVED_PIECE[GET_POSITION[example_board, from]].to_i

      expected == GET_POSITION[moved, to].to_i
    end

    assert 'puts a zero in the "from" position' do
      0 == GET_POSITION[moved, from].to_i
    end

    assert 'works when moving to same position' do
      null_move = MOVE[example_board, from, from]

      expected = TO_MOVED_PIECE[GET_POSITION[example_board, from]].to_i

      expected == GET_POSITION[null_move, from].to_i
    end
  end

  group 'INITIAL_BOARD' do
    assert 'is initialized to the correct values' do
      INITIAL_BOARD.to_a(64).map(&:to_i) == [4, 2, 3, 5, 6, 3, 2, 4,
                                             1, 1, 1, 1, 1, 1, 1, 1,
                                             0, 0, 0, 0, 0, 0, 0, 0,
                                             0, 0, 0, 0, 0, 0, 0, 0,
                                             0, 0, 0, 0, 0, 0, 0, 0,
                                             0, 0, 0, 0, 0, 0, 0, 0,
                                             7, 7, 7, 7, 7, 7, 7, 7,
                                             10,8, 9, 11,12,9, 8, 10]
    end
  end
end
