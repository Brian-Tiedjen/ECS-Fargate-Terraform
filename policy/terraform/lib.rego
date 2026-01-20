package main

resources[r] {
  some path, value
  walk(input.planned_values.root_module, [path, value])
  path[count(path) - 1] == "resources"
  r := value[_]
}
