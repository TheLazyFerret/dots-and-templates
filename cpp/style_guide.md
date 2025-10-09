## PRELUDE
The purpose of this style guide is solely to serve as a general guide for my own projects. 
It's not really intended for use by others, but feel free to do so.

It's heavily inspired by the
[Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html) 
guide and the 
[Rust Style Guide](https://doc.rust-lang.org/beta/style-guide/index.html).

My goal is to make programming in C++ feel modern, comfortable, and enjoyable. 
Therefore, I will continue to update this guide as I learn more or find better options.

## PROPRAMMING PARADIGM
Use OOP for high-level entities, but prefer free functions for small utilities.

The principle of composition over inheritance will be followed.

The declaration and implementation, except for single-line implementations, will always be separate.

## FILE EXTENSION
|File|Extension|
|---|---|
|Implementation file|`.cpp`|
|Header file|`.hpp`|
|Template implementation file|`.tpp`|

Avoid the usage of template implementation files; 
instead, put the implementation inside the `.hpp`.

Every `.cpp` should have an associated `.hpp`.

## NAMING
|Item|Case|
|---|---|
|Project|`kebab-case`|
|Files|`snake_case`|
|Types|`PascalCase`|
|Enums|`PascalCase`|
|EnumOptions|`PascalCase`|
|Class/struct|`PascalCase`|
|Functions|`snake_case`|
|Methods|`snake_case`|
|Variables|`snake_case`|
|Attributes|`snake_case_`|
|Namespaces|`snake_case`|
|Global constants|`KPascalCase`|
|Macros|`SCREAMING_SNAKE_CASE`|

## INDENTATION
Always 2 spaces instead of tabulations.

**Anything in the code should have less than 4 indentations.**
If you need more than 4, you are probably doing something wrong.

Even when a column cap of 80 looks pretty neat, 
it is too short for long declarations, especially when namespace resolutions are involved.
Therefore, the soft column cap is 100 characters. The strict column cap is 120 characters.

## COMMENTS
All files must include a [header comments](header_comment.hpp), with the next fields:
- FileName
- Author
- Copyright
- License
- Brief

All function/method, in the implementation,
must have a [brief comment](function_comment.hpp),
with the next fields:
- Brief
- Param 1 type 
- Param 2 type
- ...
- Return type

Special methods like constructor and destructor can ignore this rule.

|Item|Comment type|
|---|---|
|Header comment|`//!`|
|Brief comment|`///`|
|implementation comment|`//`|

Avoid using multi-line comments, 
as they make the code ugly by basically having two different ways of declaring comments.

## LIBRARY CREATION
Small libraries can have both declaration and implementation in a single `.hpp`,
so can be compiled at the same time.

Otherwise, declaration and implementation must be in separated files.

## NAMESPACE
Always keep your code inside a namespace,
keeping clear the global namespace.

You can use a similar namespace to this one:
- `general_namespace`
  - `constants_namespace`
  - `Class`
  - `exception_namespace`
  - `free_functions_namespace`

Namespaces don’t introduce an extra indentation level. For example:
```cpp
namespace foo {

int fn_foo() {
  return 0;
}

}
```

## HEADER FILES
Header files must be self contained. 
Only the declaration should be present here.
If a inline function is declarated, must be defined in the same file.

Favor the use of `#pragma once` over classic inclusion guards.
The vast majority of commonly used compilers support it, so unless you need to compile on a very specific platform, this rule should be followed.

Avoid the usage of fordward declaration when possible.

Include only what you use. Avoid including headers that are only needed on the implementation.

Use angle-bracketed includes only in std headers and system headers.

The order of `#include` should be the next (with a blank line between them):

- System headers `.h` files.
- Standard library headers (without file extension)
- Other project's `.hpp` files.
- Your project's `.hpp` files.

## C++ VERSION
For new projects, target the new standard **c++23**.

### LOOPS
Try to use always memory safe loops.
Although not a strict rule, use this list as a way to order loop types (starting with the safest option):
- `for (element : container)`
- `for (auto iter = begin; iter != end; ++iter)`
- `for (variable; condition; updation)` 

### ERROR HANDLING
Be consistent.

Although currently there are many ways of handling errors, you should always try to the same approach throughout the project.

E.g: don't mix `std::exception` with `std::expected`.

Prefer the usage of `std::exception` for not critical code,
to keep consisteny with the standard library.

###  POINTERS
Consider using smart pointers (`std::unique_ptr` and `std::shared_ptr`) over traditional pointers.

Avoid the usage of `void*` pointers at all.

### ENUMS
Prefer the usage of `enum class` over traditional `enum`