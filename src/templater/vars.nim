import tables

type
  VarKind* = enum
    vkStr, vkInt, vkArr, vkMap
  
  VarType* = ref object
    case kind*: VarKind:
    of vkStr: strValue*: string
    of vkInt: intValue*: int
    of vkArr: arrValue*: seq[VarType]
    of vkMap: mapValue*: Table[string, VarType]
  
func newType*(strValue: string): VarType {.inline.} =
  VarType(kind: vkStr, strValue: strValue)

func newType*(intValue: int): VarType {.inline.} =
  VarType(kind: vkInt, intValue: intValue)

func newType*(arrValue: seq[VarType]): VarType {.inline.} =
  VarType(kind: vkArr, arrValue: arrValue)

func newType*(mapValue: Table[string, VarType]): VarType {.inline.} =
  VarType(kind: vkMap, mapValue: mapValue)

func `$`*(vt: VarType): string =
  case vt.kind:
  of vkStr: vt.strValue
  of vkInt: $vt.intValue
  of vkArr: $vt.arrValue
  of vkMap: $vt.mapValue