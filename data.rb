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

# Pair Functions

PAIR = ->(left, right) {
  ->(select) { select[left, right] }
}

LEFT  = ->(pair) { pair[FIRST]  }
RIGHT = ->(pair) { pair[SECOND] }

# Tuples

NTH = ->(list, index) { LEFT[index[RIGHT, list]] }

TUPLE_MAP = ->(tuple, size, func) {
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
        IF_GREATER_OR_EQUAL[LEFT[memo], b][
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
        IF_GREATER_OR_EQUAL[LEFT[memo], b][
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

# Numbers

ZERO       = ->(func, zero) { zero }
ONE        = ->(func, zero) { func[zero] }
THREE      = ->(func, zero) { func[func[func[zero]]] }
FOUR       = ->(func, zero) { func[func[func[func[zero]]]] }
FIVE       = ->(func, zero) { func[func[func[func[func[zero]]]]] }
EIGHT      = ->(func, zero) { func[func[func[func[func[func[func[func[zero]]]]]]]] }
NINE       = ->(func, zero) { func[func[func[func[func[func[func[func[func[zero]]]]]]]]] }
TEN        = ->(func, zero) { func[func[func[func[func[func[func[func[func[func[zero]]]]]]]]]] }
ELEVEN     = ->(func, zero) { func[func[func[func[func[func[func[func[func[func[func[zero]]]]]]]]]]] }
THIRTEEN   = ->(func, zero) { func[func[func[func[func[func[func[func[func[func[func[func[func[zero]]]]]]]]]]]]] }
FOURTEEN   = ->(func, zero) { func[func[func[func[func[func[func[func[func[func[func[func[func[func[zero]]]]]]]]]]]]]] }
FIFTEEN    = MULTIPLY[FIVE, THREE]
NINETEEN   = ADD[FIFTEEN, FOUR]
TWENTY     = MULTIPLY[FOUR, FIVE]
SIXTY_FOUR = MULTIPLY[EIGHT, EIGHT]

# Comparisons

IF_ZERO = ->(number) {
  number[->(_) { SECOND }, FIRST]
}

IF_GREATER_OR_EQUAL = ->(a, b) {
  IF_ZERO[SUBTRACT[b, a]]
}

IF_EQUAL = ->(a, b) {
  AND[IF_GREATER_OR_EQUAL[a, b], IF_GREATER_OR_EQUAL[b, a]]
}
