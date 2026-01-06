# bqn-zip
A zip library for BQN

It currently provides unzipping via `Unzip` that takes bytes from a zip file and outputs a `names≍file_contents` and `Zip` which undoes that.

There is also `dir` for working with existing directories. `dir.Bytes` works similar to `•file.Bytes` but works on directories and `names≍file_contents`.

```bqn
"result.zip" •file.Bytes Zip dir.Bytes "folder" # zipping a directory into a zip file
"folder" dir.Bytes Zip⁼ •file.Bytes "result.zip" # unzipping a zip file into a directory
"destination/" dir.Bytes dir.Bytes "source/" # copying directories (follow symlinks by default)
```
