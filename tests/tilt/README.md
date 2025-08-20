# Tilt Tests in Tilt

This extension provides basic assert-like functions for testing Tilt / Starlark code. Results are formatted like Tilt's internal logstore.

Author: [CEnnis91](https://github.com/cennis91)

## Usage

Load the `test_tilt` extension with:

```python
load('ext://tests/tilt', 'test_tilt')
```

## Functions

### test_tilt

Create an object that performs basic test assertions.

```python
test_tilt(name, fatal_on_fail = False)
```

| Argument        | Type             | Description                           |
|-----------------|------------------|---------------------------------------|
| `name`          | `str`            | Name of the tester object.            |
| `fatal_on_fail` | `Optional[bool]` | Abort execution on failure when True. |

### test_tilt.assert

Perform a basic assertion that actual matches expected.

```python
test_tilt.assert(test_name, expected, actual, details = None)
```

| Argument    | Type            | Description                               |
|-------------|-----------------|-------------------------------------------|
| `test_name` | `str`           | Name of the test.                         |
| `expected`  | `Any`           | Expected result.                          |
| `actual`    | `Any`           | Actual result.                            |
| `details`   | `Optional[str]` | Additional details to display on failure. |

| Returns | Description                               |
|---------|-------------------------------------------|
| `bool`  | True if the test passes, False otherwise. |

### test_tilt.false

Assert that the actual value is False.

```python
test_tilt.false(test_name, actual, details = None)
```

| Argument    | Type            | Description                               |
|-------------|-----------------|-------------------------------------------|
| `test_name` | `str`           | Name of the test.                         |
| `actual`    | `Any`           | Actual result.                            |
| `details`   | `Optional[str]` | Additional details to display on failure. |

| Returns | Description                               |
|---------|-------------------------------------------|
| `bool`  | True if the test passes, False otherwise. |

### test_tilt.print

Print a logstore-styled message to the console.

```python
test_tilt.print(message, text_color = None)
```

| Argument     | Type            | Description             |
|--------------|-----------------|-------------------------|
| `message`    | `str`           | Message text.           |
| `text_color` | `Optional[str]` | Optional message color. |

### test_tilt.true

Assert that the actual value is True.

```python
test_tilt.true(test_name, actual, details = None)
```

| Argument    | Type            | Description                               |
|-------------|-----------------|-------------------------------------------|
| `test_name` | `str`           | Name of the test.                         |
| `actual`    | `Any`           | Actual result.                            |
| `details`   | `Optional[str]` | Additional details to display on failure. |

| Returns | Description                               |
|---------|-------------------------------------------|
| `bool`  | True if the test passes, False otherwise. |

## Examples

### Test a function

```python
def add(a, b):
    return a + b

test = test_tilt("add")

test.assert("test_tilt.assert", 4, add(2, 2))
test.false("test_tilt.false", add(2, 2) == 5)
test.true("test_tilt.true", add(2, 2) == 4)

test.assert("failure", 5, add(2, 2))
test.assert("failure.message", 5, add(2, 2), "This was expected")
```

Expected output when running `tilt ci`:

```text
Initial Build
Loading Tiltfile at: /home/example/Tiltfile
          add │ [PASS] test_tilt.assert
          add │ [PASS] test_tilt.false
          add │ [PASS] test_tilt.true
          add │ [FAIL] failure: Expected '5', but got '4'
          add │ [FAIL] failure.message: This was expected
Successfully loaded Tiltfile (31.415926ms)
```

### Abort on test failure

```python
def add(a, b):
    return a + b

test = test_tilt("add", fatal_on_fail = True)
test.assert("test_tilt.assert", 4, add(2, 2))
test.assert("failure", 5, add(2, 2))
```

Expected output when running `tilt ci`:

```text
Initial Build
Loading Tiltfile at: /home/example/Tiltfile
          add │ [PASS] test_tilt.assert
ERROR: Traceback (most recent call last):
  /home/example/Tiltfile:6:12: in <toplevel>
  /home/example/tests/tilt/Tiltfile:105:17: in _assert
Error in fail:           add │ [FAIL] failure: Expected '5', but got '4'
```

## Enable / Disable Coloring

The `test_tilt` extension uses the [color extension](../../color/README.md) to color the test output. Therefore, you can use the same environment variables described in that extension, e.g. `NO_COLOR=1 tilt ci` and `FORCE_COLOR=1 tilt ci`.
