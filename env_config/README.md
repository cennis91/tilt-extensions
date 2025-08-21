# Environment-Backed Configuration

This extension provides a helper function for managing environment-backed values.

Author: [CEnnis91](https://github.com/cennis91)

## Usage

Load the `env_config` extension with:

```python
load("ext://env_config", "env_config")
```

## Functions

### env_config

Creates an environment-backed config in a given namespace.

```python
env_config(namespace, defaults = {})
```

| Argument    | Type                    | Description                            |
|-------------|-------------------------|----------------------------------------|
| `namespace` | `str`                   | Dot-notation namespace for the config. |
| `defaults`  | `Optional[dict/struct]` | Default values for the config.         |

### env_config.default

Returns the default value of a given key.

```python
env_config.default(key)
```

| Argument | Type  | Description            |
|----------|-------|------------------------|
| `key`    | `str` | Name of the given key. |

| Returns | Description                                                 |
|---------|-------------------------------------------------------------|
| `Any`   | The default value of the given key, if set, otherwise None. |

### env_config.get

Returns the value of a given key.

```python
env_config.get(key, default = None)
```

| Argument  | Type            | Description                          |
|-----------|-----------------|--------------------------------------|
| `key`     | `str`           | Name of the given key.               |
| `default` | `Optional[Any]` | Default value if the key is not set. |

| Returns | Description                                                              |
|---------|--------------------------------------------------------------------------|
| `Any`   | The default value of the given key, if set, otherwise the default value. |

### env_config.reset

Resets the value of a given key.

```python
env_config.reset(key)
```

| Argument | Type  | Description            |
|----------|-------|------------------------|
| `key`    | `str` | Name of the given key. |

### env_config.set

Sets the value of a given key.

```python
env_config.set(key, value)
```

| Argument | Type  | Description            |
|----------|-------|------------------------|
| `key`    | `str` | Name of the given key. |
| `value`  | `Any` | Value to set.          |

## Examples

### Provide additional configuration to an extension

It's not possible to export a `binary` or `env` variable here, because Starlark freezes all values after evaluation.

```python
# my_tool/Tiltfile
load("ext://env_config", "env_config")

tool_config = env_config("my_tool", struct(
    binary = "echo",
    env = {},  # local_resource() default
))

def tool_exec(name, *args):
    args = ['"%s"' % arg for arg in list(args)]

    local_resource(
        name,
        cmd = "%s %s" % (tool_config.get("binary"), " ".join(args)),
        allow_parallel = True,  # should be thread-safe
        env = tool_config.get("env"),
    )
```

```python
# main/Tiltfile
load("../my_tool/Tiltfile", "tool_config", "tool_exec")

# normal usage
tool_exec("default", "hello world", "42")

# advanced, the user has the tool somewhere else
tool_config.set("binary", "printf")
tool_config.set("env", {"MESSAGE": "goodbye world"})
tool_exec("custom", "%s %05d\n", "$MESSAGE", "42")
```

Expected output when running `tilt ci`:

```text
Initial Build
Loading Tiltfile at: /home/example/main/Tiltfile
Successfully loaded Tiltfile (314.159µs)
      default │ 
      default │ Initial Build
      default │ Running cmd: echo "hello world" "42"
       custom │ 
       custom │ Initial Build
       custom │ Running cmd: sh -c "printf \"%s %05d\n\" \"$MESSAGE\" \"42\""
      default │ hello world 42
       custom │ goodbye world 00042
SUCCESS. All workloads are healthy.
```

## Notes

### Type Preservation

Type information is preserved for most types when encoding to the environment. Currently, `struct` type is **not supported**.

### Sensitive data

> [!CAUTION]
> Values stored by `env_config` are stored in the environment and therefore visible to other processes. Storing sensitive values, such as passwords is **strongly** discouraged.
