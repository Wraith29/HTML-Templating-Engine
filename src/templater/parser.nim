import strutils, sugar, tables, ./vars

type
  Parser = ref object
    code: string
    index: int
    vars: Table[string, VarType]

func newParser(code: string, vars: Table[string, VarType]): Parser =
  Parser(code: code, index: 0, vars: vars)

func current(parser: Parser): char = 
  parser.code[parser.index]

func peek(parser: Parser, n: int = 1): char = 
  parser.code[parser.index + n]

func skip(parser: var Parser, n: int): void = 
  parser.index += n

func next(parser: Parser): bool = 
  parser.index < parser.code.len

func hasVar(parser: Parser, key: string): bool = 
  parser.vars.hasKey(key)

func collectUntil(parser: Parser, delimiter: char): string =
  var n = 0
  while parser.peek(n) != delimiter:
    result.add(parser.peek(n))
    inc n

func collectUntil(parser: Parser, slice: string): string =
  var n = 0
  while parser.code[parser.index + n .. parser.index + n + slice.len - 1] != slice:
    result.add(parser.peek(n))
    inc n

func parseVar(parser: var Parser): void =
  let name = parser.collectUntil('|')
  if not parser.hasVar(name.strip): return
  let idx = parser.code.find(name.strip, parser.index, parser.code.len) - 2
  parser.code.delete(idx .. idx + name.len + 3)
  parser.code.insert($parser.vars[name], idx)

func parseForLoopVar(parser: Parser, pref: string, obj: VarType, original: string): string =
  if obj.kind != vkMap: return
  result = deepCopy(original)
  var 
    idx = 0
    endIdx = 0
    name: string

  while idx < result.len - 1:
    if result[idx .. idx + 1] == "{|":
      endIdx = result.find("|}", endIdx + 1, result.len - 1)
      name = result[idx + 2 .. endIdx - 1]
      
      if name.startsWith(pref):
        name.delete(0 .. pref.len)
        if obj.mapValue.hasKey(name):
          result.delete(idx .. endIdx + 1)
          result.insert($obj.mapValue[name], idx)
    inc idx

func parseLoop(parser: var Parser): void = 
  let 
    startIdx = parser.index - 2
    inner = parser.collectUntil('!').strip
    varPref = inner.split(" ")[1]
    varName = inner.split(" ")[3]

  if not parser.hasVar(varName.strip): return
  if parser.vars[varName].kind != vkArr: return
  let forDeclLen = parser.collectUntil("!}").len
  parser.skip(forDeclLen + 2)
  let forBlock = parser.collectUntil("{!}")
  var parsed: string
  for obj in parser.vars[varName].arrValue:
    parsed &= parser.parseForLoopVar(varPref, obj, forBlock)

  let blockLen = parser.collectUntil("{!}").len

  parser.code.delete(startIdx .. startIdx + forDeclLen + blockLen + 6)
  parser.code.insert(parsed, startIdx)
    
func parse(parser: var Parser): void =
  parser.code = collect(
    for line in parser.code.split("\n"):
      if line == "": continue
      line.strip()
  ).join()

  while parser.next():
    if parser.current == '{':
      if parser.peek() == '|':
        parser.skip(2)
        parser.parseVar()
      elif parser.peek() == '!' and parser.peek(2) != '}':
        parser.skip(2)
        parser.parseLoop()
    parser.skip(1)

func parseTemplate*(code: string, vars: Table[string, VarType]): string =
  var parser = newParser(code, vars)
  parser.parse()
  parser.code

func parseTemplate*(code: string): string =
  parseTemplate(code, initTable[string, VarType]())