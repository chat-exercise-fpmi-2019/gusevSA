# Chat protocol -- CP/0.1.1

## Status of this Memo

In development

# Purpose

This document specifies a chat protocol for the 13 group FAMCS BSU

# General overview

## System description

The system API based on REST API.
The system is an immediate chat. It consists server and client.

## Semantic convention

Describing messages we will apply following semantic conventions:

- Special symbols like SP and CRLF are represented with appropriate symbols.
- Interpolation of strings is represented with __#{__ string-to-interpolate __}__ symbols.

## Available commands

### Client

- Authenticate user - `Auth`
- Set _username_ - `Set-name`
- Send _private_ message - `Private-message`
- Send _broadcast_ message `Broadcast-message`

### Server

- Send _response_ / _error_ message to requested user
- Send _message_ to appropriate user. `Incoming-message`

## Flow description

Firstly Client and Server establishing connection. Then Client sends Request chain with request data.
Server answers by sending message to client with response data.

              Request chain ------------------------>
       Client ----------------Connection------------- Server
              <----------------------- Response chain

## Connection

Clients establish a TCP (see RFC 793) connection with a server and communicate with text messages.

Connection establishment features:

- Three-way handshake: SYN, SYN-ACK, ACK.

Connection termination carried out using FIN bashes that let server know about connection termination.

### Entities

Chat entities are represented below:

- User
  - Username
- Message
  - Status line (only server message)
  - Type of query
  - Header
  - Empty line
  - Body

_Username_ restrictions:

- _username_ must be shorter then 64 symbols and wider then 1 symbol.
- _username_ must consist of only numbers and latin letters in any case.

_Message_ restrictions are shown below.

### Messages

Messages are consist of **status line**, **query type**, **header** and **body**.

All text MUST be encoded as UTF-8 (RFC 3629) for network transmission.

Messages mismatching with this RFC structure and semantic will cause unpredictable behavior.

Messages are different between Client and Server, but structure of message is immutable and common for both of them.

General message structure:

- A status line.
- Query type.
- Optional header fields followed by CRLF. Header fields start from _header rule_, then follows comma _:_, and then _rule value_: `#{Header rule}: #{Header value} CRLF`. Example:

```http
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=

```

- An empty line (i.e., a line with nothing preceding the CRLF) indicating the end of the header fields.
- Optional message body

#### Server

##### Status line

Status line consists of *status code*, *reason phrase*.

`Status-line = #{Status-code} SP #{Reason-phrase} CRLF`

Restrictions:

- *Status code* ans *reason phrase* should be only as shown in chapter _Status code and reason phrase_. Any other variants will be considered as incorrect.

Example:

```http
200 OK

```

##### Type of query

It contains only from one word, that represents type of query, followed by CRLF symbols.

Restrictions:

- *Type of query* should be only as shown in following chapters. Any other variants will be considered as incorrect.

Example:

```http
Set-name

```

##### Header

###### Authentication token

**authentication token** used to store information about authentication.

`Auth: #{Authentication-token} CRLF`

Example:
Authentication token represented by string `Hello, I'm authentication token!` encoded by B64. 

Restrictions:

- It must be shorter then 2048 symbols and wider then 1 symbol.
- It must consist of only numbers and latin in any case letters.
- Allowed special symbols like `=`, `:`, `;`, `,`, `.` etc.

```http
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=

```

###### Length of body content

It's a number that represents length of body including all the symbols in body.

Restrictions:

- _Length of body content_ must consist only of numbers in decimal number system.
- Minimal value is 0 if body is void
- Maximum value is 2048.

`Content-length: #{Length-of-body-content} CRLF`

Example:

```http
Content-length: 335

```

##### Body
Body contains **response data**.

Restrictions:

- Different corresponding to each query type. See next chapters.

`Body = #{Response-data} CRLF`

#### Client

##### Header 

Header contains **authentication token**, **query type** and **length of body content**.

_Authentication token string_, and _Length of body content_ are the same with corresponding strings on the server.

##### Body
Body contains request data.

`Body = #{Request-data} CRLF`

Restrictions:

- Different corresponding to each query type. See next chapters.

## Status code and reason phrase

Status code and reason phrase reflect what the consequences request message was lead to.

Possible Status codes and reason phrases are below:

`Status-code; SP Reason-phrase`

- "200"; OK
- "304"; Not Modified
- "400"; Bad Request
- "401"; Unauthorized
- "404"; Not Found
- "418"; 'I'm a tea pocket'
- "500"; Internal Server Error
- "501"; Not Implemented
- "502"; Bad Gateway

### Default request handling

It is used corresponding all requests excluding `Auth` request. This flow is presented follow:

- _request_ semantically valid
  - _auth token_ is valid.
    - _Content-length_ is valid.
      - Request handling corresponding request type.
  - _auth token_ is invalid. Server responses with status code `401` and void body.
- _request_ semantically invalid. Server responses with status code `400` and void body.

### Client messages

#### Auth

`Auth` message is used in purpose of determining if the user is who he 'says' he is. If request passed successfully, server return _authentication token_, that will by passed to all other requests by the user in appropriate header rule `Auth`.

It should match following rules. Restrictions:

- Body is presented by _nickname_ string and _password_ string.
- _username_
  - _username_. It must have appropriate length as mentioned in the header rule _Content-length_.
  - _username_ must match _username_ restrictions described above.
- _password_
  - _password_ must be shorter then 64 symbols and wider then 12 symbol.
  - _password_ must consist of at least:
    - 1 number.
    - 1 latin letter in upper case.
    - 1 latin letter in lower case.
    - 1 special symbol: `+`, `-`, `*`, `/`, `\`, `@`, `#`, `$`, `!`, `.`, `,`, `;`, `=`, `_`.
- CRLF symbol finishes rule.

Example:

```http
Auth
Content-length: 18

SanyaNagibator777
12345678Aa+

```

Possible responses:

- _username_ is valid.
  - _password_ is valid.
    - _username_ exists in database.
      - _password_ matches _username_. Server responses with status code `200` and following body string : `${Authentication token}`.
      - _password_ mismatches _username_. Server responses with status code `401` and following body string : `Username or password are wrong.`.
    - _username_ does not exist. Server responses with status code `401` and following body string : `Username is wrong.`.
  - _password_ is not valid. Server responses with status code `400` and following body string : `Password is invalid.`.
- _username_ is not invalid. Server responses with status code `400` and following body string : `Username is invalid.`.

#### Set-name

`Set-name` message is used in purpose of setting new username to the user.

It should match following rules. Restrictions:

- New _username_. It must have appropriate length as mentioned in the header rule _Content-length_.
- _username_ must match _username_ restrictions described above.
- CRLF symbol finishes rule.

Example:

```http
Set-name
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=
Content-length: 18

SanyaNagibator777

```

Possible responses:

- _username_ is valid.
  - _username_ is unique. Server responses with status code `200` and void body.
  - _username_ is non-unique. Server responses with status code `400` and following body string : `Username is not unique.`.
- _username_ is invalid. Server responses with status code `400` and following body string : `Username is invalid.`.

#### Private-message

`Private-message` message is used in purpose of private sending message to a user.

It should match following rules. Restrictions:

- Body is represented by _recipient username_ and user _message_.
- All body must have appropriate length as mentioned in the header rule _Content-length_.
- Message starts with _recipient username_.
  - _recipient username_ must match _username_ restrictions as was mentioned above.
- CRLF symbol.
- Then follows _message_.
  - _message_ must be shorter then 2048 symbols and wider then 1 symbol.
  - _message_ can consist of any UTF-8 characters.
  - _message_ finishes by a CRLF symbol.

Example:

```http
Private-message
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=
Content-length: 60

SanyaNagibator777
Hello, go v dotky poigraem.
╲( ͡° ͜ʖ ͡°)╱

```

Possible responses:

- _recipient username_ is valid.
  - _message_ is valid.
    - _message_ is sent successfully. Server responses with status code `200` and void body.
    - _message_ is sent unsuccessfully. Server responses with status code `400` and following body string : `Message has been sent unsuccessfully.`.
  - _message_ is invalid. Server responses with status code `400` and following body string : `Message is invalid.`.
- _recipient username_ is invalid. Server responses with status code `400` and following body string : `Recipient username is invalid.`.

#### Broadcast-message

`Broadcast-message` message is used in purpose of sending message to all users.

It should match following rules. Restrictions:

- Body is represented by user _message_.
- It must have appropriate length as mentioned in the header rule _Content-length_.
- _message_ must be shorter then 2048 symbols and wider then 1 symbol.
- _message_ can consist of any UTF-8 characters.
- _message_ finishes by a CRLF symbol.
unnecessary
Example:

```http
Broadcast-message
Auth: SGVsbG8sIEknbSBhdXRoZW50aWNhdGlvbiB0b2tlbiE=
Content-length: 42

Hello, go v dotky poigraem. ╲( ͡° ͜ʖ ͡°)╱

```

Possible responses:

- _message_ is valid.
  - _message_ is sent successfully. Server responses with status code `200` and void body.
  - _message_ is sent unsuccessfully. Server responses with status code `400` and following body string : `Message has been sent unsuccessfully.`.
- _message_ is invalid. Server responses with status code `400` and following body string : `Message is invalid.`.

### Server messages

#### Incoming-message

`Incoming-message` message is used in purpose of sending derived message to user.

It should match following rules. Restrictions:

- Body is represented by user _message_.
- It must have appropriate length as mentioned in the header rule _Content-length_.
- _message_ must be shorter then 2048 symbols and wider then 1 symbol.
- _message_ can consist of any UTF-8 characters.
- _message_ finishes by a CRLF symbol.

Example:

```http
Incoming-message
Content-length: 42

Hello, go v dotky poigraem. ╲( ͡° ͜ʖ ͡°)╱

```
