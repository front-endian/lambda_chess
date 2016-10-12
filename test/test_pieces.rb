# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './test_setup'
require './../data'
require './../board'
require './../pieces'
require 'tet'

group 'Piece Functions' do
  def position x, y
    PAIR[x.to_peano, y.to_peano]
  end

  def shift_position position, delta_x, delta_y
    PAIR[
       (LEFT[position].to_i + delta_x).to_peano,
      (RIGHT[position].to_i + delta_y).to_peano
    ]
  end

   BP = BLACK_PAWN.to_i
   WP = WHITE_PAWN.to_i
  MBP = TO_MOVED_PIECE[BLACK_PAWN].to_i
  MWP = TO_MOVED_PIECE[WHITE_PAWN].to_i
   BQ = BLACK_QUEEN.to_i
   WQ = WHITE_QUEEN.to_i
  MBQ = TO_MOVED_PIECE[BLACK_QUEEN].to_i
  MWQ = TO_MOVED_PIECE[WHITE_QUEEN].to_i
  MBK = TO_MOVED_PIECE[BLACK_KING].to_i

  FROM_POSITION = position(4, 4)
  NULL_POSITION = position(0, 0)

  NOTHING_SURROUNDING = [0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, MBQ,0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

  SURROUNDED = [0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, MWQ,MWQ,MWQ,0, 0,
                0, 0, 0, MWQ,MBQ,MWQ,0, 0,
                0, 0, 0, MWQ,MWQ,MWQ,0, 0,
                0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, 0,  0,  0,  0, 0]
               .map(&:to_peano)
               .to_linked_list

  ALL_WHITE = Array.new(64, MWQ).map(&:to_peano).to_linked_list
  ALL_BLACK = Array.new(64, MBQ).map(&:to_peano).to_linked_list

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

  def expect_valid func
    func[true, false, false]
  end

  def expect_invalid func
    func[false, true, false]
  end

  def expect_en_passant func
    func[false, false, true]
  end

  group 'ROOK_RULE' do
    horizontal_movement NOTHING_SURROUNDING, 3, true,  ROOK_RULE
    diagonal_movement   NOTHING_SURROUNDING, 3, false, ROOK_RULE

    group 'if a piece is in the way' do
      horizontal_movement SURROUNDED, 3, false, ROOK_RULE
    end
  end

  group 'BISHOP_RULE' do
    horizontal_movement NOTHING_SURROUNDING, 3, false, BISHOP_RULE
    diagonal_movement   NOTHING_SURROUNDING, 3, true,  BISHOP_RULE

    group 'if a piece is in the way' do
      diagonal_movement SURROUNDED, 3, false, BISHOP_RULE
    end
  end

  group 'QUEEN_RULE' do
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
                   .map(&:to_peano)
                   .to_linked_list

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
                      0, BP,0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, WP,0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0]
                     .map(&:to_peano)
                     .to_linked_list

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
            position(1, 2),
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
                    .map(&:to_peano)
                    .to_linked_list

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
                               .map(&:to_peano)
                               .to_linked_list

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
                      .map(&:to_peano)
                      .to_linked_list

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
                      .map(&:to_peano)
                      .to_linked_list

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
                       .map(&:to_peano)
                       .to_linked_list

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
                            .map(&:to_peano)
                            .to_linked_list

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
