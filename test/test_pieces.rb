# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './test_setup'

group 'Piece Functions' do
  FROM_POSITION = position(4, 4)
  NULL_POSITION = position(0, 0)

  NOTHING_SURROUNDING = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, BQ,0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .to_board

  SURROUNDED = [0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, WQ,WQ,WQ,0, 0,
                0, 0, 0, WQ,BQ,WQ,0, 0,
                0, 0, 0, WQ,WQ,WQ,0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0]
               .to_board

  ALL_WHITE = Array.new(64, MWQ).to_board
  ALL_BLACK = Array.new(64, MBQ).to_board

  def test_movement board, is_valid, rule, delta_x, delta_y
    result = rule[
               board,
               FROM_POSITION,
               shift_position(FROM_POSITION, delta_y, delta_x),
               NULL_POSITION,
               NULL_POSITION
             ]
    if is_valid
      expect_valid result
    else
      expect_invalid result
    end
  end

  def horizontal_movement board, delta, is_valid, rule
    group "can#{' not' unless is_valid}" do
      assert 'left' do
        test_movement board, is_valid, rule, -delta, 0
      end

      assert 'right' do
        test_movement board, is_valid, rule, delta, 0
      end

      assert 'up' do
        test_movement board, is_valid, rule, 0, delta
      end

      assert 'down' do
        test_movement board, is_valid, rule, 0, -delta
      end
    end
  end

  def diagonal_movement board, delta, is_valid, rule
    group "can#{' not' unless is_valid}" do
      assert 'up + left' do
        test_movement board, is_valid, rule, -delta, delta
      end

      assert 'up + right' do
        test_movement board, is_valid, rule, delta, delta
      end

      assert 'down + left' do
        test_movement board, is_valid, rule, -delta, -delta
      end

      assert 'down + right' do
        test_movement board, is_valid, rule, -delta, -delta
      end
    end
  end

  def capturing_basics rule, delta_x, delta_y
    group 'can not capture self' do
      assert 'white' do
        expect_invalid(
          rule[
            NOTHING_SURROUNDING,
            FROM_POSITION,
            FROM_POSITION,
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          rule[
            NOTHING_SURROUNDING,
            FROM_POSITION,
            FROM_POSITION,
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'can not capture own color' do
      assert 'black' do
        expect_invalid(
          rule[
            ALL_BLACK,
            FROM_POSITION,
            shift_position(FROM_POSITION, delta_y, delta_x),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'white' do
        expect_invalid(
          rule[
            ALL_WHITE,
            FROM_POSITION,
            shift_position(FROM_POSITION, delta_y, -delta_x),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end
  end

  group 'ROOK_RULE' do
    capturing_basics    ROOK_RULE, 0, 1
    horizontal_movement NOTHING_SURROUNDING, 3, true,  ROOK_RULE
    diagonal_movement   NOTHING_SURROUNDING, 3, false, ROOK_RULE

    group 'if a piece is in the way' do
      horizontal_movement SURROUNDED, 3, false, ROOK_RULE
    end
  end

  group 'BISHOP_RULE' do
    capturing_basics    BISHOP_RULE, 1, 1
    horizontal_movement NOTHING_SURROUNDING, 3, false, BISHOP_RULE
    diagonal_movement   NOTHING_SURROUNDING, 3, true,  BISHOP_RULE

    group 'if a piece is in the way' do
      diagonal_movement SURROUNDED, 3, false, BISHOP_RULE
    end
  end

  group 'QUEEN_RULE' do
    capturing_basics    QUEEN_RULE, 1, 1
    horizontal_movement NOTHING_SURROUNDING, 3, true, QUEEN_RULE
    diagonal_movement   NOTHING_SURROUNDING, 3, true,  QUEEN_RULE

    group 'if a piece is in the way' do
      diagonal_movement SURROUNDED, 3, false, QUEEN_RULE
      horizontal_movement SURROUNDED, 3, false, QUEEN_RULE
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        QUEEN_RULE[
          NOTHING_SURROUNDING,
          FROM_POSITION,
          shift_position(FROM_POSITION, -1, 3),
          NULL_POSITION,
          NULL_POSITION
        ]
      )
    end
  end

  group 'KING_RULE' do
    capturing_basics    KING_RULE, 1, 1
    horizontal_movement NOTHING_SURROUNDING, 1, true, KING_RULE
    diagonal_movement   NOTHING_SURROUNDING, 1, true, KING_RULE

    assert 'cannot move more than one' do
      expect_invalid(
        KING_RULE[
          NOTHING_SURROUNDING,
          FROM_POSITION,
          shift_position(FROM_POSITION, 2, 0),
          NULL_POSITION,
          NULL_POSITION
        ]
      )
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        KING_RULE[
          NOTHING_SURROUNDING,
          FROM_POSITION,
          shift_position(FROM_POSITION, 2, 1),
          NULL_POSITION,
          NULL_POSITION
        ]
      )
    end

    assert 'cannot move into check' do
      near_check = [0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, MBK,0, 0, 0,
                    0, 0, MWQ,0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0]
                   .to_board

      expect_invalid(
        KING_RULE[
          near_check,
          FROM_POSITION,
          shift_position(FROM_POSITION, -1, 0),
          NULL_POSITION,
          NULL_POSITION
        ]
      )
    end
  end

  group 'KNIGHT_RULE' do
    def knights_moves board
      assert 'can make knights moves' do
        [
          [ 2,  1], [ 1,  2],
          [-2,  1], [-1,  2],
          [ 2, -1], [ 1, -2],
          [-2, -1], [-1, -2]
        ].map do |shifts|
          shift_position(FROM_POSITION, *shifts)
        end
        .all? do |valid_move|
          expect_valid(
            KNIGHT_RULE[
              board,
              FROM_POSITION,
              valid_move,
              NULL_POSITION,
              NULL_POSITION
            ]
          )
        end
      end
    end

    capturing_basics KNIGHT_RULE, 1, 2
    knights_moves    NOTHING_SURROUNDING

    group 'if a piece is in the way' do
      knights_moves SURROUNDED
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        KNIGHT_RULE[
          NOTHING_SURROUNDING,
          FROM_POSITION,
          shift_position(FROM_POSITION, -1, 1),
          NULL_POSITION,
          NULL_POSITION
        ]
      )
    end
  end

  group 'PAWN_RULE' do
    starting_board = [0, 0, 0, 0, 0, 0, 0, 0,
                      BP,BP,BP,BP,BP,BP,BP,BP,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      WP,WP,WP,WP,WP,WP,WP,WP,
                      0, 0, 0, 0, 0, 0, 0, 0]
                     .to_board

    capturing_basics PAWN_RULE, 1, 1

    group 'can move forward by one' do
      assert 'white' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            position(4, 6),
            position(4, 5),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            position(1, 1),
            position(1, 2),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'can move forward by two on the first move' do
      assert 'white' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            position(4, 6),
            position(4, 4),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            position(1, 1),
            position(1, 3),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'cannot move forward by two on subsequent moves' do
      later_board = [0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, MBP,0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, MWP,0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0]
                    .to_board

      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            later_board,
            position(4, 5),
            position(4, 3),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            later_board,
            position(1, 2),
            position(1, 4),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'cannot move backwards' do
      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            position(4, 6),
            position(4, 7),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            position(1, 1),
            position(1, 0),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'cannot move diagonally without capturing' do
      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            position(4, 6),
            position(5, 5),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            position(1, 1),
            position(0, 2),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'cannot move sideways' do
      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            position(4, 6),
            position(5, 6),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            position(1, 1),
            position(0, 1),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'cannot capture sideways' do
      sideways_capture_board = [0, 0, 0, 0, 0, 0, 0, 0,
                                WP,BP,0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, WP,BP,0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0]
                               .to_board

      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            sideways_capture_board,
            position(4, 6),
            position(5, 6),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            sideways_capture_board,
            position(1, 1),
            position(0, 1),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'can capture forward diagonally' do
      capture_board = [0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  MBP,0, 0, 0,  0,  0, 0,
                       MWP,0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  MBP,0, 0,
                       0,  0,  0, 0, MWP,0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0]
                      .to_board

      assert 'white' do
        expect_valid(
          PAWN_RULE[
            capture_board,
            position(4, 5),
            position(5, 4),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_valid(
          PAWN_RULE[
            capture_board,
            position(1, 2),
            position(0, 3),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    group 'cannot capture backwards diagonally' do
      capture_board = [0,  0,  0, 0, 0,  0,  0, 0,
                       MWP,0,  0, 0, 0,  0,  0, 0,
                       0,  MBP,0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, MWP,0,  0, 0,
                       0,  0,  0, 0, 0,  MBP,0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0]
                      .to_board

      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            capture_board,
            position(4, 5),
            position(5, 6),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            capture_board,
            position(1, 2),
            position(0, 1),
            NULL_POSITION,
            NULL_POSITION
          ]
        )
      end
    end

    en_passant_board = [0, 0,  0, 0, 0,  0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0,
                        0, MBP,WP,0, 0,  0, 0, 0,
                        0, 0,  0, BP,MWP,0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0]
                       .to_board

    group 'can capture en passant' do
      assert 'white' do
        expect_en_passant(
          PAWN_RULE[
            en_passant_board,
            position(2, 3),
            position(1, 2),
            position(1, 1),
            position(1, 3)
          ]
        )
      end

      assert 'black' do
        expect_en_passant(
          PAWN_RULE[
            en_passant_board,
            position(3, 4),
            position(4, 5),
            position(4, 6),
            position(4, 4)
          ]
        )
      end

      group 'only if last moved was a pawn' do
        non_passant_board = [0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, BQ,WP,0, 0, 0, 0, 0,
                             0, 0, 0, BP,WQ,0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0]
                            .to_board

        assert 'white' do
          expect_invalid(
            PAWN_RULE[
              non_passant_board,
              position(2, 3),
              position(1, 2),
              position(1, 1),
              position(1, 3)
            ]
          )
        end

        assert 'black' do
          expect_invalid(
            PAWN_RULE[
              non_passant_board,
              position(3, 4),
              position(4, 5),
              position(4, 6),
              position(4, 4)
            ]
          )
        end
      end

      group 'only if the last moved pawn moved two' do
        assert 'white' do
          expect_invalid(
            PAWN_RULE[
              en_passant_board,
              position(2, 3),
              position(1, 2),
              position(1, 2),
              position(1, 3)
            ]
          )
        end

        assert 'black' do
          expect_invalid(
            PAWN_RULE[
              en_passant_board,
              position(3, 4),
              position(4, 5),
              position(4, 5),
              position(4, 4)
            ]
          )
        end
      end
    end
  end
end
