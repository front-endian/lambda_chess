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

  group 'NORMAL_MOVE' do
    example_board = INITIAL_BOARD

    from  = position(0, 0)
    to    = position(2, 2)
    moved = NORMAL_MOVE[example_board, from, to, nil]

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
      null_move = NORMAL_MOVE[example_board, from, from, nil]

      expected = GET_VALUE[GET_POSITION[example_board, from]].to_i

      expected == GET_VALUE[GET_POSITION[null_move, from]].to_i
    end
  end

  group 'CHANGE_MOVE' do
    example_board = INITIAL_BOARD

    from      = position(0, 0)
    to        = position(2, 2)
    new_piece = BLACK_PAWN
    moved     = CHANGE_MOVE[example_board, from, to, new_piece]

    assert 'puts the "new_piece" in the "to" position' do
      expected = GET_VALUE[new_piece].to_i

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
      null_move = CHANGE_MOVE[example_board, from, from, new_piece]

      expected = GET_VALUE[new_piece].to_i

      expected == GET_VALUE[GET_POSITION[null_move, from]].to_i
    end
  end

  group 'CASTLING_MOVE' do
    board = [[BR,0, 0, 0, BK,0, 0, BR],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [WR,0, 0, 0, WK,0, 0, WR]]
            .to_board

    test_castling board, board,
      perform: proc { |board, from, to| CASTLING_MOVE[board, from, to, nil] },
      expect:  proc { |result, king_to, rook_to, rook_from|
        assert "king was moved" do
         piece_in_position = KING_VALUE == GET_VALUE[GET_POSITION[result, king_to]]

         piece_in_position
        end

        assert "rook was moved" do
          piece_in_position = ROOK_VALUE == GET_VALUE[GET_POSITION[result, rook_to]]

          piece_in_position
        end

        assert "correct rook was moved" do
          piece_in_position = EMPTY_SPACE == GET_POSITION[result, rook_from]

          piece_in_position
        end
      }
  end

  group 'EN_PASSANT_MOVE' do
    example_board = [[0, 0, 0, 0, 0,  0, 0, 0],
                     [0, 0, 0, 0, 0,  0, 0, 0],
                     [0, 0, 0, 0, 0,  0, 0, 0],
                     [0, 0, 0, 0, 0,  0, 0, 0],
                     [0, 0, 0, BP,MWP,0, 0, 0],
                     [0, 0, 0, 0, 0,  0, 0, 0],
                     [0, 0, 0, 0, 0,  0, 0, 0],
                     [0, 0, 0, 0, 0,  0, 0, 0]]
                    .to_board

    from  = position(3, 4)
    to    = position(4, 5)
    moved = EN_PASSANT_MOVE[example_board, from, to, nil]

    assert 'moves the piece at the "from" position to the "to" position' do
      expected = GET_VALUE[GET_POSITION[example_board, from]].to_i

      expected == GET_VALUE[GET_POSITION[moved, to]].to_i
    end

    assert 'marks the moved piece as moved' do
      expect_falsy(GET_MOVED[GET_POSITION[moved, from]]) &&
      expect_truthy(GET_MOVED[GET_POSITION[moved, to]])
    end

    group 'puts an empty piece' do
      assert 'in the "from" position' do
        expect_truthy IS_EMPTY[GET_POSITION[moved, from]]
      end

      assert 'in space behind "to"' do
        expect_truthy IS_EMPTY[GET_POSITION[moved, position(4, 4)]]
      end
    end
  end
end
