# vrd

A GitHub action to detect vulnerable regex in a pull request.

## Usage

Add the following to your workflow configuration:

```yml
...
- uses: meekdenzo/vrd@v1.0.0
...
```

### Example

Your full basic workflow should look something like this:

```yml
name: vuln-regex-detector
on: [workflow_dispatch]
jobs:
  build:
    name: Scan for redos
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2
      - name: Scan for redos
        uses: meekdenzo/vrd@v1.0.0
```
