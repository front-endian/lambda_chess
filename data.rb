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
  LIST_REDUCE[
    LIST_REDUCE[
      list,
      size,
      ->(memo, element, index) {
        PAIR[
          func[element, index],
          memo
        ]
      },
      ZERO
    ],
    size,
    ->(memo, element, _) {
      PAIR[element, memo]
    },
    ZERO
  ]
}

LIST_REDUCE = ->(list, size, func, initial) {
  LEFT[
    size[
      ->(memo) {
        PAIR[
          func[
            LEFT[memo],
            NTH[list, RIGHT[memo]],
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

DIVIDE = ->(a, b) {
  RIGHT[
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
  ]
}

MODULUS = ->(a, b) {
  RIGHT[
    a[
      ->(memo) {
        IS_GREATER_OR_EQUAL[LEFT[memo], b][
          PAIR[
            SUBTRACT[LEFT[memo], b],
            ZERO
          ],
          PAIR[
            LEFT[memo],
            LEFT[memo]
          ]
        ]
      },
      PAIR[a, ZERO]
    ]
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

MOVED_OFFSET = THIRTEEN
WHITE_OFFSET = SIX

BOARD_SPACES = SIXTY_FOUR
SIDE_LENGTH  = EIGHT

BLACK_PAWN_ROW = ONE
WHITE_PAWN_ROW = SIX
BLACK_HOME_ROW = ZERO
WHITE_HOME_ROW = SEVEN
KING_COLUMN    = FOUR

BLACK = FIRST
WHITE = SECOND

EMPTY_SPACE = ZERO

BLACK_PAWN   = ONE
BLACK_KNIGHT = TWO
BLACK_BISHOP = THREE
BLACK_ROOK   = FOUR
BLACK_QUEEN  = FIVE
BLACK_KING   = SIX

WHITE_PAWN   = ADD[BLACK_PAWN,   WHITE_OFFSET]
WHITE_ROOK   = ADD[BLACK_ROOK,   WHITE_OFFSET]
WHITE_KNIGHT = ADD[BLACK_KNIGHT, WHITE_OFFSET]
WHITE_BISHOP = ADD[BLACK_BISHOP, WHITE_OFFSET]
WHITE_QUEEN  = ADD[BLACK_QUEEN,  WHITE_OFFSET]
WHITE_KING   = ADD[BLACK_KING,   WHITE_OFFSET]

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
