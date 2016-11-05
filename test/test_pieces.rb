# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'Piece Functions' do
  REAL_ROOK_RULE   = ROOK_RULE[GET_RULE]
  REAL_BISHOP_RULE = BISHOP_RULE[GET_RULE]
  REAL_QUEEN_RULE  = QUEEN_RULE[GET_RULE]
  REAL_KING_RULE   = KING_RULE[GET_RULE]
  REAL_KNIGHT_RULE = KNIGHT_RULE[GET_RULE]
  REAL_PAWN_RULE   = PAWN_RULE[GET_RULE]

  FROM_POSITION = position(4, 4)

  NOTHING_SURROUNDING_BLACK = [[0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, BQ,0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0]]
                              .to_board

  NOTHING_SURROUNDING_WHITE = [[0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, WQ,0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0]]
                              .to_board

  BLACK_KING_IN_DANGER = [[0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [WR,0, 0, 0, BQ,0, 0,BK],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0]]
                         .to_board

  WHITE_KING_IN_DANGER = [[0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [BR,0, 0, 0, WQ,0, 0,WK],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0],
                          [0, 0, 0, 0, 0, 0, 0, 0]]
                         .to_board

  SURROUNDED = [[0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, WQ,WQ,WQ,0, 0],
                [0, 0, 0, WQ,BQ,WQ,0, 0],
                [0, 0, 0, WQ,WQ,WQ,0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0]]
               .to_board

  ALL_WHITE = Array.new(8, Array.new(8, MWQ)).to_board
  ALL_BLACK = Array.new(8, Array.new(8, MBQ)).to_board

  def run_rule rule, board, from, to, last_from = NULL_POS, last_to = NULL_POS
    rule[CREATE_STATE[from, to, last_from, last_to, board, ZERO, ZERO, ZERO]]
  end

  def test_movement board, is_valid, rule, delta_x, delta_y
    result = run_rule(
               rule,
               board,
               FROM_POSITION,
               shift_position(FROM_POSITION, delta_y, delta_x)
             )

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

  def cannot_cause_check rule, delta_x, delta_y
    group 'cannot move putting own king in check' do
      assert 'white' do
        expect_invalid(
          run_rule(
            rule,
            WHITE_KING_IN_DANGER,
            FROM_POSITION,
            shift_position(FROM_POSITION, delta_x, -delta_y)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            rule,
            BLACK_KING_IN_DANGER,
            FROM_POSITION,
            shift_position(FROM_POSITION, delta_x, delta_y)
          )
        )
      end
    end
  end

  def capturing_basics rule, delta_x, delta_y
    group 'can not capture self' do
      assert 'white' do
        expect_invalid(
          run_rule(
            rule,
            NOTHING_SURROUNDING_WHITE,
            FROM_POSITION,
            FROM_POSITION
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            rule,
            NOTHING_SURROUNDING_BLACK,
            FROM_POSITION,
            FROM_POSITION
          )
        )
      end
    end

    group 'can not capture own color' do
      def test_own_capture rule, color, delta_y, delta_x
        direction, piece, board = case color
                                  when :black
                                    [1, BP, NOTHING_SURROUNDING_BLACK]
                                  when :white
                                    [-1, WP, NOTHING_SURROUNDING_WHITE]
                                  end

        to    = shift_position(FROM_POSITION, delta_y, direction * delta_x)
        board = board.list_to_a(8).map { |row| row.list_to_a(8) }

        board[RIGHT[to].to_i][LEFT[to].to_i] = piece
        board = board.to_board

        expect_invalid(
          run_rule(
            rule,
            board,
            FROM_POSITION,
            to
          )
        )
      end

      assert('black') { test_own_capture rule, :black, delta_y, delta_x }
      assert('white') { test_own_capture rule, :white, delta_y, delta_x }
    end
  end

  def check_check
    assert 'returns FIRST with nothing around' do
      example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, BK,0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0]]
                      .to_board

      expect_truthy yield(
                      example_board,
                      position(4, 4),
                      position(4, 5)
                    )
    end

    assert 'returns SECOND when moving into check' do
      example_board = [[0, 0, 0,  0, 0,  0, 0, 0],
                       [0, 0, 0,  0, 0,  0, 0, 0],
                       [0, 0, 0,  0, 0,  0, 0, 0],
                       [0, 0, 0,  0, 0,  0, 0, 0],
                       [0, 0, 0,  0, MBK,0, 0, 0],
                       [0, 0, MWP,0, 0,  0, 0, 0],
                       [0, 0, 0,  0, 0,  0, 0, 0],
                       [0, 0, 0,  0, 0,  0, 0, 0]]
                      .to_board

      expect_falsy yield(
                     example_board,
                     position(4, 4),
                     position(3, 4)
                   )
    end

    assert 'returns FIRST when moving out of check' do
      example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, BK,0, 0, 0],
                       [0, 0, 0, 0, WR,0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0]]
                      .to_board

      expect_truthy yield(
                      example_board,
                      position(4, 4),
                      position(3, 4)
                    )
    end

    assert 'check can not come from own color' do
      example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, BK,0, 0, 0],
                       [0, 0, 0, BR,0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0]]
                      .to_board

      expect_truthy yield(
                      example_board,
                      position(4, 4),
                      position(3, 4)
                    )
    end

    assert 'returns FIRST when moving near but not into check' do
      example_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, BK,0, 0, 0],
                       [0, WR,0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0]]
                      .to_board

      expect_truthy yield(
                      example_board,
                      position(4, 4),
                      position(3, 4)
                    )
    end
  end

  group 'ROOK_RULE' do
    capturing_basics    REAL_ROOK_RULE, 0, 1
    cannot_cause_check  REAL_ROOK_RULE, 0, 1
    horizontal_movement NOTHING_SURROUNDING_BLACK, 3, true,  REAL_ROOK_RULE
    diagonal_movement   NOTHING_SURROUNDING_BLACK, 3, false, REAL_ROOK_RULE

    group 'if a piece is in the way' do
      horizontal_movement SURROUNDED, 3, false, REAL_ROOK_RULE
    end
  end

  group 'BISHOP_RULE' do
    capturing_basics    REAL_BISHOP_RULE, 1, 1
    cannot_cause_check  REAL_BISHOP_RULE, 1, 1
    horizontal_movement NOTHING_SURROUNDING_BLACK, 3, false, REAL_BISHOP_RULE
    diagonal_movement   NOTHING_SURROUNDING_BLACK, 3, true,  REAL_BISHOP_RULE

    group 'if a piece is in the way' do
      diagonal_movement SURROUNDED, 3, false, REAL_BISHOP_RULE
    end
  end

  group 'QUEEN_RULE' do
    capturing_basics    REAL_QUEEN_RULE, 1, 1
    cannot_cause_check  REAL_QUEEN_RULE, 1, 1
    horizontal_movement NOTHING_SURROUNDING_BLACK, 3, true, REAL_QUEEN_RULE
    diagonal_movement   NOTHING_SURROUNDING_BLACK, 3, true,  REAL_QUEEN_RULE

    group 'if a piece is in the way' do
      diagonal_movement   SURROUNDED, 3, false, REAL_QUEEN_RULE
      horizontal_movement SURROUNDED, 3, false, REAL_QUEEN_RULE
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        run_rule(
          REAL_QUEEN_RULE,
          NOTHING_SURROUNDING_BLACK,
          FROM_POSITION,
          shift_position(FROM_POSITION, -1, 3),
          NULL_POS,
          NULL_POS
        )
      )
    end
  end

  group 'IS_NOT_IN_CHECK' do
    check_check do |board, from, to|
      IS_NOT_IN_CHECK[NORMAL_MOVE[board, from, to, ZERO], to, GET_RULE]
    end

    assert 'allows moving into same position with own pieces nearby' do
      to    = position(4, 2)
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [BR,0, 0, 0, BK,0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]]
              .to_board

      expect_truthy IS_NOT_IN_CHECK[NORMAL_MOVE[board, position(4, 2), to, ZERO], to, GET_RULE]
    end
  end

  group 'KING_RULE' do
    capturing_basics    REAL_KING_RULE, 1, 0
    horizontal_movement NOTHING_SURROUNDING_BLACK, 1, true, REAL_KING_RULE
    diagonal_movement   NOTHING_SURROUNDING_BLACK, 1, true, REAL_KING_RULE

    check_check do |board, from, to|
      run_rule(REAL_KING_RULE, board, from, to)[
        FIRST,
        SECOND,
        SECOND,
        SECOND
      ]
    end

    assert 'cannot move more than one' do
      expect_invalid(
        run_rule(
          REAL_KING_RULE,
          NOTHING_SURROUNDING_BLACK,
          FROM_POSITION,
          shift_position(FROM_POSITION, 2, 0)
        )
      )
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        run_rule(
          REAL_KING_RULE,
          NOTHING_SURROUNDING_BLACK,
          FROM_POSITION,
          shift_position(FROM_POSITION, 2, 1)
        )
      )
    end

    assert 'cannot move into check' do
      near_check = [[0, 0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, BK,0, 0, 0],
                    [0, 0, WQ,0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0, 0]]
                   .to_board

      expect_invalid(
        run_rule(
          REAL_KING_RULE,
          near_check,
          FROM_POSITION,
          shift_position(FROM_POSITION, -1, 0)
        )
      )
    end

    group 'castling' do
      castle_result  = proc { |result| result == CASTLE }
      invalid_result = proc { |result| result == INVALID }
      rule_proc      = proc { |board, from, to|
                         run_rule(REAL_KING_RULE, board, from, to, NULL_POS, NULL_POS)
                       }

      group 'is valid' do
        board = [[BR,0, 0, 0, BK,0, 0, BR],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [WR,0, 0, 0, WK,0, 0, WR]]
                .to_board

        test_castling board, board, perform: rule_proc, expect: castle_result
      end

      group 'is invalid when' do
        group 'when positions are off' do
          board = [[BR,0, 0, 0, BK,0, 0, BR],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [WR,0, 0, 0, WK,0, 0, WR]]
                  .to_board

          group 'horizontally' do
            test_castling board, board,
              perform: proc { |board, from, to|
                         amount = LEFT[from].to_i > LEFT[to].to_i ? 1 : -1

                         run_rule(
                           REAL_KING_RULE,
                           board,
                           shift_position(from, amount, 0),
                           to
                         )
                       },
              expect: invalid_result
          end

          group 'vertically' do
            test_castling board, board,
              perform: proc { |board, from, to|
                         amount = IS_BLACK[GET_POSITION[board, from]][1, -1]

                         run_rule(
                           REAL_KING_RULE,
                           board,
                           shift_position(from, 0, amount),
                           to
                         )
                       },
              expect: invalid_result
          end
        end

        group 'path is blocked' do
          board = [[BR,0, BP,0, BK,0, BP,BR],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [WR,0, WP,0, WK,0, WP,WR]]
                  .to_board

          test_castling board, board, perform: rule_proc, expect: invalid_result
        end

        group 'king has moved' do
          board = [[BR,0, 0, 0, MBK,0, 0, BR],
                   [0, 0, 0, 0, 0,  0, 0, 0],
                   [0, 0, 0, 0, 0,  0, 0, 0],
                   [0, 0, 0, 0, 0,  0, 0, 0],
                   [0, 0, 0, 0, 0,  0, 0, 0],
                   [0, 0, 0, 0, 0,  0, 0, 0],
                   [0, 0, 0, 0, 0,  0, 0, 0],
                   [WR,0, 0, 0, MWK,0, 0, WR]]
                  .to_board

          test_castling board, board, perform: rule_proc, expect: invalid_result
        end

        group 'rook has moved' do
          board = [[MBR,0, 0, 0, BK,0, 0, MBR],
                   [0,  0, 0, 0, 0, 0, 0, 0],
                   [0,  0, 0, 0, 0, 0, 0, 0],
                   [0,  0, 0, 0, 0, 0, 0, 0],
                   [0,  0, 0, 0, 0, 0, 0, 0],
                   [0,  0, 0, 0, 0, 0, 0, 0],
                   [0,  0, 0, 0, 0, 0, 0, 0],
                   [MWR,0, 0, 0, WK,0, 0, MWR]]
                  .to_board

          test_castling board, board, perform: rule_proc, expect: invalid_result
        end

        group 'king is in check' do
          black_board = [[BR,0, 0, 0, BK,0, 0, BR],
                         [0, 0, 0, 0, WR,0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0] ]
                        .to_board

          white_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, 0, 0, 0, 0],
                         [0, 0, 0, 0, BR,0, 0, 0],
                         [WR,0, 0, 0, WK,0, 0, WR]]
                        .to_board

          test_castling black_board, white_board, perform: rule_proc, expect: invalid_result
        end

        group 'king is moving into check' do
          board = [[BR,0, 0, 0, BK,0, 0, BR],
                   [0, 0, WR,0, 0, 0, WR,0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, BR,0, 0, 0, BR,0],
                   [WR,0, 0, 0, WK,0, 0, WR]]
                  .to_board

          test_castling board, board, perform: rule_proc, expect: invalid_result
        end

        group 'king is moving past check' do
          board = [[BR,0, 0, 0, BK,0, 0, BR],
                   [0, 0, 0, WR,0, WR,0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, BR,0, BR,0, 0],
                   [WR,0, 0, 0, WK,0, 0, WR]]
                  .to_board

          test_castling board, board, perform: rule_proc, expect: invalid_result
        end

        assert 'moving wildly' do
          board = [[BR,0, 0, 0, BK,0, 0, BR],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [BP,BP,BP,BP,BP,BP,BP,BP],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [WR,0, 0, 0, 0, 0, WK, WR]]
                  .to_board

          expect_invalid run_rule(REAL_KING_RULE, board, position(4, 0), position(0, 7))
        end
      end
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
            run_rule(
              REAL_KNIGHT_RULE,
              board,
              FROM_POSITION,
              valid_move
            )
          )
        end
      end
    end

    capturing_basics   REAL_KNIGHT_RULE, 1, 2
    cannot_cause_check REAL_KNIGHT_RULE, 1, 2
    knights_moves      NOTHING_SURROUNDING_BLACK

    group 'if a piece is in the way' do
      knights_moves SURROUNDED
    end

    assert 'cannot move arbitrarily' do
      expect_invalid(
        run_rule(
          REAL_KNIGHT_RULE,
          NOTHING_SURROUNDING_BLACK,
          FROM_POSITION,
          shift_position(FROM_POSITION, -1, 1)
        )
      )
    end
  end

  group 'PAWN_RULE' do
    starting_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                      [BP,BP,BP,BP,BP,BP,BP,BP],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [0, 0, 0, 0, 0, 0, 0, 0],
                      [WP,WP,WP,WP,WP,WP,WP,WP],
                      [0, 0, 0, 0, 0, 0, 0, 0]]
                     .to_board

    capturing_basics   REAL_PAWN_RULE, 1, 1
    cannot_cause_check REAL_PAWN_RULE, 0, 1

    group 'can move forward by one' do
      assert 'white' do
        expect_valid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(4, 6),
            position(4, 5)
          )
        )
      end

      assert 'black' do
        expect_valid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(1, 1),
            position(1, 2)
          )
        )
      end
    end

    group 'can move forward by two on the first move' do
      assert 'white' do
        expect_valid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(4, 6),
            position(4, 4)
          )
        )
      end

      assert 'black' do
        expect_valid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(1, 1),
            position(1, 3)
          )
        )
      end
    end

    group 'cannot move forward by two on subsequent moves' do
      later_board = [[0, 0,  0, 0, 0,  0, 0, 0],
                     [0, 0,  0, 0, 0,  0, 0, 0],
                     [0, MBP,0, 0, 0,  0, 0, 0],
                     [0, 0,  0, 0, 0,  0, 0, 0],
                     [0, 0,  0, 0, 0,  0, 0, 0],
                     [0, 0,  0, 0, MWP,0, 0, 0],
                     [0, 0,  0, 0, 0,  0, 0, 0],
                     [0, 0,  0, 0, 0,  0, 0, 0]]
                    .to_board

      assert 'white' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            later_board,
            position(4, 5),
            position(4, 3)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            later_board,
            position(1, 2),
            position(1, 4)
          )
        )
      end
    end

    group 'cannot move backwards' do
      assert 'white' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(4, 6),
            position(4, 7)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(1, 1),
            position(1, 0)
          )
        )
      end
    end

    group 'cannot move diagonally without capturing' do
      assert 'white' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(4, 6),
            position(5, 5)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(1, 1),
            position(0, 2)
          )
        )
      end
    end

    group 'cannot move sideways' do
      assert 'white' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(4, 6),
            position(5, 6)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            starting_board,
            position(1, 1),
            position(0, 1)
          )
        )
      end
    end

    group 'cannot capture sideways' do
      sideways_capture_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                                [WP,BP,0, 0, 0, 0, 0, 0],
                                [0, 0, 0, 0, 0, 0, 0, 0],
                                [0, 0, 0, 0, 0, 0, 0, 0],
                                [0, 0, 0, 0, 0, 0, 0, 0],
                                [0, 0, 0, 0, 0, 0, 0, 0],
                                [0, 0, 0, 0, WP,BP,0, 0],
                                [0, 0, 0, 0, 0, 0, 0, 0]]
                               .to_board

      assert 'white' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            sideways_capture_board,
            position(4, 6),
            position(5, 6)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            sideways_capture_board,
            position(1, 1),
            position(0, 1)
          )
        )
      end
    end

    group 'can capture forward diagonally' do
      capture_board = [[0,  0,  0, 0, 0,  0,  0, 0],
                       [0,  0,  0, 0, 0,  0,  0, 0],
                       [0,  MBP,0, 0, 0,  0,  0, 0],
                       [MWP,0,  0, 0, 0,  0,  0, 0],
                       [0,  0,  0, 0, 0,  MBP,0, 0],
                       [0,  0,  0, 0, MWP,0,  0, 0],
                       [0,  0,  0, 0, 0,  0,  0, 0],
                       [0,  0,  0, 0, 0,  0,  0, 0]]
                      .to_board

      assert 'white' do
        expect_valid(
          run_rule(
            REAL_PAWN_RULE,
            capture_board,
            position(4, 5),
            position(5, 4)
          )
        )
      end

      assert 'black' do
        expect_valid(
          run_rule(
            REAL_PAWN_RULE,
            capture_board,
            position(1, 2),
            position(0, 3)
          )
        )
      end
    end

    group 'cannot capture backwards diagonally' do
      capture_board = [[0,  0,  0, 0, 0,  0,  0, 0],
                       [MWP,0,  0, 0, 0,  0,  0, 0],
                       [0,  MBP,0, 0, 0,  0,  0, 0],
                       [0,  0,  0, 0, 0,  0,  0, 0],
                       [0,  0,  0, 0, 0,  0,  0, 0],
                       [0,  0,  0, 0, MWP,0,  0, 0],
                       [0,  0,  0, 0, 0,  MBP,0, 0],
                       [0,  0,  0, 0, 0,  0,  0, 0]]
                      .to_board

      assert 'white' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            capture_board,
            position(4, 5),
            position(5, 6)
          )
        )
      end

      assert 'black' do
        expect_invalid(
          run_rule(
            REAL_PAWN_RULE,
            capture_board,
            position(1, 2),
            position(0, 1)
          )
        )
      end
    end

    en_passant_board = [[0, 0,  0, 0, 0,  0, 0, 0],
                        [0, 0,  0, 0, 0,  0, 0, 0],
                        [0, 0,  0, 0, 0,  0, 0, 0],
                        [0, MBP,WP,0, 0,  0, 0, 0],
                        [0, 0,  0, BP,MWP,0, 0, 0],
                        [0, 0,  0, 0, 0,  0, 0, 0],
                        [0, 0,  0, 0, 0,  0, 0, 0],
                        [0, 0,  0, 0, 0,  0, 0, 0]]
                       .to_board

    group 'can capture en passant' do
      assert 'white' do
        expect_en_passant(
          run_rule(
            REAL_PAWN_RULE,
            en_passant_board,
            position(2, 3),
            position(1, 2),
            position(1, 1),
            position(1, 3)
          )
        )
      end

      assert 'black' do
        expect_en_passant(
          run_rule(
            REAL_PAWN_RULE,
            en_passant_board,
            position(3, 4),
            position(4, 5),
            position(4, 6),
            position(4, 4)
          )
        )
      end

      group 'only if last moved was a pawn' do
        non_passant_board = [[0, 0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0, 0],
                             [0, BQ,WP,0, 0, 0, 0, 0],
                             [0, 0, 0, BP,WQ,0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0, 0],
                             [0, 0, 0, 0, 0, 0, 0, 0]]
                            .to_board

        assert 'white' do
          expect_invalid(
            run_rule(
              REAL_PAWN_RULE,
              non_passant_board,
              position(2, 3),
              position(1, 2),
              position(1, 1),
              position(1, 3)
            )
          )
        end

        assert 'black' do
          expect_invalid(
            run_rule(
              REAL_PAWN_RULE,
              non_passant_board,
              position(3, 4),
              position(4, 5),
              position(4, 6),
              position(4, 4)
            )
          )
        end
      end

      group 'only if the last moved pawn moved two' do
        assert 'white' do
          expect_invalid(
            run_rule(
              REAL_PAWN_RULE,
              en_passant_board,
              position(2, 3),
              position(1, 2),
              position(1, 2),
              position(1, 3)
            )
          )
        end

        assert 'black' do
          expect_invalid(
            run_rule(
              REAL_PAWN_RULE,
              en_passant_board,
              position(3, 4),
              position(4, 5),
              position(4, 5),
              position(4, 4)
            )
          )
        end
      end
    end
  end
end
