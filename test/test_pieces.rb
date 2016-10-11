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
  bp  = BLACK_PAWN.to_i
  wp  = WHITE_PAWN.to_i
  mbp = TO_MOVED_PIECE[BLACK_PAWN].to_i
  mwp = TO_MOVED_PIECE[WHITE_PAWN].to_i

  bq  = BLACK_QUEEN.to_i
  wq  = WHITE_QUEEN.to_i
  mbq = TO_MOVED_PIECE[BLACK_QUEEN].to_i
  mwq = TO_MOVED_PIECE[WHITE_QUEEN].to_i

  nothing_surrounding = [0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, mbq,0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0,
                         0, 0, 0, 0, 0,  0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

  surrounded = [0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, mwq,mwq,mwq,0, 0,
                0, 0, 0, mwq,mbq,mwq,0, 0,
                0, 0, 0, mwq,mwq,mwq,0, 0,
                0, 0, 0, 0,  0,  0,  0, 0,
                0, 0, 0, 0,  0,  0,  0, 0]
               .map(&:to_peano)
               .to_linked_list


  def null_position
    PAIR[0.to_peano, 0.to_peano]
  end

  def test_movement board, is_valid, func, delta_x, delta_y
    result = func[
               board,
               PAIR[4.to_peano, 4.to_peano],
               PAIR[
                 (4 + delta_x).to_peano,
                 (4 + delta_y).to_peano
               ],
               null_position,
               null_position
             ]
    if is_valid
      expect_valid result
    else
      expect_invalid result
    end
  end

  def horizontal_movement board, delta, is_valid, func
    group "can#{' not' unless is_valid}" do
      assert 'left' do
        test_movement board, is_valid, func, -delta, 0
      end

      assert 'right' do
        test_movement board, is_valid, func, delta, 0
      end

      assert 'up' do
        test_movement board, is_valid, func, 0, delta
      end

      assert 'down' do
        test_movement board, is_valid, func, 0, -delta
      end
    end
  end

  def diagonal_movement board, delta, is_valid, func
    group "can#{' not' unless is_valid}" do
      assert 'up + left' do
        test_movement board, is_valid, func, -delta, delta
      end

      assert 'up + right' do
        test_movement board, is_valid, func, delta, delta
      end

      assert 'down + left' do
        test_movement board, is_valid, func, -delta, -delta
      end

      assert 'down + right' do
        test_movement board, is_valid, func, -delta, -delta
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
    horizontal_movement nothing_surrounding, 3, true,  ROOK_RULE
    diagonal_movement   nothing_surrounding, 3, false, ROOK_RULE

    group 'if a piece is in the way' do
      horizontal_movement surrounded, 3, false, ROOK_RULE
    end
  end

  group 'BISHOP_RULE' do
    horizontal_movement nothing_surrounding, 3, false, BISHOP_RULE
    diagonal_movement   nothing_surrounding, 3, true,  BISHOP_RULE

    group 'if a piece is in the way' do
      diagonal_movement surrounded, 3, false, BISHOP_RULE
    end
  end

  group 'QUEEN_RULE' do
    horizontal_movement nothing_surrounding, 3, true, QUEEN_RULE
    diagonal_movement   nothing_surrounding, 3, true,  QUEEN_RULE

    group 'if a piece is in the way' do
      diagonal_movement surrounded, 3, false, QUEEN_RULE
      horizontal_movement surrounded, 3, false, QUEEN_RULE
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        QUEEN_RULE[
          nothing_surrounding,
          PAIR[4.to_peano, 4.to_peano],
          PAIR[3.to_peano, 6.to_peano],
          null_position,
          null_position
        ]
      )
    end
  end

  group 'KING_RULE' do
    horizontal_movement nothing_surrounding, 1, true, KING_RULE
    diagonal_movement   nothing_surrounding, 1, true, KING_RULE

    assert 'cannot move more than one' do
      expect_invalid(
        KING_RULE[
          nothing_surrounding,
          PAIR[4.to_peano, 4.to_peano],
          PAIR[2.to_peano, 4.to_peano],
          null_position,
          null_position
        ]
      )
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        KING_RULE[
          nothing_surrounding,
          PAIR[4.to_peano, 4.to_peano],
          PAIR[3.to_peano, 6.to_peano],
          null_position,
          null_position
        ]
      )
    end

    assert 'cannot move into check' do
      mbk = TO_MOVED_PIECE[BLACK_KING].to_i

      near_check = [0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, mbk,0, 0, 0,
                    0, 0, mwq,0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0,
                    0, 0, 0,  0, 0,  0, 0, 0]
                   .map(&:to_peano)
                   .to_linked_list
      expect_invalid(
        KING_RULE[
          near_check,
          PAIR[4.to_peano, 4.to_peano],
          PAIR[3.to_peano, 4.to_peano],
          null_position,
          null_position
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
        ].map do |pair|
          pair.map { |x| (x + 4).to_peano }
        end
        .all? do |pair|
          expect_valid(
            KNIGHT_RULE[
              board,
              PAIR[4.to_peano, 4.to_peano],
              PAIR[*pair],
              null_position,
              null_position
            ]
          )
        end
      end
    end

    knights_moves nothing_surrounding

    group 'if a piece is in the way' do
      knights_moves surrounded
    end

    assert 'cannot move elsewhere' do
      expect_invalid(
        KNIGHT_RULE[
          nothing_surrounding,
          PAIR[4.to_peano, 4.to_peano],
          PAIR[-4.to_peano, 7.to_peano],
          null_position,
          null_position
        ]
      )
    end
  end

  group 'PAWN_RULE' do
    starting_board = [0, 0, 0, 0, 0, 0, 0, 0,
                      0, bp,0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, wp,0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0]
                     .map(&:to_peano)
                     .to_linked_list

    group 'can move forward by one' do
      assert 'white' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            PAIR[4.to_peano, 6.to_peano],
            PAIR[4.to_peano, 5.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            PAIR[1.to_peano, 1.to_peano],
            PAIR[1.to_peano, 2.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'can move forward by two on the first move' do
      assert 'white' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            PAIR[4.to_peano, 6.to_peano],
            PAIR[4.to_peano, 4.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_valid(
          PAWN_RULE[
            starting_board,
            PAIR[1.to_peano, 1.to_peano],
            PAIR[1.to_peano, 3.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'cannot move forward by two on subsequent moves' do
      later_board = [0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, mbp,0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, mwp,0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0,
                     0, 0,  0, 0, 0,  0, 0, 0]
                    .map(&:to_peano)
                    .to_linked_list

      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            later_board,
            PAIR[4.to_peano, 5.to_peano],
            PAIR[4.to_peano, 3.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            later_board,
            PAIR[1.to_peano, 2.to_peano],
            PAIR[1.to_peano, 4.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'cannot move backwards' do
      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            PAIR[4.to_peano, 6.to_peano],
            PAIR[4.to_peano, 7.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            PAIR[1.to_peano, 1.to_peano],
            PAIR[1.to_peano, 0.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'cannot move diagonally without capturing' do
      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            PAIR[4.to_peano, 6.to_peano],
            PAIR[5.to_peano, 5.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            PAIR[1.to_peano, 1.to_peano],
            PAIR[0.to_peano, 2.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'cannot move sideways' do
      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            PAIR[4.to_peano, 6.to_peano],
            PAIR[5.to_peano, 6.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            starting_board,
            PAIR[1.to_peano, 1.to_peano],
            PAIR[0.to_peano, 1.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'cannot capture sideways' do
      sideways_capture_board = [0, 0, 0, 0, 0, 0, 0, 0,
                                wp,bp,0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, wp,bp,0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0]
                               .map(&:to_peano)
                               .to_linked_list

      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            sideways_capture_board,
            PAIR[4.to_peano, 6.to_peano],
            PAIR[5.to_peano, 6.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            sideways_capture_board,
            PAIR[1.to_peano, 1.to_peano],
            PAIR[0.to_peano, 1.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'can capture forward diagonally' do
      capture_board = [0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  mbp,0, 0, 0,  0,  0, 0,
                       mwp,0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  mbp,0, 0,
                       0,  0,  0, 0, mwp,0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0]
                      .map(&:to_peano)
                      .to_linked_list

      assert 'white' do
        expect_valid(
          PAWN_RULE[
            capture_board,
            PAIR[4.to_peano, 5.to_peano],
            PAIR[5.to_peano, 4.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_valid(
          PAWN_RULE[
            capture_board,
            PAIR[1.to_peano, 2.to_peano],
            PAIR[0.to_peano, 3.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    group 'cannot capture backwards diagonally' do
      capture_board = [0,  0,  0, 0, 0,  0,  0, 0,
                       mwp,0,  0, 0, 0,  0,  0, 0,
                       0,  mbp,0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0,
                       0,  0,  0, 0, mwp,0,  0, 0,
                       0,  0,  0, 0, 0,  mbp,0, 0,
                       0,  0,  0, 0, 0,  0,  0, 0]
                      .map(&:to_peano)
                      .to_linked_list

      assert 'white' do
        expect_invalid(
          PAWN_RULE[
            capture_board,
            PAIR[4.to_peano, 5.to_peano],
            PAIR[5.to_peano, 6.to_peano],
            null_position,
            null_position
          ]
        )
      end

      assert 'black' do
        expect_invalid(
          PAWN_RULE[
            capture_board,
            PAIR[1.to_peano, 2.to_peano],
            PAIR[0.to_peano, 1.to_peano],
            null_position,
            null_position
          ]
        )
      end
    end

    en_passant_board = [0, 0,  0, 0, 0,  0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0,
                        0, 0,  0, 0, 0,  0, 0, 0,
                        0, mbp,wp,0, 0,  0, 0, 0,
                        0, 0,  0, bp,mwp,0, 0, 0,
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
            PAIR[2.to_peano, 3.to_peano],
            PAIR[1.to_peano, 2.to_peano],
            PAIR[1.to_peano, 1.to_peano],
            PAIR[1.to_peano, 3.to_peano]
          ]
        )
      end

      assert 'black' do
        expect_en_passant(
          PAWN_RULE[
            en_passant_board,
            PAIR[3.to_peano, 4.to_peano],
            PAIR[4.to_peano, 5.to_peano],
            PAIR[4.to_peano, 6.to_peano],
            PAIR[4.to_peano, 4.to_peano]
          ]
        )
      end

      group 'only if last moved was a pawn' do
        non_passant_board = [0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, bq,wp,0, 0, 0, 0, 0,
                             0, 0, 0, bp,wq,0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0,
                             0, 0, 0, 0, 0, 0, 0, 0]
                            .map(&:to_peano)
                            .to_linked_list

        assert 'white' do
          expect_invalid(
            PAWN_RULE[
              non_passant_board,
              PAIR[2.to_peano, 3.to_peano],
              PAIR[1.to_peano, 2.to_peano],
              PAIR[1.to_peano, 1.to_peano],
              PAIR[1.to_peano, 3.to_peano]
            ]
          )
        end

        assert 'black' do
          expect_invalid(
            PAWN_RULE[
              non_passant_board,
              PAIR[3.to_peano, 4.to_peano],
              PAIR[4.to_peano, 5.to_peano],
              PAIR[4.to_peano, 6.to_peano],
              PAIR[4.to_peano, 4.to_peano]
            ]
          )
        end
      end

      group 'only if the last moved pawn moved two' do
        assert 'white' do
          expect_invalid(
            PAWN_RULE[
              en_passant_board,
              PAIR[2.to_peano, 3.to_peano],
              PAIR[1.to_peano, 2.to_peano],
              PAIR[1.to_peano, 2.to_peano],
              PAIR[1.to_peano, 3.to_peano]
            ]
          )
        end

        assert 'black' do
          expect_invalid(
            PAWN_RULE[
              en_passant_board,
              PAIR[3.to_peano, 4.to_peano],
              PAIR[4.to_peano, 5.to_peano],
              PAIR[4.to_peano, 5.to_peano],
              PAIR[4.to_peano, 4.to_peano]
            ]
          )
        end
      end
    end
  end
end
