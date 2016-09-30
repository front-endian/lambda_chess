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

MOVE = ->(board, from, to) {
  LIST_MAP[
    board,
    SIXTY_FOUR,
    ->(old_piece, index) {
      IS_EQUAL[index, POSITION_TO_INDEX[from]][
        ZERO,
        IS_EQUAL[index, POSITION_TO_INDEX[to]][
          NTH[board, POSITION_TO_INDEX[from]],
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
