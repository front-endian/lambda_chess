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

SIX_CONDITIONS_MET = ->(cond_1, cond_2, cond_3, cond_4, cond_5, cond_6) {
  ->(first, second) {
    cond_1[cond_2[cond_3[cond_4[cond_5[cond_6[
      first,
      second],
      second],
      second],
      second],
      second],
      second]
  }
}

IF = ->(condition) {
  ->(first, second) {
    condition[
      -> { first[] },
      -> { second[] }
    ][]
  }
}

# Pair Functions

PAIR = ->(left, right) {
  ->(select) { select[left, right] }
}

LEFT  = ->(pair) { pair[FIRST]  }
RIGHT = ->(pair) { pair[SECOND] }

# Lists

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

MOD_AND_DIVIDE = ->(a, b) {
  a[
    ->(memo) {
      IS_GREATER_OR_EQUAL[LEFT[memo], b][
        PAIR[
          SUBTRACT[LEFT[memo], b],
          INCREMENT[RIGHT[memo]]
        ],
        memo
      ]
    },
    PAIR[a, ZERO]
  ]
}

ABSOLUTE_DIFFERENCE = ->(x, y) {
  IS_GREATER_OR_EQUAL[x, y][
    SUBTRACT[x, y],
    SUBTRACT[y, x]
  ]
}

# Numbers

ZERO       = ->(func, zero) { zero }
ONE        = ->(func, zero) { func[zero] }
TWO        = ->(func, zero) { func[func[zero]] }
THREE      = ->(func, zero) { func[func[func[zero]]] }
FOUR       = ->(func, zero) { func[func[func[func[zero]]]] }
FIVE       = ADD[TWO, THREE]
SIX        = MULTIPLY[TWO, THREE]
SEVEN      = ADD[THREE, FOUR]
EIGHT      = MULTIPLY[TWO, FOUR]
THIRTEEN   = ADD[MULTIPLY[THREE, FOUR], ONE]
SIXTY_FOUR = MULTIPLY[MULTIPLY[FOUR, FOUR], FOUR]

# Magic Numbers

BOARD_SPACES = SIXTY_FOUR
SIDE_LENGTH  = EIGHT

BLACK_PAWN_ROW = ONE
WHITE_PAWN_ROW = SIX
BLACK_HOME_ROW = ZERO
WHITE_HOME_ROW = SEVEN
KING_COLUMN    = FOUR

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

PAWN   = ONE
KNIGHT = TWO
BISHOP = THREE
ROOK   = FOUR
QUEEN  = FIVE
KING   = SIX

MAKE_PIECE = ->(color, value, occupied, moved) {
  PAIR[PAIR[color, value], PAIR[occupied, moved]]
}

INITIAL_PIECE = ->(color, value) {
  MAKE_PIECE[color, value, OCCUPIED, UNMOVED]
}

EMPTY_SPACE = MAKE_PIECE[BLACK, ZERO, EMPTY, UNMOVED]

BLACK_PAWN   = INITIAL_PIECE[BLACK, PAWN]
BLACK_KNIGHT = INITIAL_PIECE[BLACK, KNIGHT]
BLACK_BISHOP = INITIAL_PIECE[BLACK, BISHOP]
BLACK_ROOK   = INITIAL_PIECE[BLACK, ROOK]
BLACK_QUEEN  = INITIAL_PIECE[BLACK, QUEEN]
BLACK_KING   = INITIAL_PIECE[BLACK, KING]

WHITE_PAWN   = INITIAL_PIECE[WHITE, PAWN]
WHITE_ROOK   = INITIAL_PIECE[WHITE, ROOK]
WHITE_KNIGHT = INITIAL_PIECE[WHITE, KNIGHT]
WHITE_BISHOP = INITIAL_PIECE[WHITE, BISHOP]
WHITE_QUEEN  = INITIAL_PIECE[WHITE, QUEEN]
WHITE_KING   = INITIAL_PIECE[WHITE, KING]

IS_EMPTY_AT = ->(board, position) {
  COLOR_AT_SWITCH[board, position][SECOND, SECOND, FIRST]
}

IS_BLACK_AT = ->(board, position) {
  COLOR_AT_SWITCH[board, position][FIRST, SECOND, SECOND]
}

IS_WHITE_AT = ->(board, position) {
  COLOR_AT_SWITCH[board, position][SECOND, FIRST, SECOND]
}

COLOR_AT_SWITCH = ->(board, position) {
  COLOR_SWITCH[GET_POSITION[board, position]]
}

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
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], OCCUPIED, MOVED]
}

TO_UNMOVED_PIECE = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], OCCUPIED, UNMOVED]
}

IS_MOVED = ->(piece) {
  GET_MOVED[piece]
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

COMPARE = ->(a, b) {
  ->(less, equal, greater) {
    IS_GREATER_OR_EQUAL[a, b][
      IS_EQUAL[a, b][
        equal,
        greater
      ],
      less
    ]
  }
}
