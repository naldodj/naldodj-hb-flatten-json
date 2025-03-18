# tests

### Original JSON
```json
{
    "fruit": "banana",
    "number": 2,
    "option": "yes",
    "status": "active"
}
```
### Flattened JSON
```json
{
    "fruit": "banana",
    "number": 2,
    "option": "yes",
    "status": "active"
}
```
---
### Original JSON
```json
{
    "type": "object",
    "required": ["fruit","number","option","status"],
    "properties": {
        "fruit": {
            "type": "string",
            "enum": ["apple","banana","cherry"]
        },
        "number": {
            "type": "number",
            "enum": [1,2,3]
        },
        "option": {
            "type": "string",
            "enum": ["yes","no"]
        },
        "status": {
            "type": ["string","null"],
            "enum": [null,"active","inactive"]
        }
    }
}
```
### Flattened JSON
```json
{
  "type": "object",
  "required": "__$A:4",
  "required[0]": "fruit",
  "required[1]": "number",
  "required[2]": "option",
  "required[3]": "status",
  "properties": "__$O:4",
  "properties.fruit": "__$O:2",
  "properties.fruit.type": "string",
  "properties.fruit.enum": "__$A:3",
  "properties.fruit.enum[0]": "apple",
  "properties.fruit.enum[1]": "banana",
  "properties.fruit.enum[2]": "cherry",
  "properties.number": "__$O:2",
  "properties.number.type": "number",
  "properties.number.enum": "__$A:3",
  "properties.number.enum[0]": 1,
  "properties.number.enum[1]": 2,
  "properties.number.enum[2]": 3,
  "properties.option": "__$O:2",
  "properties.option.type": "string",
  "properties.option.enum": "__$A:2",
  "properties.option.enum[0]": "yes",
  "properties.option.enum[1]": "no",
  "properties.status": "__$O:2",
  "properties.status.type": "__$A:2",
  "properties.status.type[0]": "string",
  "properties.status.type[1]": "null",
  "properties.status.enum": "__$A:3",
  "properties.status.enum[0]": null,
  "properties.status.enum[1]": "active",
  "properties.status.enum[2]": "inactive"
}
```
---
### Original JSON
```json
{
  "definitions":
  {
    "positiveIntegerDefault0":
    {
      "allOf":
      [
        {
          "$ref": "#/definitions/positiveInteger"
        },
        {
          "default": 0
        }
      ]
    }
}
```
### Flattened JSON
```json
{
  "definitions": "__$O:1",
  "definitions.positiveIntegerDefault0": "__$O:1",
  "definitions.positiveIntegerDefault0.allOf": "__$A:2",
  "definitions.positiveIntegerDefault0.allOf[0]": "__$O:1",
  "definitions.positiveIntegerDefault0.allOf[0].$ref": "#/definitions/positiveInteger",
  "definitions.positiveIntegerDefault0.allOf[1]": "__$O:1",
  "definitions.positiveIntegerDefault0.allOf[1].default": 0
}
```
---
