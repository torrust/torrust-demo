# Linting

This project uses linting tools to ensure code quality and consistency.

## Markdown Linting

All Markdown files must pass the markdown linter before being committed.

### Running Markdown Linter

To check Markdown files for linting errors:

```bash
# Check a specific file
npx markdownlint-cli2 README.md

# Check all Markdown files
npx markdownlint-cli2 "**/*.md"
```

### Common Markdown Linting Errors

**MD032: Lists should be surrounded by blank lines**

This error occurs when lists don't have blank lines before and after them.

❌ **Incorrect:**

```markdown
Some text:

- Item 1
- Item 2
  More text
```

✅ **Correct:**

```markdown
Some text:

- Item 1
- Item 2

More text
```

### Fixing Markdown Linting Errors

When you encounter linting errors:

1. Read the error message to understand which rule is violated
2. Identify the line number in the error output
3. Fix the issue according to the rule's requirements
4. Re-run the linter to verify the fix

Most editors have markdown linting extensions that show errors in real-time:

- VS Code: `markdownlint` extension
- Vim/Neovim: Various linting plugins
- JetBrains IDEs: Built-in markdown support

## Spell Checking with CSpell

All files in the repository must pass CSpell spell checking.

### Running CSpell

To check files for spelling errors:

```bash
# Check a specific file
npx cspell README.md

# Check all files (respects .gitignore)
npx cspell "**/*"
```

### CSpell Configuration

CSpell is configured via [`cspell.json`](../cspell.json) in the repository root:

```json
{
  "version": "0.2",
  "dictionaryDefinitions": [
    {
      "name": "project-words",
      "path": "./project-words.txt",
      "addWords": true
    }
  ],
  "dictionaries": ["project-words"]
}
```

### Adding Words to Dictionary

If CSpell reports a spelling error for a valid project-specific term:

1. Open [`project-words.txt`](../project-words.txt)
2. Add the word to the list (maintain alphabetical order)
3. Save the file
4. Re-run CSpell to verify

Example `project-words.txt`:

```text
certbot
fullchain
qbittorrent
Torrust
torrust
TORRUST
webroot
```

### Common CSpell Patterns

**Project Names**: Add all variations of project names:

- `Torrust` (capitalized)
- `torrust` (lowercase)
- `TORRUST` (uppercase)

**Technical Terms**: Add domain-specific terms:

- `certbot`
- `webroot`
- `qbittorrent`

**Configuration Keys**: Add configuration property names that aren't standard English words.

### Fixing CSpell Errors

When you encounter spelling errors:

1. Check if it's a typo - if so, fix the typo
2. If it's a valid term (project name, technical term), add it to `project-words.txt`
3. Maintain alphabetical order in the dictionary file
4. Re-run CSpell to verify

### Editor Integration

Most editors support CSpell integration:

- **VS Code**: Install the `Code Spell Checker` extension
- **Vim/Neovim**: Use `coc-spell-checker` or similar plugins
- **JetBrains IDEs**: Built-in spell checking with custom dictionaries

## Pre-commit Checks

Before committing:

1. Run markdown linter on any modified `.md` files
2. Run CSpell on all modified files
3. Fix any errors reported
4. Commit only after all checks pass

## CI/CD Integration

Linting checks should be automated in CI/CD pipelines to ensure all code meets quality standards before merging.
