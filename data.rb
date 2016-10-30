# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Choice Functions

FIRST  = ->(first, second) { first  }
SECOND = ->(first, second) { second }

AND = ->(a, b) {
  ->(first, second) {
    a[b[first, second], second]
  }
}

OR = ->(a, b) {
  ->(first, second) {
    a[first, b[first, second]]
  }
}

NOT = ->(choice) {
  ->(first, second) {
    choice[second, first]
  }
}

FIVE_CONDITIONS_MET = ->(cond_1, cond_2, cond_3, cond_4, cond_5) {
  ->(first, second) {
    cond_1[cond_2[cond_3[cond_4[cond_5[
      first,
      second],
      second],
      second],
      second],
      second]
  }
}

IF = ->(condition) {
  ->(first, second) {
    condition[first, second][]
  }
}

ALWAYS_FIRST = ->(condition) { FIRST }

# Math Functions

IDENTITY = ->(x) { x }

INCREMENT = ->(a) { ADD[ONE, a] }

ADD = ->(a, b) {
  ->(func, zero) {
    b[func, a[func, zero]]
  }
}

DECREMENT = ->(a) {
  RIGHT[
    a[
      ->(memo) {
        PAIR[
          INCREMENT[LEFT[memo]],
          LEFT[memo]
        ]
      },
      PAIR[ZERO, ZERO]
    ]
  ]
}

SUBTRACT = ->(a, b) {
  ->(func, zero) {
    b[DECREMENT, a][func, zero]
  }
}

MULTIPLY = ->(a, b) {
  ->(func, zero) {
    a[
      ->(value) { b[func, value] },
      zero
    ]
  }
}

DELTA = ->(position_1, position_2, coordinate) {
  ->(a, b) {
    IS_GREATER_OR_EQUAL[a, b][
      SUBTRACT[a, b],
      SUBTRACT[b, a]
    ]
  }[
    coordinate[position_1],
    coordinate[position_2]
  ]
}

# Numbers

ZERO       = ->(succ, zero) { zero }
ONE        = ->(succ, zero) { succ[zero] }
TWO        = ->(succ, zero) { succ[succ[zero]] }
THREE      = ->(succ, zero) { succ[succ[succ[zero]]] }
FOUR       = ->(succ, zero) { succ[succ[succ[succ[zero]]]] }
FIVE       = ADD[TWO, THREE]
SIX        = MULTIPLY[TWO, THREE]
SEVEN      = ADD[THREE, FOUR]
EIGHT      = MULTIPLY[TWO, FOUR]

# Pair Functions

PAIR = ->(left, right) {
  ->(select) { select[left, right] }
}

LEFT  = ->(pair) { pair[FIRST]  }
RIGHT = ->(pair) { pair[SECOND] }

# Lists Functions

NTH = ->(list, index) { LEFT[index[RIGHT, list]] }

LIST_MAP = ->(list, size, func) {
  LEFT[
    size[
      ->(memo) {
        PAIR[
         PAIR[
           func[
             NTH[list, RIGHT[memo]],
             RIGHT[memo]
           ],
           LEFT[memo]
          ],
          DECREMENT[RIGHT[memo]]
        ]
      },
      PAIR[ZERO, DECREMENT[size]]
    ]
  ]
}

LIST_REDUCE = ->(list, size, func, initial) {
  LEFT[
    size[
      ->(memo) {
        PAIR[
          func[
            # previous
            LEFT[memo],
            # next
            NTH[list, RIGHT[memo]],
            # index
            RIGHT[memo],
          ],
          INCREMENT[RIGHT[memo]]
        ]
      },
      PAIR[initial, ZERO]
    ]
  ]
}

# Vector Functions

EMPTY_VECTOR = PAIR[ZERO, ZERO]

VECTOR_SIZE = RIGHT
VECTOR_LIST = LEFT

VECTOR_APPEND = ->(vector, item) {
  PAIR[
    PAIR[item, VECTOR_LIST[vector]],
    INCREMENT[VECTOR_SIZE[vector]]
  ]
}

VECTOR_FIRST = ->(vector) {
  NTH[VECTOR_LIST[vector], ZERO]
}

VECTOR_MAP = ->(vector, func) {
  PAIR[
    LIST_MAP[
      VECTOR_LIST[vector],
      VECTOR_SIZE[vector],
      ->(item, index) { func[item] }
    ],
    VECTOR_SIZE[vector]
  ]
}

VECTOR_REDUCE = ->(vector, func, initial) {
  LIST_REDUCE[
    VECTOR_LIST[vector],
    VECTOR_SIZE[vector],
    ->(memo, item, index) { func[memo, item] },
    initial
  ]
}

# Magic Numbers

SIDE_LENGTH = EIGHT

BLACK_PAWN_ROW = ONE
WHITE_PAWN_ROW = SIX
BLACK_HOME_ROW = ZERO
WHITE_HOME_ROW = SEVEN
KING_COLUMN    = FOUR

PAWN_VALUE   = ONE
KNIGHT_VALUE = TWO
BISHOP_VALUE = THREE
ROOK_VALUE   = FOUR
QUEEN_VALUE  = FIVE
KING_VALUE   = SIX

# Piece data

GET_COLOR    = ->(piece) { LEFT[LEFT[piece]] }
GET_VALUE    = ->(piece) { RIGHT[LEFT[piece]] }
GET_OCCUPIED = ->(piece) { LEFT[RIGHT[piece]] }
GET_MOVED    = ->(piece) { RIGHT[RIGHT[piece]] }

OCCUPIED = FIRST
EMPTY    = SECOND

UNMOVED  = SECOND
MOVED    = FIRST

BLACK = FIRST
WHITE = SECOND

MAKE_PIECE = ->(color, value, occupied, moved) {
  PAIR[PAIR[color, value], PAIR[occupied, moved]]
}

INITIAL_PIECE = ->(color, value) {
  MAKE_PIECE[color, value, OCCUPIED, UNMOVED]
}

EMPTY_SPACE = MAKE_PIECE[BLACK, ZERO, EMPTY, UNMOVED]

BLACK_PAWN   = INITIAL_PIECE[BLACK, PAWN_VALUE]
BLACK_KNIGHT = INITIAL_PIECE[BLACK, KNIGHT_VALUE]
BLACK_BISHOP = INITIAL_PIECE[BLACK, BISHOP_VALUE]
BLACK_ROOK   = INITIAL_PIECE[BLACK, ROOK_VALUE]
BLACK_QUEEN  = INITIAL_PIECE[BLACK, QUEEN_VALUE]
BLACK_KING   = INITIAL_PIECE[BLACK, KING_VALUE]

WHITE_PAWN   = INITIAL_PIECE[WHITE, PAWN_VALUE]
WHITE_ROOK   = INITIAL_PIECE[WHITE, ROOK_VALUE]
WHITE_KNIGHT = INITIAL_PIECE[WHITE, KNIGHT_VALUE]
WHITE_BISHOP = INITIAL_PIECE[WHITE, BISHOP_VALUE]
WHITE_QUEEN  = INITIAL_PIECE[WHITE, QUEEN_VALUE]
WHITE_KING   = INITIAL_PIECE[WHITE, KING_VALUE]

IS_EMPTY = ->(piece) {
  NOT[GET_OCCUPIED[piece]]
}

IS_BLACK = ->(piece) {
  COLOR_SWITCH[piece][FIRST, SECOND, SECOND]
}

IS_WHITE = ->(piece) {
  COLOR_SWITCH[piece][SECOND, FIRST, SECOND]
}

COLOR_SWITCH = ->(piece) {
  ->(black, white, empty) {
    GET_OCCUPIED[piece][
      GET_COLOR[piece][
        black,
        white
      ],
      empty
    ]
  }
}

TO_MOVED_PIECE = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}

IS_MOVED = ->(piece) {
  GET_MOVED[piece]
}

HAS_VALUE = ->(piece, value) {
  IS_EQUAL[value, GET_VALUE[piece]]
}

# Comparisons

IS_ZERO = ->(number) {
  number[->(_) { SECOND }, FIRST]
}

IS_GREATER_OR_EQUAL = ->(a, b) {
  IS_ZERO[SUBTRACT[b, a]]
}

IS_EQUAL = ->(a, b) {
  IF[IS_GREATER_OR_EQUAL[a, b]][
    -> { IS_GREATER_OR_EQUAL[b, a] },
    -> { SECOND }
  ]
}
