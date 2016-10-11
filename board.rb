# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Board Functions

POSITION_TO_INDEX = ->(position) {
  ADD[
    LEFT[position],
    MULTIPLY[RIGHT[position], SIDE_LENGTH]
  ]
}

INDEX_TO_POSITION = ->(index) {
  PAIR[
    MODULUS[index, SIDE_LENGTH],
    DIVIDE[index, SIDE_LENGTH]
  ]
}

DISTANCE = ->(position_1, position_2) {
  PAIR[
    ABSOLUTE_DIFFERENCE[LEFT[position_1], LEFT[position_2]],
    ABSOLUTE_DIFFERENCE[RIGHT[position_1], RIGHT[position_2]]
  ]
}

GET_POSITION = ->(board, position) {
  NTH[board, POSITION_TO_INDEX[position]]
}

SET_POSITION = ->(board, position, new_value) {
  LIST_MAP[
    board,
    BOARD_SPACES,
    ->(old_piece, index) {
      IS_EQUAL[index, POSITION_TO_INDEX[position]][
        new_value,
        old_piece
      ]
    }
  ]
}

IS_EMPTY = ->(board, position) {
  IS_EQUAL[GET_POSITION[board, position], EMPTY_SPACE]
}

IS_BLACK = ->(piece_number) {
  IS_GREATER_OR_EQUAL[
    TO_MOVED_PIECE[WHITE_OFFSET],
    TO_MOVED_PIECE[piece_number]
  ]
}

TO_MOVED_PIECE = ->(piece_number) {
  IS_MOVED[piece_number][
    piece_number,
    ADD[piece_number, MOVED_OFFSET]
  ]
}

TO_UNMOVED_PIECE = ->(piece_number) {
  IS_MOVED[piece_number][
    SUBTRACT[piece_number, MOVED_OFFSET],
    piece_number
  ]
}

IS_MOVED = ->(piece_number) {
  IS_GREATER_OR_EQUAL[piece_number, MOVED_OFFSET]
}

CHANGE_FUNC = ->(from, to, coordinate) {
  COMPARE[coordinate[from], coordinate[to]][
    INCREMENT,
    IDENTITY,
    DECREMENT
  ]
}

FREE_PATH = ->(board, from, to, alter_length) {
  RIGHT[
    # Get the number of positions that have to be checked
    alter_length[
      IS_ZERO[ABSOLUTE_DIFFERENCE[LEFT[from], LEFT[to]]][
        ABSOLUTE_DIFFERENCE[RIGHT[from], RIGHT[to]],
        ABSOLUTE_DIFFERENCE[LEFT[from], LEFT[to]]
      ]
    ][
      # For each position inbetween....
      ->(memo) {
        ->(new_postion) {
          PAIR[
            new_postion,
            # If a filled position hasn't been found, check for a piece
            RIGHT[memo][
              IS_EMPTY[board, new_postion],
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
}

MOVE = ->(board, from, to) {
  LIST_MAP[
    board,
    BOARD_SPACES,
    ->(old_piece, index) {
      IS_EQUAL[index, POSITION_TO_INDEX[from]][
        EMPTY_SPACE,
        IS_EQUAL[index, POSITION_TO_INDEX[to]][
          TO_MOVED_PIECE[GET_POSITION[board, from]],
          old_piece
        ]
      ]
    }
  ]
}

P = PAIR

INITIAL_BOARD =
  P[BLACK_ROOK,  P[BLACK_KNIGHT, P[BLACK_BISHOP, P[BLACK_QUEEN, P[BLACK_KING,  P[BLACK_BISHOP, P[BLACK_KNIGHT, P[BLACK_ROOK,
  P[BLACK_PAWN,  P[BLACK_PAWN,   P[BLACK_PAWN,   P[BLACK_PAWN,  P[BLACK_PAWN,  P[BLACK_PAWN,   P[BLACK_PAWN,   P[BLACK_PAWN,
  P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE,
  P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE,
  P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE,
  P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE, P[EMPTY_SPACE, P[EMPTY_SPACE,  P[EMPTY_SPACE,  P[EMPTY_SPACE,
  P[WHITE_PAWN,  P[WHITE_PAWN,   P[WHITE_PAWN,   P[WHITE_PAWN,  P[WHITE_PAWN,  P[WHITE_PAWN,   P[WHITE_PAWN,   P[WHITE_PAWN,
  P[WHITE_ROOK,  P[WHITE_KNIGHT, P[WHITE_BISHOP, P[WHITE_QUEEN, P[WHITE_KING,  P[WHITE_BISHOP, P[WHITE_KNIGHT, P[WHITE_ROOK,
  ZERO]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
