# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

class Proc
  def to_i
    self.call(proc { |x| x + 1 }, 0)
  end

  def to_a length
    result = []
    part   = self

    length.times do
      result.push(LEFT[part])
      part = RIGHT[part]
    end

    result
  end
end

class Fixnum
  def to_peano
    proc do |func, result|
      self.times { result = func.call(result) }
      result
    end
  end
end

class Array
  def to_linked_list
    self.reverse.inject(ZERO) do |previous, element|
      PAIR[element, previous]
    end
  end
end

def index_array
  [0,  1,  2,  3,  4,  5,  6,  7,
   8,  9,  10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23,
   24, 25, 26, 27, 28, 29, 30, 31,
   32, 33, 34, 35, 36, 37, 38, 39,
   40, 41, 42, 43, 44, 45, 46, 47,
   48, 49, 50, 51, 52, 53, 54, 55,
   56, 57, 58, 59, 60, 61, 62, 63]
end
