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

# Pair Functions

PAIR = ->(left, right) {
  ->(select) { select[left, right] }
}

LEFT  = ->(pair) { pair[FIRST]  }
RIGHT = ->(pair) { pair[SECOND] }

# Lists

NTH = ->(list, index) { LEFT[index[RIGHT, list]] }

LIST_MAP = ->(tuple, size, func) {
  LEFT[
    size[
      ->(memo) {
        PAIR[
          PAIR[
            func[
              NTH[tuple, RIGHT[memo]],
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
FIVE       = ->(func, zero) { func[func[func[func[func[zero]]]]] }
SIX        = ->(func, zero) { func[func[func[func[func[func[zero]]]]]] }
SEVEN      = ->(func, zero) { func[func[func[func[func[func[func[zero]]]]]]] }
EIGHT      = ->(func, zero) { func[func[func[func[func[func[func[func[zero]]]]]]]] }
NINE       = ->(func, zero) { func[func[func[func[func[func[func[func[func[zero]]]]]]]]] }
TEN        = ->(func, zero) { func[func[func[func[func[func[func[func[func[func[zero]]]]]]]]]] }
FIFTEEN    = MULTIPLY[FIVE, THREE]
TWENTY     = MULTIPLY[FOUR, FIVE]
SIXTY_FOUR = MULTIPLY[EIGHT, EIGHT]

# Magic Numbers

MOVED_OFFSET = TWENTY
WHITE_OFFSET = TEN

BOARD_SPACES = SIXTY_FOUR
SIDE_LENGTH  = EIGHT

BLACK_PAWN_ROW = ONE
WHITE_PAWN_ROW = SIX
BLACK_HOME_ROW = ZERO
WHITE_HOME_ROW = SEVEN
KING_COLUMN    = FOUR

EMPTY_SPACE = ZERO

BLACK_PAWN   = ONE
BLACK_ROOK   = FIVE
BLACK_KNIGHT = THREE
BLACK_BISHOP = FOUR
BLACK_QUEEN  = NINE
BLACK_KING   = TEN

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
  AND[IS_GREATER_OR_EQUAL[a, b], IS_GREATER_OR_EQUAL[b, a]]
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
