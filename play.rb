# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

NORMAL_MOVE_VALUE,


PLAY = ->(board, from, to, last_from, last_to, move_type, promotion) {
  ->(perform_normal_move) {

    move_type[
      # Normal Move
      # Castle Left
      # Castle Right
      # Promote
    ]
  }[
    # "perform_normal_move"
    -> {
      GET_RULE[GET_POSITION[board, from]][board, from, to, from, to]
    }
  ]
}

PERFORM_CASTLING = ->(old_board, from, to) {
  ->(is_moving_left) {
    MOVE[
      MOVE[old_board, from, to],
      # Rook position
      PAIR[is_moving_left[ZERO, SEVEN], RIGHT[from]],
      PAIR[
        is_moving_left[THREE, FIVE],
        RIGHT[from]
      ]
    ]
  }[
    # "is_moving_left"
    IS_GREATER_OR_EQUAL[LEFT[from], LEFT[to]]
  ]
}

MAX_PIECE_TOTAL = ADD[
  MULTIPLY[PAWN_VALUE, EIGHT],
  ADD[
    MULTIPLY[KNIGHT_VALUE, TWO],
    ADD[
      MULTIPLY[BISHOP_VALUE, TWO],
      ADD[
        MULTIPLY[ROOK_VALUE, TWO],
        ADD[
          QUEEN_VALUE,
          KING_VALUE
        ]
      ]
    ]
  ]
]

SCORE = ->(board, color) {
  BOARD_REDUCE[
    board,
    ->(memo, piece, position) {
      IS_BLACK[piece][
        color[ADD, SUBTRACT],
        color[SUBTRACT, ADD]
      ][
        memo,
        GET_VALUE[piece]
      ]
    },
    MAX_PIECE_TOTAL
  ]
}
