## PRELUDE
The purpose of this style guide is solely to serve as a general guide for my own projects. 
It's not really intended for use by others, but feel free to do so.

It's heavily inspired by the Google C++ style guide and the Rust style guide.

My goal is to make programming in C++ feel modern, comfortable, and enjoyable. 
Therefore, I will continue to update this guide as I learn more or find better options.

## NAMING
|Item|Case|
|------|----|
|Project|kebab-case|
|Files|snake_case|
|Types|PascalCase|
|enums|PascalCase|
|class/struct|PascalCase|
|functions|snake_case|
|methods|snake_case|
|variables|snake_case|
|Global constants|KPacalCase|
|macros|SCREAMING_SNAKE_CASE|

## INDENTATION
Always 2 spaces instead of tabulations.

**Anything in the code should have more than 4 indentations.**
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

All function/method declaration must have brief comment.
Special methods like constructor and destructor can ignore this rule.

|Item|Comment type|
|---|---|
|Header comment|`//!`|
|Brief comment|`///`|
|implementation comment|`//`|

Avoid using multi-line comments, 
as they make the code ugly by basically having two different ways of declaring comments.
