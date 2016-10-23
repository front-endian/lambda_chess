# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

PLAY = ->(board, from, to, last_from, last_to, move_type, promotion) {

}

PERFORM_CASTLING = ->(old_board, from, to, last_from, last_to) {
  ->(is_moving_left) {
    ->(rook_from, nop, mid_to) {
      IF[
        ->(king, rook) {
          FIVE_CONDITIONS_MET[
            # Moving a king
            HAS_VALUE[king, KING_VALUE],
            # King is unmoved
            NOT[GET_MOVED[king]],
            # Moving a rook
            HAS_VALUE[rook, ROOK_VALUE],
            # Rook is unmoved
            NOT[GET_MOVED[rook]],
            # Path is free
            FREE_PATH[old_board, from, rook_from, DECREMENT]
          ]
        }[
          # "king"
          GET_POSITION[old_board, from],
          # "rook"
          GET_POSITION[old_board, rook_from]
        ]
      ][
        -> {
          IF[IS_NOT_IN_CHECK[old_board, from, from]][
            -> {
              IF[IS_NOT_IN_CHECK[old_board, from, mid_to]][
                -> {
                  IF[IS_NOT_IN_CHECK[old_board, from, to]][
                    -> {
                      MOVE[
                        MOVE[old_board, from, to],
                        rook_from,
                        PAIR[
                          is_moving_left[THREE, FIVE],
                          RIGHT[from]
                        ]
                      ]
                    },
                    nop
                  ]
                },
                nop
              ]
            },
            nop
          ]
        },
        nop
      ]
    }[
      # "rook_from"
      PAIR[
        is_moving_left[ZERO, SEVEN],
        RIGHT[from]
      ],
      # "nop"
      -> { old_board },
      # "mid_to"
      PAIR[
        is_moving_left[DECREMENT, INCREMENT][LEFT[from]],
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
