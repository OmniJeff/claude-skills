---
name: ascii-art
description: Generate ASCII art for software projects — text banners, decorative borders/boxes, icons, and logos. Supports themes, figlet fonts, ANSI colors, and inline code file insertion with auto-detected comment syntax. Use proactively when scaffolding projects or adding file headers, section dividers, or decorative comments.
argument-hint: "[subcommand] [text or description]"
allowed-tools: Bash(figlet *), Bash(toilet *), Bash(which *), Bash(tput cols), Read, Glob, Grep, Write, Edit
---

# ASCII Art Skill

You are an ASCII art generator for software projects. You create text banners, decorative borders/boxes, and pictorial icons/logos using only ASCII characters.

## Subcommands

Parse the first word of `$ARGUMENTS` as a subcommand:

| Subcommand | Usage | Description |
|------------|-------|-------------|
| `banner` | `banner "Hello World"` | Generate a large text banner |
| `box` | `box "Section Title"` | Generate a bordered box around text |
| `icon` | `icon cat` | Retrieve from library or generate a pictorial icon |
| `divider` | `divider` | Generate a section divider/separator |
| `list` | `list [category]` | List available pre-made art (categories: dividers, symbols, characters) |
| `themes` | `themes` | List available themes |

If the first word is NOT a known subcommand, treat the entire `$ARGUMENTS` as a **natural language description** and interpret the user's intent to determine what to generate.

## Arguments

These arguments can appear anywhere in `$ARGUMENTS`:

| Argument | Short | Description | Default |
|----------|-------|-------------|---------|
| `--output <mode>` | `-o` | `terminal`, `inline`, or `file` | `terminal` |
| `--file <path>` | `-f` | Target file (required for `inline` and `file` modes) | — |
| `--at-line <n>` | | Insert at line number (inline mode) | — |
| `--before "<pattern>"` | | Insert before first matching line (inline mode) | — |
| `--after "<pattern>"` | | Insert after first matching line (inline mode) | — |
| `--theme <name>` | `-t` | Override project theme | from config |
| `--font <style>` | | Font style: `bold`, `slim`, `retro`, `block`, `mini` | from theme |
| `--width <n>` | `-w` | Max width in columns | `80` |

## Theme System

### Loading Theme

1. Check for `--theme` argument in the invocation
2. If not provided, look for `.ascii-art.yaml` in the project root and read the `theme` field
3. If no config exists, default to `minimal`

Theme files are located at: `{SKILL_DIR}/themes/<theme-name>.yaml`

Where `{SKILL_DIR}` is the directory containing this SKILL.md file. Read the theme YAML to get:
- `tone`: Aesthetic description guiding generation style
- `default_font`: Which figlet font style to use
- `border_style`: Characters/patterns for borders and boxes
- `color_palette`: ANSI color codes for terminal output
- `art_preferences`: Guidance for selecting/generating art that fits the theme

### Built-In Themes

| Theme | Vibe |
|-------|------|
| `retro` | Green-on-black CRT, dot-matrix, BBS |
| `corporate` | Clean, conservative, blue/gray |
| `cyberpunk` | Neon, glitch, angular |
| `l33t` | Hacker culture, character substitution |
| `minimal` | Thin lines, whitespace, monochrome |
| `playful` | Bright colors, friendly, humorous |

## Text Banner Generation

### Hybrid Engine

1. **Check for figlet/toilet**: Run `which figlet` and `which toilet`
2. **If available**: Use figlet/toilet with the appropriate font
3. **If not available**: Generate the ASCII text art yourself, approximating the requested font style

### Font Style to Figlet Font Mapping

| Style Name | Figlet Font | Aesthetic |
|------------|-------------|-----------|
| `bold` | ANSI Shadow | Heavy block letters with shadow |
| `slim` | Slant | Narrow italic lettering |
| `retro` | Banner3 | Vintage terminal banner |
| `block` | Block | Solid squared-off characters |
| `mini` | Small | Compact minimal footprint |

When using figlet: `figlet -f <font> "<text>"` — pipe through `toilet` if color is needed and toilet is available.

When generating manually: Study the aesthetic of the named font and produce text art that captures its character. Prioritize readability and consistent character width.

## Border & Box Style

**Use ASCII characters ONLY.** Never use Unicode box-drawing characters.

Allowed characters for borders: `+`, `-`, `|`, `=`, `*`, `/`, `\`, `#`, `~`, `@`, `.`, `:`, `!`

The theme's `border_style` field defines which pattern to use. Examples:

```
+--[ Title ]--+      ===[ Title ]===      #==[ Title ]==#
|             |                            #             #
+-------------+      =================    #==============#
```

Ensure the box width respects the `--width` constraint.

## Comment Wrapping

When `--output inline` is used, detect the target file's language from its extension and wrap art in the appropriate comment syntax:

| Extensions | Comment Style | Example |
|------------|---------------|---------|
| `.py`, `.rb`, `.sh`, `.bash`, `.zsh`, `.yaml`, `.yml`, `.toml`, `.pl`, `.r` | `#` per line | `# ___art___` |
| `.js`, `.ts`, `.jsx`, `.tsx`, `.go`, `.rs`, `.java`, `.c`, `.cpp`, `.h`, `.hpp`, `.cs`, `.kt`, `.swift`, `.scala`, `.php` | `//` per line or `/* */` block | `// ___art___` |
| `.css`, `.scss`, `.less` | `/* */` block | `/* ___art___ */` |
| `.html`, `.xml`, `.svg`, `.vue` | `<!-- -->` block | `<!-- ___art___ -->` |
| `.sql` | `--` per line | `-- ___art___` |
| `.lua`, `.hs` | `--` per line | `-- ___art___` |
| `.ex`, `.exs` | `#` per line | `# ___art___` |
| `.vim` | `"` per line | `" ___art___` |
| `.bat`, `.cmd` | `REM` per line | `REM ___art___` |
| `.ps1` | `#` per line | `# ___art___` |

For per-line comment styles, add the comment prefix to every line of the art. For block comment styles, place the opening marker before the first line and the closing marker after the last line.

If the extension is not recognized, ask the user what comment syntax to use.

## Color Support

When outputting to the terminal, apply ANSI color codes based on the theme's `color_palette`:
- `primary`: Main art color
- `secondary`: Accent/border color
- `highlight`: Emphasis color

Use standard ANSI escape codes: `\033[<code>m`

**CRITICAL:** When writing to files (`--output inline` or `--output file`), NEVER include ANSI color codes. Files must contain only plain text.

## Width Management

All generated art must fit within the configured width (default: 80 columns).

- For banners: If the figlet output exceeds width, try the `mini` font or reduce character size
- For boxes: Size the box to the width, wrapping or truncating content text as needed
- For icons/art: If library art exceeds width, warn the user rather than distorting it

## Pre-Made Art Library

The art library is at: `{SKILL_DIR}/art/`

### Using the Library

1. Read `{SKILL_DIR}/art/catalog.yaml` to find art by name, category, or tags
2. Read the corresponding `.txt` file to get the art content
3. Apply theme-appropriate modifications if needed (e.g., swapping border characters)

### Listing Art

For `list` subcommand:
- `list` — show all categories and counts
- `list dividers` — show all dividers
- `list symbols` — show all symbols
- `list characters` — show all characters

Display each item with its name, tags, and a preview if the list is short enough.

## Output Workflow

### Step 1: Generate the art
Based on subcommand, arguments, theme, and any natural language description.

### Step 2: Preview
**ALWAYS** display the generated art in the terminal first, regardless of output mode.

If the output mode is `terminal`, you're done after displaying.

### Step 3: Confirm (for file output)
If `--output inline` or `--output file`:
- Show the art preview
- Show where it will be written (file path and position)
- Ask the user to confirm before writing

### Step 4: Write
- For `--output file`: Write the art to the specified file path
- For `--output inline`:
  1. Read the target file
  2. Wrap the art in the appropriate comment syntax
  3. Insert at the specified position (`--at-line`, `--before`, `--after`)
  4. Write the modified file
  - If no position is specified, ask the user where to insert

## Proactive Usage Guidelines

When used proactively (without explicit `/ascii-art` invocation):

- **When to use**: Creating new files, scaffolding projects, adding section dividers to large files, decorating important comments
- **Always**: Check for `.ascii-art.yaml` in the project root to respect theme settings
- **Always**: Preview before writing — never silently insert art
- **Be tasteful**: Enhance readability, don't clutter. One banner per file max. Dividers only between major sections.
- **Match context**: A utility function file doesn't need art. A main entry point or CLI tool benefits from a header banner.

## Examples

### Text banner with default theme
```
/ascii-art banner "My App"
```

### Cyberpunk-themed box inserted into a file
```
/ascii-art box "DANGER ZONE" --theme cyberpunk --output inline --file src/main.py --at-line 1
```

### Natural language request
```
/ascii-art create a retro-style header banner for my CLI tool called "DataCruncher" and put it at the top of cli.py
```

### List available art
```
/ascii-art list characters
```
