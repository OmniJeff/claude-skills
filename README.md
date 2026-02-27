# claude-skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Skills

| Skill | Description |
|-------|-------------|
| [ascii-art](ascii-art/) | Generate ASCII art for software projects — text banners, decorative borders, icons, and logos with theme support |

## Install

Clone this repo and symlink the skill(s) you want into your Claude Code skills directory:

```bash
git clone https://github.com/OmniJeff/claude-skills
ln -s /path/to/claude-skills/ascii-art ~/.claude/skills/ascii-art
```

Then start a new Claude Code session. The skill will be available as `/ascii-art`.

## License

[MIT](LICENSE)
