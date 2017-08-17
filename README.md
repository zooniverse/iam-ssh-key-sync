# iam-ssh-key-sync
Shell script for downloading IAM users' SSH keys

Usage:

```
fetch_keys.sh IAM_GROUP_NAME [OUTPUT_FILENAME] [UPDATE_DELAY] [CHMOD_UID]
```

Options:

- `IAM_GROUP_NAME` -- Which group authorized users are in.
- `OUTPUT_FILENAME` -- Optional. If provided, output will be written to this
  file. If missing or empty string, output is to stdout.
- `UPDATE_DELAY` -- Optional. How often (in seconds) the keys should be fetched.
  If missing or empty string, fetch keys once then exit.
- `CHMOD_UID` -- Optional. User ID who should own the output file. If missing or
  empty string, owner will be the user under which the command is running.

You may also specify an `EXTRA_KEYS` environment variable containing a
newline-separated list of additional (i.e. non-IAM) keys to be included in the
output. The contents of this variable will simply be prepended to the output.
