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
