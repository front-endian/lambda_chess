# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'Board Functions' do
  group 'GET_POSITION' do
    assert 'gets data at the given position' do
      piece = GET_POSITION[INITIAL_BOARD, PAIR[KING_COLUMN, BLACK_HOME_ROW]]

      GET_VALUE[piece].to_i == KING_VALUE.to_i
    end
  end

  group 'FREE_PATH' do
    center = position(3, 3)

    group 'returns FIRST if there are no pieces in the way' do
      example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, BP,0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0]]
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
          example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [WQ,0, 0, BQ,0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0]]
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
          example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, BQ,0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, WQ,0, 0, 0, 0]]
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
          example_board = [[0, 0, 0, 0, 0, 0, WQ,0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, BQ,0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0]]
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
          example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [WQ,0, 0, BQ,0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0]]
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
          example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, BQ,0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, WQ,0, 0, 0, 0]]
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
          example_board = [[0, 0, 0, 0, 0, 0, WQ,0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, BQ,0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0]]
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
        example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, BQ,WQ,0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0]]
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
        example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, WQ,0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, BQ,0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0]]
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
        example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, BQ,0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, WQ,0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0]]
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
    example_board = INITIAL_BOARD

    from  = position(0, 0)
    to    = position(2, 2)
    moved = MOVE[example_board, from, to]

    assert 'moves the piece at the "from" position to the "to" position' do
      expected = GET_VALUE[GET_POSITION[example_board, from]].to_i

      expected == GET_VALUE[GET_POSITION[moved, to]].to_i
    end

    assert 'marks the moved piece as moved' do
      expect_falsy(GET_MOVED[GET_POSITION[moved, from]]) &&
      expect_truthy(GET_MOVED[GET_POSITION[moved, to]])
    end

    assert 'puts an empty piece in the "from" position' do
      EMPTY_SPACE == GET_POSITION[moved, from]
    end

    assert 'works when moving to same position' do
      null_move = MOVE[example_board, from, from]

      expected = GET_VALUE[GET_POSITION[example_board, from]].to_i

      expected == GET_VALUE[GET_POSITION[null_move, from]].to_i
    end
  end
end
