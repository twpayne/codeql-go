/**
 * Provides classes for working with Go types.
 */

import go

/** A Go type. */
class Type extends @type {
  /** Gets the name of this type, if it has one. */
  string getName() { typename(this, result) }

  /**
   * Gets the underlying type of this type after any type aliases have been replaced
   * with their definition.
   */
  Type getUnderlyingType() { result = this }

  /**
   * Gets the entity associated with this type.
   */
  TypeEntity getEntity() { type_objects(this, result) }

  /** Gets the package in which this type is declared, if any. */
  Package getPackage() { result = this.getEntity().getPackage() }

  /**
   * Gets the qualified name of this type, if any.
   */
  string getQualifiedName() { result = getEntity().getQualifiedName() }

  /**
   * Holds if this type is declared in a package with path `pkg` and has name `name`.
   */
  predicate hasQualifiedName(string pkg, string name) { getEntity().hasQualifiedName(pkg, name) }

  /**
   * Holds if the method set of this type contains a method named `m` of type `t`.
   */
  predicate hasMethod(string m, SignatureType t) { t = getMethod(m).getType() }

  /**
   * Gets the method `m` belonging to the method set of this type, if any.
   */
  Method getMethod(string m) {
    result.getReceiverType() = this and
    result.getName() = m
  }

  /**
   * Gets the field `f` of this type.
   *
   * This includes fields promoted from an embedded field.
   */
  Field getField(string f) { result = getUnderlyingType().getField(f) }

  /**
   * Holds if this type implements interface `i`, that is, the method set of `i`
   * is contained in the method set of this type.
   */
  predicate implements(InterfaceType i) {
    isEmptyInterface(i)
    or
    this.hasMethod(getExampleMethodName(i), _) and
    forall(string m, SignatureType t | i.hasMethod(m, t) | this.hasMethod(m, t))
  }

  /**
   * Holds if this type implements an interface that has the qualified name `pkg.name`,
   * that is, the method set of `pkg.name` is contained in the method set of this type.
   */
  predicate implements(string pkg, string name) {
    exists(Type t | t.hasQualifiedName(pkg, name) | this.implements(t.getUnderlyingType()))
  }

  /**
   * Gets the pointer type that has this type as its base type.
   */
  PointerType getPointerType() { result.getBaseType() = this }

  /**
   * Gets a pretty-printed representation of this type, including its structure where applicable.
   */
  string pp() { result = toString() }

  /**
   * Gets a basic textual representation of this type.
   */
  string toString() { result = getName() }
}

/** An invalid type. */
class InvalidType extends @invalidtype, Type {
  override string toString() { result = "invalid type" }
}

/** A basic type. */
class BasicType extends @basictype, Type { }

/** Either the normal or literal boolean type */
class BoolType extends @booltype, BasicType { }

/** The `bool` type of a non-literal expression */
class BoolExprType extends @boolexprtype, BoolType {
  override string getName() { result = "bool" }
}

/** A numeric type such as `int` or `float64`. */
class NumericType extends @numerictype, BasicType {
  /**
   * Gets the implementation-independent size (in bits) of this numeric type.
   *
   * This predicate is not defined for types with an implementation-specific size, that is,
   * `uint`, `int` or `uintptr`.
   */
  int getSize() { none() }

  /**
   * Gets a possible implementation-specific size (in bits) of this numeric type.
   *
   * This predicate is not defined for `uintptr` since the language specification says nothing
   * about its size.
   */
  int getASize() { result = getSize() }
}

/** An integer type such as `int` or `uint64`. */
class IntegerType extends @integertype, NumericType { }

/** A signed integer type such as `int`. */
class SignedIntegerType extends @signedintegertype, IntegerType { }

/** The type `int`. */
class IntType extends @inttype, SignedIntegerType {
  override int getASize() { result = 32 or result = 64 }

  override string getName() { result = "int" }
}

/** The type `int8`. */
class Int8Type extends @int8type, SignedIntegerType {
  override int getSize() { result = 8 }

  override string getName() { result = "int8" }
}

/** The type `int16`. */
class Int16Type extends @int16type, SignedIntegerType {
  override int getSize() { result = 16 }

  override string getName() { result = "int16" }
}

/** The type `int32`. */
class Int32Type extends @int32type, SignedIntegerType {
  override int getSize() { result = 32 }

  override string getName() { result = "int32" }
}

/** The type `int64`. */
class Int64Type extends @int64type, SignedIntegerType {
  override int getSize() { result = 64 }

  override string getName() { result = "int64" }
}

/** An unsigned integer type such as `uint`. */
class UnsignedIntegerType extends @unsignedintegertype, IntegerType { }

/** The type `uint`. */
class UintType extends @uinttype, UnsignedIntegerType {
  override int getASize() { result = 32 or result = 64 }

  override string getName() { result = "uint" }
}

/** The type `uint8`. */
class Uint8Type extends @uint8type, UnsignedIntegerType {
  override int getSize() { result = 8 }

  override string getName() { result = "uint8" }
}

/** The type `uint16`. */
class Uint16Type extends @uint16type, UnsignedIntegerType {
  override int getSize() { result = 16 }

  override string getName() { result = "uint16" }
}

/** The type `uint32`. */
class Uint32Type extends @uint32type, UnsignedIntegerType {
  override int getSize() { result = 32 }

  override string getName() { result = "uint32" }
}

/** The type `uint64`. */
class Uint64Type extends @uint64type, UnsignedIntegerType {
  override int getSize() { result = 64 }

  override string getName() { result = "uint64" }
}

/** The type `uintptr`. */
class UintptrType extends @uintptrtype, BasicType {
  override string getName() { result = "uintptr" }
}

/** A floating-point type such as `float64`. */
class FloatType extends @floattype, NumericType { }

/** The type `float32`. */
class Float32Type extends @float32type, FloatType {
  override int getSize() { result = 32 }

  override string getName() { result = "float32" }
}

/** The type `float64`. */
class Float64Type extends @float64type, FloatType {
  override int getSize() { result = 64 }

  override string getName() { result = "float64" }
}

/** A complex-number type such as `complex64`. */
class ComplexType extends @complextype, NumericType { }

/** The type `complex64`. */
class Complex64Type extends @complex64type, ComplexType {
  override int getSize() { result = 64 }

  override string getName() { result = "complex64" }
}

/** The type `complex128`. */
class Complex128Type extends @complex128type, ComplexType {
  override int getSize() { result = 128 }

  override string getName() { result = "complex128" }
}

/** Either the normal or literal string type */
class StringType extends @stringtype, BasicType { }

/** The `string` type of a non-literal expression */
class StringExprType extends @stringexprtype, StringType {
  override string getName() { result = "string" }
}

/** The type `unsafe.Pointer`. */
class UnsafePointerType extends @unsafepointertype, BasicType {
  override string getName() { result = "unsafe.Pointer" }
}

/** The type of a literal. */
class LiteralType extends @literaltype, BasicType { }

/** The type of a bool literal. */
class BoolLiteralType extends @boolliteraltype, LiteralType, BoolType {
  override string toString() { result = "bool literal" }
}

/** The type of an integer literal. */
class IntLiteralType extends @intliteraltype, LiteralType, SignedIntegerType {
  override string toString() { result = "int literal" }
}

/** The type of a rune literal. */
class RuneLiteralType extends @runeliteraltype, LiteralType, SignedIntegerType {
  override string toString() { result = "rune literal" }
}

/** The type of a float literal. */
class FloatLiteralType extends @floatliteraltype, LiteralType, FloatType {
  override string toString() { result = "float literal" }
}

/** The type of a complex literal. */
class ComplexLiteralType extends @complexliteraltype, LiteralType, ComplexType {
  override string toString() { result = "complex literal" }
}

/** The type of a string literal. */
class StringLiteralType extends @stringliteraltype, LiteralType, StringType {
  override string toString() { result = "string literal" }
}

/** The type of `nil`. */
class NilLiteralType extends @nilliteraltype, LiteralType {
  override string toString() { result = "nil literal" }
}

/** A composite type, that is, not a basic type. */
class CompositeType extends @compositetype, Type { }

/** An array type. */
class ArrayType extends @arraytype, CompositeType {
  /** Gets the element type of this array type. */
  Type getElementType() { element_type(this, result) }

  /** Gets the length of this array type as a string. */
  string getLengthString() { array_length(this, result) }

  /** Gets the length of this array type if it can be represented as a QL integer. */
  int getLength() { result = getLengthString().toInt() }

  override Package getPackage() { result = this.getElementType().getPackage() }

  override string pp() { result = "[" + getLength() + "]" + getElementType().pp() }

  override string toString() { result = "array type" }
}

/** A slice type. */
class SliceType extends @slicetype, CompositeType {
  /** Gets the element type of this slice type. */
  Type getElementType() { element_type(this, result) }

  override Package getPackage() { result = this.getElementType().getPackage() }

  override string pp() { result = "[]" + getElementType().pp() }

  override string toString() { result = "slice type" }
}

/** A struct type. */
class StructType extends @structtype, CompositeType {
  /**
   * Holds if this struct contains a field `name` with type `tp`;
   * `isEmbedded` is true if the field is embedded.
   *
   * Note that this predicate does not take promoted fields into account.
   */
  predicate hasOwnField(int i, string name, Type tp, boolean isEmbedded) {
    exists(string n | component_types(this, i, n, tp) |
      if n = ""
      then (
        isEmbedded = true and
        (
          name = tp.(NamedType).getName()
          or
          name = tp.(PointerType).getBaseType().(NamedType).getName()
        )
      ) else (
        isEmbedded = false and
        name = n
      )
    )
  }

  /**
   * Get a field with the name `name`; `isEmbedded` is true if the field is embedded.
   *
   * Note that this does not take promoted fields into account.
   */
  Field getOwnField(string name, boolean isEmbedded) {
    result.getDeclaringType() = this and
    result.getName() = name and
    this.hasOwnField(_, name, _, isEmbedded)
  }

  private predicate hasEmbeddedField(Type tp, int depth) {
    hasFieldOrMethodCand(_, tp, depth, true, false)
    or
    exists(PointerType embeddedPtr |
      hasFieldOrMethodCand(_, embeddedPtr, depth, true, false) and
      tp = embeddedPtr.getBaseType()
    )
  }

  private predicate hasFieldOrMethodCand(
    string name, Type tp, int depth, boolean isEmbedded, boolean isMethod
  ) {
    hasOwnField(_, name, tp, isEmbedded) and depth = 0 and isMethod = false
    or
    exists(Type embedded | hasEmbeddedField(embedded, depth - 1) |
      embedded.getUnderlyingType().(StructType).hasOwnField(_, name, tp, isEmbedded) and
      isMethod = false
      or
      exists(MethodDecl md | md.getReceiverType() = embedded |
        name = md.getName() and
        tp = md.getType()
      ) and
      isEmbedded = false and
      isMethod = true
    )
  }

  private predicate hasFieldOrMethod(string name, Type tp, boolean isMethod) {
    exists(int mindepth |
      mindepth = min(int depth | hasFieldOrMethodCand(name, _, depth, _, _)) and
      hasFieldOrMethodCand(name, tp, mindepth, _, isMethod) and
      (strictcount(getFieldCand(name, mindepth, _)) = 1 or isMethod = true)
    )
  }

  /**
   * Holds if this struct contains a field `name` with type `tp`, possibly inside a (nested)
   * embedded field.
   */
  predicate hasField(string name, Type tp) { hasFieldOrMethod(name, tp, false) }

  private Field getFieldCand(string name, int depth, boolean isEmbedded) {
    result = this.getOwnField(name, isEmbedded) and depth = 0
    or
    exists(Type embedded | hasEmbeddedField(embedded, depth - 1) |
      result = embedded.getUnderlyingType().(StructType).getOwnField(name, isEmbedded)
    )
  }

  override Field getField(string name) {
    exists(int mindepth |
      mindepth = min(int depth | exists(getFieldCand(name, depth, _))) and
      result = getFieldCand(name, mindepth, _) and
      strictcount(getFieldCand(name, mindepth, _)) = 1
    )
  }

  override predicate hasMethod(string name, SignatureType tp) { hasFieldOrMethod(name, tp, true) }

  language[monotonicAggregates]
  override string pp() {
    result = "struct { " +
        concat(int i, string name, Type tp |
          component_types(this, i, name, tp)
        |
          name + " " + tp.pp(), "; " order by i
        ) + " }"
  }

  override string toString() { result = "struct type" }
}

/** A pointer type. */
class PointerType extends @pointertype, CompositeType {
  /** Gets the base type of this pointer type. */
  Type getBaseType() { base_type(this, result) }

  override Package getPackage() { result = this.getBaseType().getPackage() }

  override Method getMethod(string m) {
    // https://golang.org/ref/spec#Method_sets: "the method set of a pointer type *T is
    // the set of all methods declared with receiver *T or T"
    result = CompositeType.super.getMethod(m)
    or
    result = getBaseType().getMethod(m)
  }

  override string pp() { result = "* " + getBaseType().pp() }

  override string toString() { result = "pointer type" }
}

/** An interface type. */
class InterfaceType extends @interfacetype, CompositeType {
  /** Gets the type of method `name` of this interface type. */
  Type getMethodType(string name) { component_types(this, _, name, result) }

  override predicate hasMethod(string m, SignatureType t) { t = getMethodType(m) }

  language[monotonicAggregates]
  override string pp() {
    result = "interface { " +
        concat(string name, Type tp |
          tp = getMethodType(name)
        |
          name + " " + tp.pp(), "; " order by name
        ) + " }"
  }

  override string toString() { result = "interface type" }
}

/** A tuple type. */
class TupleType extends @tupletype, CompositeType {
  /** Gets the `i`th component type of this tuple type. */
  Type getComponentType(int i) { component_types(this, i, _, result) }

  language[monotonicAggregates]
  override string pp() {
    result = "(" + concat(int i, Type tp | tp = getComponentType(i) | tp.pp(), ", " order by i) +
        ")"
  }

  override string toString() { result = "tuple type" }
}

/** A signature type. */
class SignatureType extends @signaturetype, CompositeType {
  /** Gets the `i`th parameter type of this signature type. */
  Type getParameterType(int i) { i >= 0 and component_types(this, i + 1, _, result) }

  /** Gets the `i`th result type of this signature type. */
  Type getResultType(int i) { i >= 0 and component_types(this, -(i + 1), _, result) }

  /** Gets the number of parameters specified by this signature. */
  int getNumParameter() { result = count(int i | exists(getParameterType(i))) }

  /** Gets the number of results specified by this signature. */
  int getNumResult() { result = count(int i | exists(getResultType(i))) }

  language[monotonicAggregates]
  override string pp() {
    result = "func(" + concat(int i, Type tp | tp = getParameterType(i) | tp.pp(), ", " order by i) +
        ") " + concat(int i, Type tp | tp = getResultType(i) | tp.pp(), ", " order by i)
  }

  override string toString() { result = "signature type" }
}

/** A map type. */
class MapType extends @maptype, CompositeType {
  /** Gets the key type of this map type. */
  Type getKeyType() { key_type(this, result) }

  /** Gets the value type of this map type. */
  Type getValueType() { element_type(this, result) }

  override string pp() { result = "[" + getKeyType().pp() + "]" + getValueType().pp() }

  override string toString() { result = "map type" }
}

/** A channel type. */
class ChanType extends @chantype, CompositeType {
  /** Gets the element type of this channel type. */
  Type getElementType() { element_type(this, result) }

  /** Holds if this channel can send data. */
  predicate canSend() { none() }

  /** Holds if this channel can receive data. */
  predicate canReceive() { none() }
}

/** A channel type that can only send. */
class SendChanType extends @sendchantype, ChanType {
  override predicate canSend() { any() }

  override string pp() { result = "chan<- " + getElementType().pp() }

  override string toString() { result = "send-channel type" }
}

/** A channel type that can only receive. */
class RecvChanType extends @recvchantype, ChanType {
  override predicate canReceive() { any() }

  override string pp() { result = "<-chan " + getElementType().pp() }

  override string toString() { result = "receive-channel type" }
}

/** A channel type that can both send and receive. */
class SendRecvChanType extends @sendrcvchantype, ChanType {
  override predicate canSend() { any() }

  override predicate canReceive() { any() }

  override string pp() { result = "chan " + getElementType().pp() }

  override string toString() { result = "send-receive-channel type" }
}

/** A named type. */
class NamedType extends @namedtype, CompositeType {
  /** Gets a method with name `m` defined on this type. */
  MethodDecl getMethodDecl(string m) {
    result.getName() = m and
    this = result.getReceiverBaseType()
  }

  /** Gets the type which this type is defined to be. */
  Type getBaseType() { underlying_type(this, result) }

  override Type getUnderlyingType() { result = getBaseType().getUnderlyingType() }
}

/**
 * Holds if `i` is the empty interface type, which is implemented by every type with a method set.
 */
pragma[noinline]
private predicate isEmptyInterface(InterfaceType i) { not i.hasMethod(_, _) }

/**
 * Gets the name of a method in the method set of `i`.
 *
 * This is used to restrict the set of interfaces to consider in the definition of `implements`,
 * so it does not matter which method name is chosen (we use the lexicographically least).
 */
private string getExampleMethodName(InterfaceType i) { result = min(string m | i.hasMethod(m, _)) }