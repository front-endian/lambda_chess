# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Choice Functions

FIRST  = ->(first, second) { first  }
SECOND = ->(first, second) { second }

# Pair Functions

PAIR = ->(left, right) {
  ->(select) { select[left, right] }
}

LEFT  = ->(pair) { pair[FIRST]  }
RIGHT = ->(pair) { pair[SECOND] }

NTH = ->(list, index) { LEFT[index[RIGHT, list]] }

# Numbers

ZERO  = ->(func, base) { base }
ONE   = ->(func, base) { func[base] }

# Math Functions

INCREMENT = ->(a) { ADD[ONE, a] }

ADD = ->(a, b) {
  ->(func, base) {
    b[func, a[func, base]]
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
  ->(func, base) {
    b[DECREMENT, a][func, base]
  }
}

MULTIPLY = ->(a, b) {
  ->(func, base) {
    a[
      ->(value) { b[func, value] },
      base
    ]
  }
}

DIVIDE = ->(a, b) {
  RIGHT[
    a[
      ->(memo) {
        GREATER_OR_EQUAL[LEFT[memo], b][
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
        GREATER_OR_EQUAL[LEFT[memo], b][
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

# Comparisons

AND = ->(a, b) {
  ->(first, second) {
    a[b[first, second], second]
  }
}

IS_ZERO = ->(number) {
  number[->(_) { SECOND }, FIRST]
}

GREATER_OR_EQUAL = ->(a, b) {
  IS_ZERO[SUBTRACT[b, a]]
}

EQUAL = ->(a, b) {
  AND[GREATER_OR_EQUAL[a, b], GREATER_OR_EQUAL[b, a]]
}
