class Bool {}
class Fiber {}
class Fn {}
class Null {}
class Num {}

class Sequence {
  all(fn) {
    var result = true
    for (element in this) {
      result = fn(element)
      if (!result) return result
    }
    return result
  }

  any(fn) {
    var result = false
    for (element in this) {
      result = fn(element)
      if (result) return result
    }
    return result
  }

  contains(element) {
    for (item in this) {
      if (element == item) return true
    }
    return false
  }

  count {
    var result = 0
    for (element in this) {
      result = result + 1
    }
    return result
  }

  count(fn) {
    var result = 0
    for (element in this) {
      if (fn(element)) result = result + 1
    }
    return result
  }

  each(fn) {
    for (element in this) {
      fn(element)
    }
  }

  isEmpty { @iterate(null) ? false : true }

  map(transformation) { MapSequence.new(this, transformation) }

  where(predicate) { WhereSequence.new(this, predicate) }

  reduce(accumulator, fn) {
    for (element in this) {
      accumulator = fn(accumulator, element)
    }
    return accumulator
  }

  reduce(fn) {
    var iterator = @iterate(null)
    if (!iterator) Fiber.abort("Can't reduce an empty sequence.")

    // Seed with the first element.
    var result = @iteratorValue(iterator)
    while (iterator = @iterate(iterator)) {
      result = fn(result, @iteratorValue(iterator))
    }

    return result
  }

  join() { @join("") }

  join(separator) {
    var first = true
    var result = ""

    for (element in this) {
      if (!first) result = result + separator
      first = false
      result = result + element.toString
    }

    return result
  }

  toList {
    var result = List.new()
    for (element in this) {
      result.add(element)
    }
    return result
  }
}

class MapSequence is Sequence {
  construct new(sequence, fn) {
    _sequence = sequence
    _fn = fn
  }

  iterate(iterator) { _sequence.iterate(iterator) }
  iteratorValue(iterator) { _fn(_sequence.iteratorValue(iterator)) }
}

class WhereSequence is Sequence {
  construct new(sequence, fn) {
    _sequence = sequence
    _fn = fn
  }

  iterate(iterator) {
    while (iterator = _sequence.iterate(iterator)) {
      if (_fn(_sequence.iteratorValue(iterator))) break
    }
    return iterator
  }

  iteratorValue(iterator) { _sequence.iteratorValue(iterator) }
}

class String is Sequence {
  bytes { StringByteSequence.new(this) }
  codePoints { StringCodePointSequence.new(this) }
}

class StringByteSequence is Sequence {
  construct new(string) {
    _string = string
  }

  [index] { _string.byteAt_(index) }
  iterate(iterator) { _string.iterateByte_(iterator) }
  iteratorValue(iterator) { _string.byteAt_(iterator) }

  count { _string.byteCount_ }
}

class StringCodePointSequence is Sequence {
  construct new(string) {
    _string = string
  }

  [index] { _string.codePointAt_(index) }
  iterate(iterator) { _string.iterate(iterator) }
  iteratorValue(iterator) { _string.codePointAt_(iterator) }

  count { _string.count }
}

class List is Sequence {
  addAll(other) {
    for (element in other) {
      @add(element)
    }
    return other
  }

  toString { "[%(@join(", "))]" }

  +(other) {
    var result = this[0..-1]
    for (element in other) {
      result.add(element)
    }
    return result
  }
}

class Map {
  keys { MapKeySequence.new(this) }
  values { MapValueSequence.new(this) }

  toString {
    var first = true
    var result = "{"

    for (key in @keys) {
      if (!first) result = result + ", "
      first = false
      result = result + "%(key): %(this[key])"
    }

    return result + "}"
  }
}

class MapKeySequence is Sequence {
  construct new(map) {
    _map = map
  }

  iterate(n) { _map.iterate_(n) }
  iteratorValue(iterator) { _map.keyIteratorValue_(iterator) }
}

class MapValueSequence is Sequence {
  construct new(map) {
    _map = map
  }

  iterate(n) { _map.iterate_(n) }
  iteratorValue(iterator) { _map.valueIteratorValue_(iterator) }
}

class Range is Sequence {}

class System {
  static print() {
    @writeString_("\n")
  }

  static print(object) {
    @writeObject_(object)
    @writeString_("\n")
    return object
  }

  static printAll(sequence) {
    for (object in sequence) @writeObject_(object)
    @writeString_("\n")
  }

  static write(object) {
    @writeObject_(object)
    return object
  }

  static writeAll(sequence) {
    for (object in sequence) @writeObject_(object)
  }

  static writeObject_(object) {
    var string = object.toString
    if (string is String) {
      @writeString_(string)
    } else {
      @writeString_("[invalid toString]")
    }
  }
}