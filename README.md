<div style="text-align: center;">
	<h1>Veronica Project</h1>
</div>

## I. Introduction

A video game ?

## II. Clone the project
- Install Godot [4.7.2](https://godotengine.org/download/archive/4.7.2-stable/) ;
- Clone the project ;
- Create godot alias command in powershell :
	- `notepad $PROFILE` ;
	- Save `Set-Alias godot "D:\Software\Godot\Godot_v4.7.2-stable_win64_console.exe"` in $PROFILE ;
	- execute `godot --headless --path . --import`
	- Test with `godot --headless --path .`

View `VI.` for project debug commands.

## III. Style guideline

### naming conventions

- Files: snake_case ;
- Nodes: PascalCase ;
- Constants: CONSTANT_CASE ;
- Variables et Functions: snake_case.

### Comments type

This example is taken from the [official documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html).

```
## A brief description of the class's role and functionality.
##
## The description of the script, what it can do,
## and any further detail.
##
## @tutorial:             https://example.com/tutorial_1
## @tutorial(Tutorial 2): https://example.com/tutorial_2
## @experimental
```

## IV. Version guide

Versions follow the `x.y.z` format. You can find the current version of the bot in the
`pyproject.toml` file.

- **x** — major version, breaking changes or full rework ;
- **y** — new feature added ;
- **z** — bug fix or patch.

## V. Commit guideline

### Structure

```
<type>: <50 char max summary>

<75 char max description or list>
```

### Types

- **feat** ;
- **fix** ;
- **chore** ;
- **docs** ;
- **refactor**.

## VI. Debug commands
The engine option are set before `--` and mine after.

- `godot --version`: Godot version
- `godot --path .`: Open game windows *(check terminal for logs)*
- `godot --headless --path .`: No windows, juste terminal logs
- `godot --headless --path . --export-pack "Windows" build/jeu.pck`: Export game data only
- `godot --main-pack build/jeu.pck`: Run the exported pack
- `godot --headless --path . -- --server`: Start the server (UDP port 7000)
- `godot --path . -- --join`: Open the game and join the server on this computer
