# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'Play' do
  def board_array board
    board.list_to_a(8)
         .map { |row|
           row.list_to_a(8).map { |piece|
             GET_VALUE[piece].to_i + IS_BLACK[piece][KING_VALUE.to_i, 0]
           }
         }.flatten
  end

  def same_board board_a, board_b
    board_a.board_to_a == board_b.board_to_a
  end

  def safe_position_to_a object
    object.is_a?(Array) ? object : object.position_to_a
  end

  def same_position position_a, position_b
    safe_position_to_a(position_a) == safe_position_to_a(position_b)
  end

  def return_type type
    proc { |new_state| { state: new_state, type: type } }
  end

  def make_state board, move, last_move = [[0, 0], [0, 0]], promotion: WHITE_QUEEN, seed: 1
    CREATE_STATE[
      position(*move.first),
      position(*move.last),
      position(*last_move.first),
      position(*last_move.last),
      board,
      ZERO,
      promotion,
      seed.to_peano
    ]
  end

  def black_response board, from, to
    GET_BOARD[
      RIGHT[
        BLACK_AI[
          make_state(
            NORMAL_MOVE[board, position(*from), position(*to), nil],
            [from, to],
            [from, to]
          )
        ]
      ]
    ]
  end

  def perform_play type, state
    PLAY[
      state,
      return_type(:accept),
      return_type(:reject),
      return_type(:loss),
      return_type(:forfit)
    ].tap { |result|
      assert "#{type} proc is called" do
        result[:type] == type
      end
    }[:state]
  end

  def def_expect_unchanged type
    define_method("expect_#{type}") do |initial_state|
      result = perform_play(type, initial_state)

      assert 'board is unchanged' do
        same_board(GET_BOARD[initial_state], GET_BOARD[result])
      end

      assert '"last_from" is unchanged' do
        same_position(GET_LAST_FROM[initial_state], GET_LAST_FROM[result])
      end

      assert '"last_to" is unchanged' do
        same_position(GET_LAST_TO[initial_state], GET_LAST_TO[result])
      end
    end
  end

  def_expect_unchanged :reject
  def_expect_unchanged :loss
  def_expect_unchanged :forfit

  def expect_accept initial_state, result_board
    result = perform_play(:accept, initial_state)

    assert 'board updated' do
      same_board(result_board, GET_BOARD[result])
    end

    assert '"last_from" is set to "from"' do
      same_position(GET_FROM[initial_state], GET_LAST_FROM[result])
    end

    assert '"last_to" is set to "to"' do
      same_position(GET_TO[initial_state], GET_LAST_TO[result])
    end
  end

  assert 'moving an empty space' do
    expect_reject make_state(INITIAL_BOARD, [[0, 3], [1, 4]])
  end

  assert 'moving a black piece' do
    expect_reject make_state(INITIAL_BOARD, [[1, 1], [1, 2]])
  end

  assert 'capturing self' do
    expect_reject make_state(INITIAL_BOARD, [[2, 6], [2, 6]])
  end

  assert 'valid move' do
    from = [2, 6]
    to   = [2, 5]

    expect_accept(
      make_state(INITIAL_BOARD, [from, to]),
      black_response(INITIAL_BOARD, from, to)
    )
  end
end
