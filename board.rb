# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Board Functions

BOARD_MAP = ->(board, func) {
  LIST_MAP[
    board,
    SIDE_LENGTH,
    ->(row, y) {
      LIST_MAP[
        row,
        SIDE_LENGTH,
        ->(piece, x) {
          func[piece, PAIR[x, y]]
        }
      ]
    }
  ]
}

BOARD_REDUCE = ->(board, func, initial) {
  LIST_REDUCE[
    board,
    SIDE_LENGTH,
    ->(memo, row, y) {
      LIST_REDUCE[
        row,
        SIDE_LENGTH,
        ->(memo, piece, x) {
          func[memo, piece, PAIR[x, y]]
        },
        memo
      ]
    },
    initial
  ]
}

SAME_POSITION = ->(a, b) {
  AND[
    IS_EQUAL[LEFT[a], LEFT[b]],
    IS_EQUAL[RIGHT[a], RIGHT[b]]
  ]
}

GET_POSITION = ->(board, position) {
  NTH[NTH[board, RIGHT[position]], LEFT[position]]
}

CHANGE_FUNC = ->(from, to, coordinate) {
  ->(a, b) {
    IS_GREATER_OR_EQUAL[a, b][
      IS_EQUAL[a, b][
        IDENTITY,
        DECREMENT
      ],
      INCREMENT
    ]
  }[
    coordinate[from],
    coordinate[to]
  ]
}

FREE_PATH = ->(board, from, to, alter_length) {
  ->(delta_x, delta_y) {
    IF[
      OR[
        OR[
          IS_ZERO[delta_x],
          IS_ZERO[delta_y],
        ],
        IS_EQUAL[delta_x, delta_y]
      ]
    ][
      -> {
        RIGHT[
          # Get the number of positions that have to be checked
          alter_length[
            IS_ZERO[delta_x][
              DELTA[from, to, RIGHT],
              delta_x
            ]
          ][
            # For each position inbetween....
            ->(memo) {
              ->(new_postion) {
                PAIR[
                  new_postion,
                  # If a filled position hasn't been found, check for a piece
                  RIGHT[memo][
                    IS_EMPTY[GET_POSITION[board, new_postion]],
                    SECOND
                  ]
                ]
              }[
                # Calculate next postion to check
                PAIR[
                  CHANGE_FUNC[from, to, LEFT][LEFT[LEFT[memo]]],
                  CHANGE_FUNC[from, to, RIGHT][RIGHT[LEFT[memo]]]
                ]
              ]
            },
            PAIR[from, FIRST]
          ]
        ]
      },
      -> { SECOND }
    ]
  }[
    # "delta_x"
    DELTA[from, to, LEFT],
    # "delta_y"
    DELTA[from, to, RIGHT]
  ]
}

MOVE = ->(board, from, to) {
  BOARD_MAP[
    board,
    ->(old_piece, position) {
      IF[SAME_POSITION[position, to]][
        -> { TO_MOVED_PIECE[GET_POSITION[board, from]] },
        -> {
          SAME_POSITION[position, from][
            EMPTY_SPACE,
            old_piece
          ]
        }
      ]
    }
  ]
}

P = PAIR

INITIAL_BOARD =
  P[P[BLACK_ROOK,  P[BLACK_KNIGHT, P[BLACK_BISHOP, P[BLACK_QUEEN, P[BLACK_KING,  P[BLACK_BISHOP, P[BLACK_KNIGHT, P[BLACK_ROOK,  ZERO]]]]]]]],
  P[P[BLACK_PAWN,  P[BLACK_PAWN,   P[BLACK_PAWN,   P[BLACK_PAWN,  P[BLACK_PAWN,  P[BLACK_PAWN,   P[BLACK_PAWN,   P[BLACK_PAWN,  ZERO]]]]]]]],
  P[P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, ZERO]]]]]]]],
  P[P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, ZERO]]]]]]]],
  P[P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, ZERO]]]]]]]],
  P[P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, ZERO]]]]]]]],
  P[P[WHITE_PAWN,  P[WHITE_PAWN,   P[WHITE_PAWN,   P[WHITE_PAWN,  P[WHITE_PAWN,  P[WHITE_PAWN,   P[WHITE_PAWN,   P[WHITE_PAWN,  ZERO]]]]]]]],
  P[P[WHITE_ROOK,  P[WHITE_KNIGHT, P[WHITE_BISHOP, P[WHITE_QUEEN, P[WHITE_KING,  P[WHITE_BISHOP, P[WHITE_KNIGHT, P[WHITE_ROOK,  ZERO]]]]]]]],
  ZERO]]]]]]]]
