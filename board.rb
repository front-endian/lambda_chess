# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Board Functions

POSITION_TO_INDEX = ->(position) {
  ADD[
    LEFT[position],
    MULTIPLY[RIGHT[position], EIGHT]
  ]
}

INDEX_TO_POSITION = ->(index) {
  PAIR[
    MODULUS[index, EIGHT],
    DIVIDE[index, EIGHT]
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

IS_OCCUPIED = ->(board, position) {
  IS_GREATER_OR_EQUAL[
    GET_POSITION[board, position],
    ONE
  ]
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
              IS_ZERO[GET_POSITION[board, new_postion]],
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
    SIXTY_FOUR,
    ->(old_piece, index) {
      IS_EQUAL[index, POSITION_TO_INDEX[from]][
        ZERO,
        IS_EQUAL[index, POSITION_TO_INDEX[to]][
          GET_POSITION[board, from],
          old_piece
        ]
      ]
    }
  ]
}

INITIAL_BOARD =
  PAIR[FIVE,    PAIR[THREE,    PAIR[FOUR,     PAIR[NINE,     PAIR[TEN,    PAIR[FOUR,    PAIR[THREE,     PAIR[FIVE,
  PAIR[ONE,     PAIR[ONE,      PAIR[ONE,      PAIR[ONE,      PAIR[ONE,    PAIR[ONE,     PAIR[ONE,       PAIR[ONE,
  PAIR[ZERO,    PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,   PAIR[ZERO,    PAIR[ZERO,      PAIR[ZERO,
  PAIR[ZERO,    PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,   PAIR[ZERO,    PAIR[ZERO,      PAIR[ZERO,
  PAIR[ZERO,    PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,   PAIR[ZERO,    PAIR[ZERO,      PAIR[ZERO,
  PAIR[ZERO,    PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,     PAIR[ZERO,   PAIR[ZERO,    PAIR[ZERO,      PAIR[ZERO,
  PAIR[ELEVEN,  PAIR[ELEVEN,   PAIR[ELEVEN,   PAIR[ELEVEN,   PAIR[ELEVEN, PAIR[ELEVEN,  PAIR[ELEVEN,    PAIR[ELEVEN,
  PAIR[FIFTEEN, PAIR[THIRTEEN, PAIR[FOURTEEN, PAIR[NINETEEN, PAIR[TWENTY, PAIR[FOURTEEN, PAIR[THIRTEEN, PAIR[FIFTEEN,
  ZERO]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
