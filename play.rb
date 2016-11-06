# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

PLAY =
->(__if__) {
->(__five_conditions_met__) {
->(__not__) {
->(__or__) {
->(__and__) {
->(__second__) {
->(__first__) {
->(__four__) {
->(__three__) {
->(__two__) {
->(__one__) {
->(__zero__) {
->(__right__) {
->(__left__) {
->(__pair__) {
->(__add__) {
->(__five__) {
->(__white_queen__) {
->(__black_queen__) {
->(__increment__) {
->(__decrement__) {
->(__subtract__) {
->(__is_zero__) {
->(__is_greater_or_equal__) {
->(__is_equal__) {
->(__multiply__) {
->(__eight__) {
->(__seven__) {
->(__six__) {
->(_get_moved_) {
->(__get_occupied__) {
->(__get_value__) {
->(__get_color__) {
->(__nth__) {
->(__has_value__) {
->(__color_switch__) {
->(__is_white__) {
->(__is_black__) {
->(__is_empty__) {
->(__list_map__) {
->(__list_reduce__) {
->(__empty_vector__) {
->(__vector_append__) {
->(__vector_first__) {
->(__vector_reduce__) {
->(__delta__) {
->(__empty_space__) {
->(__get_last_to__) {
->(__get_from__) {
->(__get_to__) {
->(__get_board__) {
->(__get_last_from__) {
->(__get_promotion__) {
->(__get_score__) {
->(__create_state__) {
->(__with_basic_info__) {
->(__board_reduce__) {
->(__same_position__) {
->(__get_position__) {
->(__change_func__) {
->(__free_path__) {
->(__position_select__) {
->(__from_to_reduce__) {
->(__invalid__) {
->(__valid__) {
->(__isnt_invalid__) {
->(__is_not_in_check__) {
->(__change_move__) {
->(__normal_move__) {
->(__update_all_but_from_to_promotion__) {
->(__basic_checks__){
->(__straight_line_rule__) {
->(__pawn_rule__) {
->(__knight_rule__) {
->(__king_rule__) {
->(__bishop_rule__) {
->(__rook_rule__) {
->(__queen_rule__) {
->(__get_rule__) {
->(__advance_state__) {
->(__possible_moves__) {


->(state, accept, reject, loss, forfit, seed) {
  __if__[__is_black__[__get_position__[__get_board__[state]][__get_from__[state]]]][
    -> { reject[state] }][
    -> {
      __advance_state__[state][
        ->(new_state) {
          ->(response) {
            __if__[__left__[response]][
              -> {
                ->(response_state) {
                  __if__[
                    ->(board) {
                      ->(king_position_vector) {
                        __if__[
                          __from_to_reduce__[
                            king_position_vector][
                            __position_select__[board][->(_) { __first__ }]][
                            ->(memo) { ->(from) { ->(to) {
                              __if__[memo][
                                -> { __first__ }][
                                -> {
                                  __isnt_invalid__[
                                    __king_rule__[__get_rule__][
                                      __create_state__[from][to][from][to][board][__zero__][__white_queen__]
                                    ]
                                  ]
                                }
                              ]
                            }}}][
                            __second__
                          ]
                        ][
                          # King can move
                          -> { __first__ }][
                          # King can't move
                          -> {
                            __is_not_in_check__[board][__vector_first__[king_position_vector]][__get_rule__]
                          }
                        ]
                      }[
                        # "king_position_vector"
                        __position_select__[
                          board][
                          ->(piece) {
                            __and__[
                              __is_white__[piece]][
                              __has_value__[piece][__six__]
                            ]
                          }
                        ]
                      ]
                    }[
                      __get_board__[response_state]
                    ]
                  ][
                    -> { accept[response_state] }][
                    -> { loss[response_state] }
                  ]
                }[
                  # "response_state"
                  ->(older) {
                    __create_state__[
                      __get_from__[older]][
                      __get_to__[older]][
                      __get_from__[state]][
                      __get_to__[state]][
                      __get_board__[older]][
                      __get_score__[older]][
                      __get_promotion__[older]
                    ]
                  }[__right__[response]]
                ]
              }][
              -> { forfit[new_state] }
            ]
          }[
            # "response"
            ->(result) {
              __if__[__left__[result]][
                -> {
                  __advance_state__[__update_all_but_from_to_promotion__[__right__[result]][new_state]][
                    ->(new_state) { __pair__[__first__][new_state] }][
                    -> { __pair__[__second__][ __zero__] }
                  ]
                }][
                -> { result }
              ]
            }[
              # "result"
              ->(states) {
                __if__[__is_zero__[__right__[states]]][
                  -> { __pair__[__second__][__zero__] }][
                  -> {
                    ->(best_vector) {
                      __pair__[
                        __first__][
                        __nth__[
                          __left__[best_vector]][
                          __right__[
                            seed[
                              ->(memo) {
                                __is_greater_or_equal__[__left__[memo]][__right__[best_vector]][
                                  __pair__[
                                    __subtract__[__left__[memo]][__right__[best_vector]]][
                                    __zero__
                                  ]][
                                  __pair__[
                                    __left__[memo]][
                                    __left__[memo]
                                  ]
                                ]
                              }][
                              __pair__[seed][__zero__]
                            ]
                          ]
                        ]
                      ]
                    }[
                      # "best_vector"
                      __vector_reduce__[
                        states][
                        ->(memo) { ->(state) {
                          __if__[__is_zero__[__right__[memo]]][
                            -> { __vector_append__[memo][state] }][
                            -> {
                              __is_equal__[__get_score__[state]][__get_score__[__vector_first__[memo]]][
                                __vector_append__[memo][state]][
                                __is_greater_or_equal__[
                                  __get_score__[state]][
                                  __get_score__[__vector_first__[memo]]
                                ][
                                  __vector_append__[__empty_vector__][state]][
                                  memo
                                ]
                              ]
                            }
                          ]
                        }}][
                        __empty_vector__
                      ]
                    ]
                  }
                ]
              }[
                __vector_reduce__[
                  __possible_moves__[
                    new_state][
                    __first__][
                    __position_select__[
                      __get_board__[new_state]][
                      ->(piece) { __not__[__is_black__[piece]] }
                    ]
                  ]][
                  ->(memo) { ->(old_state) {
                    # Find the highest scoring response
                    __vector_append__[
                      memo][
                      __vector_reduce__[
                        # Find all possble responses
                        __possible_moves__[
                          old_state][
                          __second__][
                          __vector_append__[__empty_vector__][__get_to__[old_state]]
                        ]][
                        ->(memo) { ->(new_state) {
                          __is_greater_or_equal__[__get_score__[new_state]][__get_score__[memo]][
                            memo][
                            __update_all_but_from_to_promotion__[memo][new_state]
                          ]
                        }}][
                        old_state
                      ]
                    ]
                  }}][
                  __empty_vector__
                ]
              ]
            ]
          ]
        }][
        -> { reject[state] }
      ]
    }
  ]
}









}[
  # "__possible_moves__"
  ->(state) { ->(color) { ->(possible_tos) {
    ->(board) {
      __from_to_reduce__[
        __position_select__[board][color[__is_black__][__is_white__]]][
        possible_tos][
        ->(possible_moves) { ->(from) { ->(to) {
          __advance_state__[
            __create_state__[
              from][
              to][
              __get_last_from__[state]][
              __get_last_to__[state]][
              board][
              __zero__][
              color[__black_queen__][__white_queen__]
            ]
          ][
            ->(new_state) { __vector_append__[possible_moves][new_state] }][
            -> { possible_moves }
          ]
        }}}][
        __empty_vector__
      ]
    }[
      # "board"
      __get_board__[state]
    ]
  }}}
]



}[
  # "__advance_state__"
  ->(state) {
    ->(move_type) {
      ->(if_valid) {->(if_invalid) {
        __if__[__isnt_invalid__[move_type]][
          -> {
            if_valid[
              ->(board) {
                __create_state__[
                  __get_from__[state]][
                  __get_to__[state]][
                  __get_from__[state]][
                  __get_to__[state]][
                  board][
                  ->(last_moved) {
                    __board_reduce__[
                      board][
                      ->(memo) { ->(piece) { ->(position) {
                        __add__[
                          __is_black__[piece][
                            __add__][
                            __subtract__
                          ][
                            memo][
                            __get_value__[piece]
                          ]][
                          __if__[__is_white__[piece]][
                            -> {
                              __if__[__has_value__[piece][__six__]][
                                -> {
                                  __isnt_invalid__[
                                    __get_rule__[__get_position__[board][last_moved]][
                                      __create_state__[
                                        last_moved][
                                        position][
                                        last_moved][
                                        last_moved][
                                        board][
                                        __zero__][
                                        __black_queen__
                                      ]
                                    ]
                                  ][
                                    __multiply__[__eight__][__five__]][
                                    __zero__
                                  ]
                                }][
                                -> { __zero__ }
                              ]
                            }][
                            -> { __zero__ }
                          ]
                        ]
                      }}}][
                      __multiply__[__eight__][__five__]
                    ]
                  }[__get_to__[state]]][
                  __get_promotion__[state]
                ]
              }[
                move_type[
                  __normal_move__][
                  __zero__][
                  ->(board) { ->(from) { ->(to) { ->(new_piece) {
                    ->(captured) {
                      __change_move__[
                        __normal_move__[board][from][to][new_piece]][
                        captured][
                        captured][
                        __empty_space__
                      ]
                    }[
                      # "captured"
                      __pair__[__left__[to]][__right__[from]]
                    ]
                  }}}}][
                  ->(board) { ->(from) { ->(to) { ->(new_piece) {
                    ->(is_moving_left) {
                      __normal_move__[
                        __normal_move__[board][ from][ to][ new_piece]][
                        # Rook positions
                        __pair__[is_moving_left[__zero__][__seven__]][__right__[from]]][
                        __pair__[is_moving_left[__three__][__five__]][__right__[from]]][
                        new_piece
                      ]
                    }[
                      # "is_moving_left"
                      __is_greater_or_equal__[__left__[from]][__left__[to]]
                    ]
                  }}}}][
                  __change_move__
                ][
                  __get_board__[state]][
                  __get_from__[state]][
                  __get_to__[state]][
                  __get_promotion__[state]
                ]
              ]
            ]
          }][
          -> { if_invalid[] }
        ]
      }}
    }[
      # "move_type"
      __get_rule__[__get_position__[__get_board__[state]][__get_from__[state]]][state]
    ]
  }
]



}[
  # "__get_rule__"
  ->(aaa) { aaa[aaa] }[ ->(xxx) {
    ->(piece) {
      __has_value__[piece][__one__][
        __pawn_rule__][
      __has_value__[piece][->(succ) { ->(zero) { succ[succ[succ[succ[zero]]]] } }][
        __rook_rule__][
      __has_value__[piece][__two__][
        __knight_rule__][
      __has_value__[piece][__three__][
        __bishop_rule__][
      __has_value__[piece][__five__][
        __queen_rule__][
      __has_value__[piece][__six__][
        __king_rule__][
        ->(_) { ->(_) { __invalid__ } }
      ]]]]]][->(vvv) { xxx[xxx][vvv] }]
    } } ]
]



}[
  # "__queen_rule__"
  ->(get_rule) {
    ->(state) {
      ->(follows_rule) {
        __or__[
          follows_rule[__rook_rule__[get_rule]]][
          follows_rule[__bishop_rule__[get_rule]]
        ][
          __valid__][
          __invalid__
        ]
      }[
        # "follows_rule"
        ->(rule) { __isnt_invalid__[rule[state]] }
      ]
    }
  }
]



}[
  # "__rook_rule__"
  __straight_line_rule__[
    ->(delta_x) { ->(delta_y) {
      __or__[
        __is_zero__[delta_x]][
        __is_zero__[delta_y]
      ]
    }}
  ]
]



}[
  # "__bishop_rule__"
  __straight_line_rule__[
    ->(delta_x) {
      -> (delta_y) {
      __is_equal__[delta_x][delta_y]
    }}
  ]
]



}[
  # "__king_rule__"
  __basic_checks__[
    ->(state) { ->(get_rule) {
      __if__[
        __and__[
          __is_greater_or_equal__[__one__][__delta__[__get_from__[state]][__get_to__[state]][__left__]]][
          __is_greater_or_equal__[__one__][__delta__[__get_from__[state]][__get_to__[state]][__right__]]
        ]
      ][
        -> { __valid__ }][
        -> {
          __with_basic_info__[
            state][
            ->(board) { ->(from) { ->(to) {
              __if__[
                __and__[
                  __is_equal__[__two__][__delta__[from][to][__left__]]][
                  __is_zero__[__delta__[from][to][__right__]]
                ]
              ][
                -> {
                  ->(is_moving_left) {
                    ->(rook_from) { ->(invalid) { ->(mid_to) {
                      __if__[
                        ->(king) { ->(rook) {
                          __five_conditions_met__[
                            # Moving a king
                            __has_value__[king][__six__]][
                            # King is unmoved
                            __not__[_get_moved_[king]]][
                            # Moving a rook
                            __has_value__[rook][__four__]][
                            # Rook is unmoved
                            __not__[_get_moved_[rook]]][
                            # Path is free
                            __free_path__[board][from][rook_from][__decrement__]
                          ]
                        } }[
                          # "king"
                          __get_position__[board][from]][
                          # "rook"
                          __get_position__[board][rook_from]
                        ]
                      ][
                        -> {
                          __if__[__is_not_in_check__[__normal_move__[board][from][from][__zero__]][from][get_rule]][
                            -> {
                              __if__[__is_not_in_check__[__normal_move__[board][from][mid_to][__zero__]][mid_to][get_rule]][
                                # Don't check __is_not_in_check__[board, from, to] since
                                # __basic_checks__ does that.
                                -> { __first__ }][
                                invalid
                              ]
                            }][
                            invalid
                          ]
                        }][
                        invalid
                      ]
                    } } }[
                      # "rook_from"
                      __pair__[is_moving_left[__zero__][__seven__]][__right__[from]]][
                      # "invalid"
                      -> { __second__ }][
                      # "mid_to"
                      __pair__[
                        is_moving_left[__decrement__][__increment__][__left__[from]]][
                        __right__[from]
                      ]
                    ]
                  }[
                    # "is_moving_left"
                    __is_greater_or_equal__[__left__[from]][__left__[to]]
                  ]
                }][
                -> { __second__ }
              ]
            }}}
          ][
            ->(_) { ->(_) { ->(_) { ->(castle) { ->(_) { castle }}}}}][
            __invalid__
          ]
        }
      ]
    }}
  ]
]



}[
  # "__knight_rule__"
  __basic_checks__[
    ->(state) {->(_) {
      ->(delta_x) { -> (delta_y) {
        __or__[
          __and__[
            __is_equal__[__two__][delta_x]][
            __is_equal__[__one__][delta_y]
          ]][
          __and__[
            __is_equal__[__one__][delta_x]][
            __is_equal__[__two__][delta_y]
          ]
        ][
          __valid__][
          __invalid__
        ]
     } }[
        # "delta_x"
        __delta__[__get_from__[state]][__get_to__[state]][__left__]][
        # "delta_y"
        __delta__[__get_from__[state]][__get_to__[state]][__right__]
      ]
    }}
  ]
]



}[
  # "__pawn_rule__"
  __basic_checks__[
    ->(state) {
    ->(_) {
      __with_basic_info__[
        state][
        ->(board) { ->(from) { ->(to) {
          ->(pawn_is_black) { ->(from_y) { ->(to_y) {
            __if__[
               pawn_is_black[
                __is_zero__[__subtract__[from_y][to_y]]][
                __is_zero__[__subtract__[to_y][from_y]]
              ]
            ][
              # If moving forward
              -> {
                ->(vertical_movement) {
                  __if__[__is_equal__[__one__][vertical_movement]][
                    # If moving vertically one
                    -> {
                      ->(horizontal_movement) { ->(last_to) {
                        __if__[__is_zero__[horizontal_movement]][
                          # If not moving horizontally
                          -> {
                            # Performing a normal move
                            __is_empty__[__get_position__[board][to]][
                              __is_equal__[
                                to_y][
                                pawn_is_black[__seven__][__zero__]
                              ][
                                ->(_) { ->(_) { ->(_) { ->(_) { ->(promotion) { promotion }}}}}][
                                __valid__
                              ]][
                              __invalid__
                            ]
                          }][
                          # If moving horizontally
                          -> {
                            __if__[__is_equal__[__one__][horizontal_movement]][
                              # If moving horizontally one
                              -> {
                                __if__[__is_empty__[__get_position__[board][to]]][
                                  # Not performing a normal capture
                                  -> {
                                    ->(last_moved) {
                                      __five_conditions_met__[
                                        __first__][
                                        # Position behind "to" is "last_to"
                                        __same_position__[
                                          last_to][
                                          __pair__[__left__[to]][from_y]
                                        ]][
                                        # "last_moved" is a pawn
                                        __has_value__[last_moved][__one__]][
                                        # "last_moved" is the opposite color
                                        pawn_is_black[__is_white__][__is_black__][last_moved]][
                                        # "last_moved" moved forward two
                                        __is_equal__[
                                          __delta__[__get_last_from__[state]][last_to][__right__]][
                                          __two__
                                        ]
                                      ][
                                        ->(_) { ->(_) { ->(en_passant) { ->(_) { ->(_) { en_passant }}}}}][
                                        __invalid__
                                      ]
                                    }[
                                      # "last_moved"
                                      __get_position__[board][last_to]
                                    ]
                                  }][
                                  # Performing a normal capture
                                  -> { __valid__ }
                                ]
                              }][
                              # If moving horizontally more than
                              -> { __invalid__ }
                            ]
                          }
                        ]
                      } }[
                        # "horizontal_movement"
                        __delta__[from][to][__left__]][
                        # "last_to"
                        __get_last_to__[state]
                      ]
                    }][
                    # If not moving vertically one
                    -> {
                      __if__[__is_equal__[__two__][vertical_movement]][
                        # If moving vertically two
                        -> {
                          __if__[__is_zero__[__delta__[from][to][__left__]]][
                            # If not moving horizontally
                            -> {
                              __and__[
                                __is_empty__[__get_position__[board][to]]][
                                __and__[
                                  # One space ahead of pawn is free
                                  __is_empty__[
                                    __get_position__[
                                      board][
                                      __pair__[
                                        __left__[to]][
                                        __change_func__[from][ to][ __right__][from_y]
                                      ]
                                    ]
                                  ]][
                                  # Pawn has not moved yet
                                  __not__[_get_moved_[__get_position__[board][from]]]
                                ]
                              ][
                                __valid__][
                                __invalid__
                              ]
                            }][
                            # If moving horizontally
                            -> { __invalid__ }
                          ]
                        }][
                        # If not moving vertically two
                        -> { __invalid__ }
                      ]
                    }
                  ]
                }[
                  # "vertical_movement"
                  __delta__[from][to][__right__]
                ]
              }][
              # If not moving forward
              -> { __invalid__ }
            ]
          }}}[
            # "pawn_is_black"
            __is_black__[__get_position__[board][from]]][
            # "from_y"
            __right__[from]][
            # "to_y"
            __right__[to]
          ]
        }}}
      ]
    }}
  ]
]



}[
  # "__straight_line_rule__"
  ->(rule) {
    __basic_checks__[
      ->(state) {
      ->(_) {
        __with_basic_info__[
          state][
          ->(board) { ->(from) { ->(to) {
            __if__[rule[__delta__[from][to][__left__]][__delta__[from][to][__right__]]][
              -> {
                __free_path__[board][from][to][__decrement__][
                  __valid__][
                  __invalid__
                ]
              }][
              -> { __invalid__ }
            ]
          }}}
        ]
      }}
    ]
  }
]



}[
  # "__basic_checks__"
  ->(rule) {
    ->(get_rule) {
      ->(state) {
        __with_basic_info__[
          state][
          ->(board){->(from){->(to) {
            __if__[
              # Cannot capture own color
              __color_switch__[__get_position__[board][from]][
                __is_black__[__get_position__[board][to]]][
                __is_white__[__get_position__[board][to]]][
                __second__
              ]
            ][
              -> { __invalid__ }][
              -> {
                ->(move_type) {
                  __if__[__isnt_invalid__[move_type]][
                    -> {
                      ->(moved_piece) { ->(after_move) {
                        ->(my_kings_data) {
                          __vector_reduce__[my_kings_data][
                            ->(memo) { ->(king_position) {
                              __if__[memo][
                                -> {
                                  __is_not_in_check__[
                                    after_move][
                                    king_position][
                                    get_rule
                                  ][
                                    __first__][
                                    __second__
                                  ]
                                }][
                                -> { __second__ }
                              ]
                            }}][
                            __first__
                          ]
                        }[
                          # "my_kings_data"
                          __position_select__[
                            after_move][
                            ->(possible) {
                              __and__[
                                __has_value__[possible][__six__]][
                                __is_black__[possible][
                                  __is_black__[moved_piece]][
                                  __is_white__[moved_piece]
                                ]
                              ]
                            }
                          ]
                        ]
                      } }[
                        # "moved_piece"
                        __get_position__[board][from]][
                        # "after_move"
                        __normal_move__[board][from][to][__zero__]
                      ][
                        move_type][
                        __invalid__
                      ]
                    }][
                    -> { move_type }
                  ]
                }[
                  # "move_type"
                  rule[state][get_rule]
                ]
              }
            ]
          }}}
        ]
      }
    }
  }
]



}[
  # "__update_all_but_from_to_promotion__"
  ->(older) { ->(newer) {
    __create_state__[
      __get_from__[older]][
      __get_to__[older]][
      __get_from__[newer]][
      __get_to__[newer]][
      __get_board__[newer]][
      __get_score__[newer]][
      __get_promotion__[older]
    ]
  }}
]



}[
  # "__normal_move__"
  ->(board) { ->(from) { ->(to) { ->(new_piece) {
    __change_move__[board][from][to][__get_position__[board][from]]
  }}}}
]



}[
  # "__change_move__"
  ->(board) { ->(from) { ->(to) { ->(new_piece) {
    __list_map__[
      board][
      __eight__][
      ->(row) {
      ->(yyy) {
        __list_map__[
          row][
          __eight__][
          ->(piece) {
          ->(xxx) {
            __if__[__same_position__[__pair__[xxx][yyy]][to]][
              -> {
                __pair__[
                  __pair__[__get_color__[new_piece]][__get_value__[new_piece]]][
                  __pair__[__get_occupied__[new_piece]][__first__]
                ]
              }][
              -> { __same_position__[__pair__[xxx][yyy]][from][__empty_space__][piece] }
            ]
          }}
        ]
      }}
    ]
  }}}}
]



}[
  # "__is_not_in_check__"
  ->(board) { ->(to) { ->(get_rule) {
    __from_to_reduce__[
      __position_select__[
        board][
        ->(piece) {
          __is_black__[__get_position__[board][to]][
            __is_white__[piece]][
            __is_black__[piece]
          ]
        }
      ]][
      __vector_append__[__empty_vector__][ to]][
      ->(memo) { ->(from) { ->(to) {
        __if__[memo][
          -> {
            __not__[
              __isnt_invalid__[
                get_rule[__get_position__[board][from]][
                  __create_state__[from][to][from][to][board][__zero__][__zero__]
                ]
              ]
            ]
          }][
          -> { __second__ }
        ]
      }}}][
      __first__
    ]
  }}}
]



}[
  # "__isnt_invalid__"
  ->(move_result) { move_result[__first__][__second__][__first__][__first__][__first__] }
]



}[
  # "__valid__"
  ->(valid){->(_) { ->(_) { ->(_) { ->(_) { valid } }}}}
]



}[
  # "__invalid__"
  ->(_) { ->(invalid) { ->(_) { ->(_) { ->(_) { invalid } }}}}
]



}[
  # "__from_to_reduce__"
  ->(possible_froms) { ->(possible_tos) { ->(func) { ->(initial) {
    __vector_reduce__[
      possible_froms][
      ->(memo) { ->(from_position) {
        __vector_reduce__[
          possible_tos][
            ->(inner_memo) { ->(to_position) {
              func[inner_memo][from_position][to_position]
            }}
          ][
          memo
        ]
      }}][
      initial
    ]
  }}}}
]



}[
  # "__position_select__"
  ->(board) { ->(condition) {
    __board_reduce__[
      board][
      ->(memo) { ->(piece) { ->(position) {
        condition[piece][
          __vector_append__[memo][position]][
          memo
        ]
      }}}][
      __empty_vector__
    ]
  }}
]

}[
  # "__free_path__"
  ->(board) { ->(from) { ->(to) { ->(alter_length) {
    ->(delta_x) { -> (delta_y) {
      __if__[
        __or__[
          __or__[
            __is_zero__[delta_x]][
            __is_zero__[delta_y]
          ]][
          __is_equal__[delta_x][delta_y]
        ]
      ][
        -> {
          __right__[
            # Get the number of positions that have to be checked
            alter_length[
              __is_zero__[delta_x][
                __delta__[from][to][__right__]][
                delta_x
              ]
            ][
              # For each position inbetween....
              ->(memo) {
                ->(new_postion) {
                  __pair__[
                    new_postion][
                    # If a filled position hasn't been found, check for a piece
                    __right__[memo][
                      __is_empty__[__get_position__[board][new_postion]]][
                      __second__
                    ]
                  ]
                }[
                  # Calculate next postion to check
                  __pair__[
                    __change_func__[from][to][__left__][__left__[__left__[memo]]]][
                    __change_func__[from][to][__right__][__right__[__left__[memo]]]
                  ]
                ]
              }][
              __pair__[from][__first__]
            ]
          ]
        }][
        -> { __second__ }
      ]
    } }[
      # "delta_x"
      __delta__[from][to][__left__]][
      # "delta_y"
      __delta__[from][to][__right__]
    ]
  }}}}
]



}[
  # "__change_func__"
  ->(from) { ->(to) { ->(coordinate) {
    ->(aaa) { ->(bbb) {
      __is_greater_or_equal__[aaa][bbb][
        __is_equal__[aaa][bbb][
          ->(xxxx) { xxxx }][
          __decrement__
        ]][
        __increment__
      ]
    } }[
      coordinate[from]][
      coordinate[to]
    ]
  }}}
]



}[
  # "__get_position__"
  ->(board) { ->(position) {
    __nth__[__nth__[board][__right__[position]]][__left__[position]]
  }}
]

}[
  # "__same_position__"
  ->(aaa) {
    ->(bbb) {
      __and__[
        __is_equal__[__left__[aaa]][__left__[bbb]]][
        __is_equal__[__right__[aaa]][__right__[bbb]]
      ]
    }}
]

}[
  # "__board_reduce__"
  ->(board) { ->(func) { ->(initial) {
    __list_reduce__[
      board][
      __eight__][
      ->(memo) { ->(row) { ->(yyy) {
        __list_reduce__[
          row][
          __eight__][
          ->(memo) { ->(piece) { ->(xxx) {
            func[memo][piece][__pair__[xxx][yyy]]
          }}}][
          memo
        ]
      }}}][
      initial
    ]
  }}}
]

}[
  # "__with_basic_info__"
  ->(state) { ->(func) { func[__get_board__[state]][__get_from__[state]][__get_to__[state]] } }
]

}[
  # "__create_state__"
  ->(from) { ->(to) { ->(last_from) { ->(last_to) { ->(board) { ->(score) { ->(promotion) {
    __pair__[
      __pair__[
        __pair__[from][to]][
        __pair__[board][score]
      ]][
      __pair__[
        promotion][
        __pair__[last_from][last_to]
      ]
    ]
  }}}}}}}
]

}[
  # "__get_score__"
  ->(state) { _get_moved_[__left__[state]] }
]


}[
  # "__get_promotion__"
  ->(state) { __left__[__right__[state]] }
]

}[
  # "__get_last_from__"
  ->(state) { __left__[_get_moved_[state]] }
]

}[
  # "__get_board__"
  ->(state) { __get_occupied__[__left__[state]] }
]

}[
  # "__get_to__"
  ->(state) { __right__[__get_color__[state]] }
]

}[
  # "__get_from__"
  ->(state) { __left__[__get_color__[state]] }
]

}[
  # "__get_last_to__"
  ->(state) { __right__[_get_moved_[state]] }
]

}[
  # "__empty_space__"
  __pair__[__pair__[__first__][__zero__]][__pair__[__second__][__second__]]
]

}[
  # "__delta__"
  ->(position_1) { ->(position_2) { ->(coordinate) {
    ->(aaa) {
    ->(bbb) {
      __is_greater_or_equal__[aaa][bbb][
        __subtract__[aaa][bbb]][
        __subtract__[bbb][aaa]
      ]
    }}[
      coordinate[position_1]][
      coordinate[position_2]
    ]
  }}}
]

}[
  # "__vector_reduce__"
  ->(vector) { ->(func) { ->(initial) {
    __list_reduce__[
      __left__[vector]][
      __right__[vector]][
      ->(memo) { ->(item) { ->(index) { func[memo][item] }}}][
      initial
    ]
  }}}
]

}[
  # "__vector_first__"
  ->(vector) { __nth__[__left__[vector]][__zero__] }
]

}[
  # "__vector_append__"
  ->(vector) { ->(item) {
    __pair__[
      __pair__[item][__left__[vector]]][
      __increment__[__right__[vector]]
    ]
  }}
]

}[
  # "__empty_vector__"
  __pair__[__zero__][__zero__]
]

}[
  # "__list_reduce__"
  ->(list) { ->(size) { ->(func) { ->(initial) {
    __left__[
      size[
        ->(memo) {
          __pair__[
            func[
              # previous
              __left__[memo]][
              # next
              __nth__[list][__right__[memo]]][
              # index
              __right__[memo]
            ]][
            __increment__[__right__[memo]]
          ]
        }][
        __pair__[initial][__zero__]
      ]
    ]
  }}}}
]

}[
  # "__list_map__"
  ->(list) { ->(size) { ->(func) {
    __left__[
      size[
        ->(memo) {
          __pair__[
           __pair__[
             func[
               __nth__[list][__right__[memo]]][
               __right__[memo]
             ]][
             __left__[memo]
            ]][
            __decrement__[__right__[memo]]
          ]
        }][
        __pair__[__zero__][__decrement__[size]]
      ]
    ]
  }}}
]




}[
  # "__is_empty__"
  ->(piece) {
    __not__[__get_occupied__[piece]]
  }
]

}[
  # "__is_black__"
  ->(piece) {
    __color_switch__[piece][__first__][__second__][__second__]
  }
]

}[
  # "__is_white__"
  ->(piece) {
    __color_switch__[piece][__second__][__first__][__second__]
  }
]

}[
  # "__color_switch__"
  ->(piece) {
    ->(black) { ->(white) { ->(empty) {
      __get_occupied__[piece][
        __get_color__[piece][
          black][
          white
        ]][
        empty
      ]
    }}}
  }
]

}[
  # "__has_value__"
  ->(piece) {
  ->(value) {
    __is_equal__[value][ __get_value__[piece]]
  }}
]




}[
  # "__nth__"
  ->(list) { ->(index) { __left__[index[__right__][list]] } }
]

}[
  # "__get_color__"
  ->(piece) { __left__[__left__[piece]] }
]


}[
  # "__get_value__"
  ->(piece) { __right__[__left__[piece]] }
]


}[
  # "__get_occupied__"
  ->(piece) { __left__[__right__[piece]] }
]


}[
  # "_get_moved_"
  ->(piece) { __right__[__right__[piece]] }
]

}[
  # "__six__"
  __multiply__[__two__][__three__]
]

}[
  # "__seven__"
  __add__[__three__][__four__]
]

}[
  # "__eight__"
  __multiply__[__two__][__four__]
]

}[
  # "__multiply__"
  ->(aaa) {->(bbb) {
    ->(func) { ->(zero) {
      aaa[
        ->(value) { bbb[func][value] }][
        zero
      ]
    }}
  }}
]


}[
  # "__is_equal__"
  ->(aaa) {
  ->(bbb) {
    __if__[__is_greater_or_equal__[aaa][bbb]][
      -> { __is_greater_or_equal__[bbb][aaa] }][
      -> { __second__ }
    ]
  }
  }
]


}[
  # "__is_greater_or_equal__"
  ->(aaa) {
  ->(bbb) {
    __is_zero__[__subtract__[bbb][aaa]]
  }
  }
]


}[
  # "__is_zero__"
  ->(number) {
    number[->(_) { __second__ }][__first__]
  }
]


}[
  # "__subtract__"
  ->(aaa) { ->(bbb) {
    ->(func) { ->(zero) {
      bbb[__decrement__][aaa][func][zero]
    }}
  }}
]

}[
  # "__decrement__"
  ->(aaa) {
    __right__[
      aaa[
        ->(memo) {
          __pair__[
            __increment__[__left__[memo]]][
            __left__[memo]
          ]
        }][
        __pair__[__zero__][__zero__]
      ]
    ]
  }
]

}[
  # "__increment__"
  ->(aaa) { __add__[__one__][aaa] }
]

}[
  # "__black_queen__"
  __pair__[__pair__[__first__][__five__]][__pair__[__first__][__first__]]
]

}[
  # "__white_queen__"
  __pair__[__pair__[__second__][__five__]][__pair__[__first__][__first__]]
]

}[
  # "__five__"
  __add__[__two__][__three__]
]

}[
  # "__add__"
  ->(aaa) { ->(bbb) {
    ->(func) { ->(zero) {
      bbb[func][aaa[func][zero]]
    }
  } } }
]

}[
  # "__pair__"
  ->(left) {
    ->(right) {
      ->(select) { select[left][right] }
    }}
]

}[
  # "__left__"
  ->(pair) { pair[__first__]  }
]

}[
  # "__right__"
  ->(pair) { pair[__second__] }
]

}[
  # "__zero__"
  ->(succ) { ->(zero) { zero } }
]

}[
  # "__one__"
  ->(succ) { ->(zero) { succ[zero] } }
]

}[
  # "__two__"
  ->(succ) { ->(zero) { succ[succ[zero]] } }
]

}[
  # "__three__"
  ->(succ) { ->(zero) { succ[succ[succ[zero]]] } }
]

}[
  # "__four__"
  ->(succ) { ->(zero) { succ[succ[succ[succ[zero]]]] } }
]

}[
  # "__first__"
  ->(first) {
  ->(second) { first } }
]

}[
  # "__second__"
  ->(first) {
  ->(second) { second } }
]

}[
  # "__and__"
  ->(aaa) {
  ->(bbb) {
    ->(first) {
    ->(second) {
      aaa[bbb[first][second]][second]
    }
  }
  }
  }
]

}[
  # "__or__"
  ->(aaa) {
  ->(bbb) {
    ->(first) {
    ->(second) {
      aaa[first][bbb[first][second]]
    }
  }
  }
  }
]

}[
  # "__not__"
  ->(choice) {
    ->(first){
        ->(second) {
          choice[second][first]
        }
      }}
]

}[
  # "__five_conditions_met__"
  ->(cond_1) {
  ->(cond_2) {
  ->(cond_3) {
  ->(cond_4) {
  ->(cond_5) {
    ->(first) {
    ->(second) {
      cond_1[cond_2[cond_3[cond_4[cond_5[
        first][
        second]][
        second]][
        second]][
        second]][
        second]
    }
  }}}}}}
]

}[
  # "__if__"
  ->(condition) {
    ->(first) {
    ->(second) {
      condition[first][second][]
    }
  }}
]
