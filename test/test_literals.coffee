a = [((x) -> x), ((x) -> x * x)]
eq a.length, 2


eq (3 -4), -1


# Decimal number literals.
eq 1.0, .25 + .75
eq 0.5, 0.0 + -.25 - -.75 + 0.0


ok 4.valueOf(), 'can access a simple number with dot'


eq void, do -> return if true


# Trailing commas.
eq [1, 2,] + '', '1,2'

sum  = 0
sum += n for n of [
  1, 2, 3,
  4, 5, 6
  7, 8, 9,
]
eq sum, 45

o = {k1: "v1", k2: 4, k3: (-> true),}
ok o.k3() and o.k2 is 4 and o.k1 is "v1"


ok {a: (num) -> num is 10 }.a 10


moe = {
  name:  'Moe'
  greet: (salutation) ->
    salutation + " " + @name
  hello: ->
    @['greet'] "Hello"
  10: 'number'
}

ok moe.hello() is "Hello Moe"
ok moe[10] is 'number'

moe.hello = ->
  this['greet'] "Hello"

ok moe.hello() is 'Hello Moe'


obj = {
  is:     -> true,
  'not':  -> false,
}

ok obj.is()
ok not obj.not()


### Top-level braceless object ###
obj: 1
### doesn't break things. ###


# Funky indentation within non-comma-seperated arrays.
result = [['a']
 {b: 'c'}]

ok result[0][0] is 'a'
ok result[1]['b'] is 'c'


# Object literals should be able to include keywords.
obj = class: 'hot'
obj.function = 'dog'
eq obj.class + obj.function, 'hotdog'


# But keyword assignment should be smart enough not to stringify variables.
func = ->
  this == 'this'

ok func() is false


# New fancy implicit objects:
config =
  development:
    server: 'localhost'
    timeout: 10

  production:
    server: 'dreamboat'
    timeout: 1000

ok config.development.server  is 'localhost'
ok config.production.server   is 'dreamboat'
ok config.development.timeout is 10
ok config.production.timeout  is 1000

obj =
  a: 1
  b: 2

ok obj.a is 1
ok obj.b is 2

obj =
  a: 1,
  b: 2,

ok obj.a is 1
ok obj.b is 2


# Implicit objects nesting.
obj =
  options:
    value: true

  fn: ->
    {}
    null

ok obj.options.value is true
ok obj.fn() is null


third = (a, b, c) -> c
obj =
  one: 'one'
  two: third 'one', 'two', 'three'

ok obj.one is 'one'
ok obj.two is 'three'


# Implicit objects with wacky indentation:
obj =
  'reverse': (obj) ->
    Array.prototype.reverse.call obj
  abc: ->
    @reverse(
      @reverse @reverse ['a', 'b', 'c'].reverse()
    )
  one: [1, 2,
    a: 'b'
  3, 4]
  red:
    orange:
          yellow:
                  green: 'blue'
    indigo: 'violet'
  misdent: [[],
  [],
                  [],
      []]

ok obj.abc().join(' ') is 'a b c'
ok obj.one.length is 5
ok obj.one[4] is 4
ok obj.one[2].a is 'b'
ok (key for key in obj.red).length is 2
ok obj.red.orange.yellow.green is 'blue'
ok obj.red.indigo is 'violet'
ok obj.misdent.toString() is ',,,'


# Implicit objects as part of chained calls.
pluck = (x) -> x.a
eq 100, pluck pluck pluck a: a: a: 100


eq '\\`', `
  // Inline JS
  "\\\`"
`

i = 3
`LABEL:`
while --i then while --i then `break LABEL`
eq i, 1


# Braceless objects.
obj =
  ### comment one ###
  ### comment two ###
  one: 1, two: 2
  fun: -> [zero: 0; three: @one + @two][1]

eq obj.fun().three, 3


# Dynamic object keys.
i = 0
o = splat: 'me'
obj = {
  ### leading comment  ###
  (4 * 2): 8
  ### cached shorthand ###
  (++i)
  ###      splat       ###
  ...o
  ...({splatMe: 'too'})
  ###   normal keys    ###
  key: ok
  's': ok
  0.0: ok

  "#{'interpolated'}":
    """#{"nested"}""": 123: 456
  ### traling comment  ###
}
eq obj.interpolated.nested[123], 456
eq obj[8], 8
eq obj[1], 1
eq obj.splat  , 'me'
eq obj.splatMe, 'too'
ok obj.key is obj.s is obj[0]

eq 'braceless dynamic key',
  (key for key in """braceless #{ 0 in ((0):(0)) and 'dynamic' } key""": 0)[0]

obj =
  one: 1
  (1 + 2 * 4): 9
eq obj[9], 9, 'trailing dynamic property should be braced as well'

obj.key = 'val'
obj.val = ok
{(obj.key)} = obj
eq ok, obj.key


eq '<[ quoted words ]>', <[ <[ quoted words ]\> ]>.join ' '
eq  1, <[]>.length
eq '', <[]>[0]


#coffee-542: Objects leading expression statement should be parenthesized.
{f: -> ok true }.f() + 1


#coffee-764: Boolean/Number should be indexable.
ok 42['toString']
ok true['toString']


ok 2r101010 == 8r52 == 36r16 == 42


#19
throws 'duplicated property name: a', -> Coco.compile 'a: 1, b: 2, a: 3'
